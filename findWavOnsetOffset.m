function out = findWavOnsetOffset(wav, Fs, varargin)
%--------------------------------------------------------------------------
% out = findWavOnsetOffset(wav, Fs, threshold, rmswin_ms, meanwin)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
% Input Arguments:
%
% Output Arguments:
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

				otherwise
					error('%s: Unknown option %s', mfilename, varargin{aindex});
			end
		end
	end

	%------------------------------------------------------------------------
	% find onset
	%------------------------------------------------------------------------
	onset = rmsonset(wav, Fs, userconfirm, rmswin_ms, meanwin, ...
																		threshold, 'ONSET');
	%------------------------------------------------------------------------
	% find offset
	%------------------------------------------------------------------------
	% flip wav around
	if isrow(wav)
		wav = fliplr(wav);
	else
		wav = flipud(wav);
	end
	% then use "onset" to find offset
	tmp = rmsonset(wav, Fs, userconfirm, rmswin_ms, meanwin, ...
																		threshold, 'OFFSET');
	% subtract from total length to give offset
	offset = length(wav) - tmp;
	% build output
	out = [onset offset];
	
end	% END of findWavOnset

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function out = rmsonset(wav, Fs, userconfirm, rmswin_ms, ...
														meanwin, threshold, ptitle)
%--------------------------------------------------------------------------
	% plot signal
	figure(314);
	dt = (1/Fs);
	t_wav = 1000 * dt * ( 0:(length(wav) - 1) );
	plot(t_wav, wav, 'b.');
	title(ptitle)

	% compute rms of signal in blocks, then plot it
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
					hold on
						onPlot = plot(onsettime, rmsonsetval, 'k*', 'MarkerSize', 9);
					hold off
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