function out = findWavOnsetOffset(wav, Fs, varargin)
%--------------------------------------------------------------------------
% out = findWavOnsetOffset(wav, Fs, 'UserConfirm', 'Threshold', threshold, 
% 												 'RMSWin', rmswin_ms, 'MeanWin', meanwin)
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
%
% Output Arguments:
%	 [onset offset] bins in 1X2 vector
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

				otherwise
					error('%s: Unknown option %s', mfilename, varargin{aindex});
			end
		end
	end

	%------------------------------------------------------------------------
	% find onset
	%------------------------------------------------------------------------
	if strcmpi(method, 'rms')
		onset = rms_onset(wav, Fs, userconfirm, rmswin_ms, meanwin, ...
																		threshold, ...
																		['ONSET:' wavname]);
	else
		onset = drmsdt_onset(wav, Fs, userconfirm, rmswin_ms, meanwin, ...
																		threshold, ...
																		['ONSET:' wavname]);		
	end
	
	%------------------------------------------------------------------------
	% find offset
	%------------------------------------------------------------------------
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
																		['OFFSET:' wavname]);
	else
		onset = drmsdt_onset(wav, Fs, userconfirm, rmswin_ms, meanwin, ...
																		threshold, ...
																		['OFFSET:' wavname]);	
	end
	% subtract from total length to give offset
	offset = length(wav) - tmp;
	% build output
	out = [onset offset];
	
end	% END of findWavOnset

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function out = rms_onset(wav, Fs, userconfirm, rmswin_ms, ...
														meanwin, threshold, ptitle)
%--------------------------------------------------------------------------
	% plot signal in blue
	figure(314);
	dt = (1/Fs);
	t_wav = 1000 * dt * ( 0:(length(wav) - 1) );
	plot(t_wav, wav, 'b.');
	title(ptitle, 'Interpreter', 'none')
	grid on

	% compute rms of signal in blocks, then plot it in green
	wavrms = block_rms(wav, ms2bin(rmswin_ms, Fs));
	t_rms = rmswin_ms * (0:(length(wavrms) - 1));
	hold on
		plot(t_rms, wavrms, 'g');
	hold off

	% find first value above threshold
	rmsonsetbin = 0;
	rmsonsetval = [];
	av = moving_average(wavrms, meanwin);
	hold on
		plot(t_rms, av, 'r')
	hold off
	for n = 1:length(av)
		if (rmsonsetbin == 0) && (av(n) > threshold)
			rmsonsetbin = n;
			rmsonsetval = av(n);
		end
	end
	if rmsonsetbin == 0
		rmsonsetbin = 1;
		onsettime = t_rms(rmsonsetbin);
		rmsonsetval = av(rmsonsetbin);
	else
		% check onset
		onsettime = t_rms(rmsonsetbin)-(meanwin*rmswin_ms);
	end
	if onsettime < 0
		onsettime = t_rms(rmsonsetbin);
	elseif rmsonsetbin == 0
		rmsonsetbin = 1;
		onsettime = t_rms(1);
		rmsonsetval = av(rmsonsetbin);
	end
	% plot onset
	hold on
		plot(t_rms(rmsonsetbin), rmsonsetval, 'm*', 'MarkerSize', 9)
		onPlot = plot(onsettime, rmsonsetval, 'k*', 'MarkerSize', 9);
	hold off
	legend('wav', 'rms', 'rmsavg', 'rmson', 'onset')
	drawnow
	
	if userconfirm
		% check with user
		qopts = struct('Default', 'No', 'Interpreter', 'none');
% 		ptopts = struct('Resize', 'on', 'WindowStyle', 'normal', 'Interpreter', 'none');
		butt = 'No';
		while strcmpi(butt, 'No')

			butt = questdlg(	'Accept Onset?', ...
									'Find onset', ...
									'Yes', 'No', ...
									qopts);
			if strcmpi(butt, 'No')
				tmpcell = inputdlg('onset (ms)', 'New Onset', 1, {num2str(onsettime)});
				if isempty(tmpcell)
					newval = onsettime;
				else
					newval = str2num(tmpcell{1}); %#ok<ST2NM>
				end
				if between(newval, 0, max(t_wav))
					delete(onPlot);
					onsettime = newval;
					rmsonsetval = av(t_rms==onsettime);
					try
						hold on
						onPlot = plot(onsettime, rmsonsetval, 'k*', 'MarkerSize', 9);
						hold off
					catch
						debug
						
					end
				else
					errdlg('Invalid onset', 'find onset')
					butt = 'No';
				end
			end
		end
	end
	
	% return onset bin
	out =  ms2bin(onsettime, Fs);
end


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function out = drmsdt_onset(wav, Fs, userconfirm, rmswin_ms, ...
														meanwin, threshold, ptitle)
%--------------------------------------------------------------------------
	% plot signal in blue
	figure(314);
	dt = (1/Fs);
	t_wav = 1000 * dt * ( 0:(length(wav) - 1) );
	plot(t_wav, wav, 'b.');
	title(ptitle, 'Interpreter', 'none')
	grid on

	% compute rms of signal in blocks, then plot it in green
	wavrms = block_rms(wav, ms2bin(rmswin_ms, Fs));
	t_rms = rmswin_ms * (0:(length(wavrms) - 1));
	hold on
		plot(t_rms, wavrms, 'g');
	hold off

	% compute 1st derivative of rms
	dwavrmsdt = diff(wavrms) ./ rmswin_ms;
	dwavrmsdt = [dwavrmsdt(1); dwavrmsdt];

	% find first avg derivative value above threshold
	rmsonsetbin = 0;
	rmsonsetval = [];
	av = zeros(length(t_rms), 1);
	for n = 1:(length(t_rms) - meanwin)
		av(n) = mean(dwavrmsdt(n:(n+meanwin)));
		hold on
			plot(t_rms(n), av(n), 'r+')
		hold off
		if (rmsonsetbin == 0) && (av(n) > threshold)
			rmsonsetbin = n;
			rmsonsetval = av(n);
		end
	end
	if rmsonsetbin == 0
		rmsonsetbin = 1;
		onsettime = t_rms(rmsonsetbin);
		rmsonsetval = av(rmsonsetbin);
	else
		% check onset
		onsettime = t_rms(rmsonsetbin)-(meanwin*rmswin_ms);
	end
	if onsettime < 0
		onsettime = t_rms(rmsonsetbin);
	elseif rmsonsetbin == 0
		rmsonsetbin = 1;
		onsettime = t_rms(1);
		rmsonsetval = av(rmsonsetbin);
	end
	% plot onset
	hold on
		plot(t_rms(rmsonsetbin), rmsonsetval, 'm*', 'MarkerSize', 9)
		onPlot = plot(onsettime, rmsonsetval, 'k*', 'MarkerSize', 9);
	hold off
	drawnow
	
	if userconfirm
		% check with user
		qopts = struct('Default', 'No', 'Interpreter', 'none');
% 		ptopts = struct('Resize', 'on', 'WindowStyle', 'normal', 'Interpreter', 'none');
		butt = 'No';
		while strcmpi(butt, 'No')

			butt = questdlg(	'Accept Onset?', ...
									'Find onset', ...
									'Yes', 'No', ...
									qopts);
			if strcmpi(butt, 'No')
				tmpcell = inputdlg('onset (ms)', 'New Onset', 1, {num2str(onsettime)});
				if isempty(tmpcell)
					newval = onsettime;
				else
					newval = str2num(tmpcell{1}); %#ok<ST2NM>
				end
				if between(newval, 0, max(t_wav))
					delete(onPlot);
					onsettime = newval;
					rmsonsetval = av(t_rms==onsettime);
					try
						hold on
						onPlot = plot(onsettime, rmsonsetval, 'k*', 'MarkerSize', 9);
						hold off
					catch
						debug
						
					end
				else
					errdlg('Invalid onset', 'find onset')
					butt = 'No';
				end
			end
		end
	end
	
	% return onset bin
	out =  ms2bin(onsettime, Fs);
end