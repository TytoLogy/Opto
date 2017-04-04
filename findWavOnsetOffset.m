% function out = findWavOnsetOffset(varargin)
%--------------------------------------------------------------------------
% out = findWavOnsetOffset(varargin)
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

load('wavinfo.mat');
tmp = wavInfo(6);
wav = audioread(tmp.Filename);

figure(314)
dt = (1/tmp.SampleRate);
t_wav = 1000 * dt * ( 0:(tmp.TotalSamples - 1) );
plot(t_wav, wav, 'b.');

rmswin_ms = 0.1;

wavrms = block_rms(wav, ms2bin(rmswin_ms, tmp.SampleRate));
t_rms = rmswin_ms * (0:(length(wavrms) - 1));

dwavrmsdt = diff(wavrms) ./ rmswin_ms;
dwavrmsdt = [dwavrmsdt(1); dwavrmsdt];

hold on
plot(t_rms, wavrms, 'g');
plot(t_rms, dwavrmsdt, 'r');
hold off

meanwin = 5;
rmsonsetbin = 0;
rmsonsetval = [];
av = zeros(length(t_rms), 1);
for n = 1:(length(t_rms) - meanwin)
	av(n) = mean(dwavrmsdt(n:(n+meanwin)));
	hold on
		plot(t_rms(n), av(n), 'r+')
	hold off
	if (rmsonsetbin == 0) && (av(n) > 0.1)
		rmsonsetbin = n;
		rmsonsetval = av(n);
	end
end

onsettime = t_rms(rmsonsetbin)-(meanwin*rmswin_ms);
if onsettime < 0
	onsettime = t_rms(rmsonsetbin);
elseif rmsonsetbin == 0
	rmsonsetbin = 1;
	onsettime = t_rms(1);
end

hold on
	plot(t_rms(rmsonsetbin), rmsonsetval, 'm*', 'MarkerSize', 9)
	onPlot = plot(onsettime, rmsonsetval, 'k*', 'MarkerSize', 9);
hold off

qopts = struct('Default', 'No', 'Interpreter', 'none');
ptopts = struct('Resize', 'on', 'WindowStyle', 'normal', 'Interpreter', 'none');

butt = 'No';
while strcmpi(butt, 'No')

	butt = questdlg(	'Accept Onset?', ...
							'Find onset', ...
							'Yes', 'No', ...
							qopts);
	tmpcell = inputdlg('onset (ms)', 'New Onset', 1, {num2str(onsettime)});
	if isempty(tmpcell)
		newval = onsettime;
	else
		newval = str2num(tmpcell{1});
	end
	if between(newval, 0, max(t_wav))
		delete(onPlot);
		hold on
			onsettime = newval;
			rmsonsetval = av(t_rms==onsettime);
			onPlot = plot(onsettime, rmsonsetval, 'k*', 'MarkerSize', 9);
		hold off
		butt = questdlg(	'Accept Onset?', ...
							'Find onset', ...
							'Yes', 'No', ...
							qopts);	
	else
		errdlg('Invalid onset', 'find onset')
		butt = 'No';
	end
end
