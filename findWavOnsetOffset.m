function varargout = findWavOnsetOffset(wav, Fs, varargin)
%--------------------------------------------------------------------------
% [out_bins, out_ms] = findWavOnsetOffset(wav, Fs, 
%														'UserConfirm', 
% 														'Threshold', threshold, 
% 														'RMSWin', rmswin_ms, 
% 														'MeanWin', meanwin)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% finds onset, offset of audio signal wav sampled at Fs samples/sec
%--------------------------------------------------------------------------
% Input Arguments:
%	wav	audio signal
%	Fs		sample rate (samples/sec)
% 
% 	Optional Inputs:
% 	'UserConfirm'		if included as input, automatically detected onset and 
% 							offset will need to be confirmed by user
% 	'Threshold'			threshold dV/dt value to detect change from background
% 							mean RMS value. Default: 0.1 V/ms
% 	'RMSWin'				window for computing RMS. Default: 0.1 ms
% 	'MeanWin'			# bins for computing mean for threshold. Default: 5 bins
% 	'WAVName'			name of wav to add to plot
%	'Method'				threshold detect method
% 								'drmsdt'		use slope of RMS (default)
% 								'rms'			use RMS
%	'Axis'				use defined axis handle for plot
%
% Output Arguments:
%	 out_bins			[onset offset] bins in 1X2 vector
%	 out_ms				[onset offset] milliseconds in 1X2 vector
%--------------------------------------------------------------------------
% See Also: getWavInfo, opto
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Created:	4 April, 2017 (SJS)
%
% Revision History:
%	18 Apr 2019 (SJS): added Axis input
%	22 Apr 2019 (SJS): revisions
%		- fixed offset issue when using default methods
%		- pulled out nested functions
%		- hopefully improved plotting in formerly nested functions
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

	%------------------------------------------------------------------------
	% defaults
	%------------------------------------------------------------------------
	userconfirm = 0;
	rmswin_ms = 0.1;
	meanwin = 5;
	threshold = 0.1;
	wavname = '';
	method = 'drmsdt';
	axH = [];
	
	valid_methods = {'drmsdt', 'rms'};
	
	%------------------------------------------------------------------------
	% check input arguments
	%------------------------------------------------------------------------
	nvararg = length(varargin);
	if nvararg
		aindex = 1;
		while aindex <= nvararg
			switch(upper(varargin{aindex}))

				% select if user confirms selection
				case 'USERCONFIRM'
					userconfirm = 1;
					aindex = aindex + 1;

				case 'THRESHOLD'
					threshold = varargin{aindex + 1};
					aindex = aindex + 2;

				case 'RMSWIN'
					rmswin_ms = varargin{aindex + 1};
					aindex = aindex + 2;

				case 'MEANWIN'
					meanwin = varargin{aindex + 1};
					aindex = aindex + 2;
					
				case 'WAVNAME'
					wavname = varargin{aindex + 1};
					aindex = aindex + 2;
					
				case 'METHOD'
					tmp = varargin{aindex + 1};
					if isempty(tmp) || ~any(strcmpi(tmp, valid_methods))
						error('%s: invalid Method %s', mfilename, tmp);
					else
						method = tmp;
					end
					aindex = aindex + 2;
					
				case 'AXIS'
					if ~ishandle(varargin{aindex+1})
						error('%s: not valid axis handle', mfilename);
					else
						axH = varargin{aindex+1};
					end
					aindex = aindex + 2;

				otherwise
					error('%s: Unknown option %s', mfilename, varargin{aindex});
			end
		end
	end

	% if axH ius empty, use current axes or use current
	if isempty(axH)
		axH = gca;
	end
	
	%------------------------------------------------------------------------
	% find onset
	%------------------------------------------------------------------------
	figure(1);
	axOn = gca;
	if strcmpi(method, 'rms')
		onset = rms_onset(wav, Fs, userconfirm, rmswin_ms, meanwin, ...
																		threshold, ...
																		['ONSET:' wavname], ...
																		axOn);
	else
		onset = drmsdt_onset(wav, Fs, userconfirm, rmswin_ms, meanwin, ...
																		threshold, ...
																		['ONSET:' wavname], ...
																		axOn);
	end
	
	%------------------------------------------------------------------------
	% find offset
	%------------------------------------------------------------------------
	figure(2);
	axOff = gca;
	% flip wav around
	if isrow(wav)
		wav = fliplr(wav);
	else
		wav = flipud(wav);
	end
	if strcmpi(method, 'rms')
		% then use "onset" to find offset
		tmp = rms_onset(wav, Fs, userconfirm, rmswin_ms, meanwin, ...
																		threshold, ...
																		['OFFSET:' wavname], ...
																		axOff);
	else
		tmp = drmsdt_onset(wav, Fs, userconfirm, rmswin_ms, meanwin, ...
																		threshold, ...
																		['OFFSET:' wavname], ...
																		axOff);
	end
	% need to subtract from total length to give offset
	offset = length(wav) - tmp;
	% build output
	varargout{1} = [onset offset];
	if nargout > 1
		varargout{2} = bin2ms([onset offset], Fs);
	end
	
end	% END of findWavOnset