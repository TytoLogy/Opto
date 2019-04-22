function out = drmsdt_onset(wav, Fs, userconfirm, rmswin_ms, ...
														meanwin, threshold, ptitle, ...
														varargin)
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% setup plot
if isempty(varargin)
	figure(314);
	ax = gca;
else
	ax = varargin{1};
end
% signal color
sigCol = 0.4*[1 1 1];

% plot signal in black
dt = (1/Fs);
t_wav = 1000 * dt * ( 0:(length(wav) - 1) );
plot(ax, t_wav, wav, 'Color', sigCol);
title(ax, ptitle, 'Interpreter', 'none')
grid(ax);
grid(ax, 'Minor');

% compute rms of signal in blocks, then plot it in blue
wavrms = block_rms(wav, ms2bin(rmswin_ms, Fs));
t_rms = rmswin_ms * (0:(length(wavrms) - 1));
hold on
	plot(ax, t_rms, wavrms, 'b');
hold off

% compute 1st derivative of rms
dwavrmsdt = diff(wavrms) ./ rmswin_ms;
% add point to compensate for diff offset
dwavrmsdt = [dwavrmsdt(1); dwavrmsdt];

% find first avg derivative value above threshold
rmsonsetbin = 0;
rmsonsetval = [];
av = zeros(length(t_rms), 1);
for n = 1:(length(t_rms) - meanwin)
	av(n) = mean(dwavrmsdt(n:(n+meanwin)));
	if (rmsonsetbin == 0) && (av(n) > threshold)
		rmsonsetbin = n;
		rmsonsetval = av(n);
	end
end
% plot averaged block values as red dots
hold on
	plot(ax, t_rms, av, 'r.', 'MarkerSize', 6)
hold off

% check if threshold was never crossed (rmsonsetbin equal to 0)
if rmsonsetbin == 0
	% if so, set to 1, get values for this
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
	plot(ax, t_rms(rmsonsetbin), rmsonsetval, 'm+', 'MarkerSize', 9);
	onPlot = plot(ax, onsettime, rmsonsetval, 'g*', 'MarkerSize', 10);
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
					onPlot = plot(ax, onsettime, rmsonsetval, 'g*', 'MarkerSize', 10);
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
