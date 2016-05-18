% indev frequency (Hz) = 48828.125
% outdev frequency (Hz) = 195312.5

%% configure structs
% lock file
config.TDTLOCKFILE = fullfile(pwd, 'tdtlockfile.mat');
config.CONFIGNAME = 'RZ6OUT200K_RZ5DIN';
% function handles
config.ioFunc = @opto_io;
config.TDTsetFunc = @TDT_opto_settings;
config.setattenFunc = @RZ6setatten;
% input device
config.indev.hardware = 'RZ5D';
config.indev.Fs = 50000;
config.indev.Circuit_Path = 'C:\TytoLogy\Toolboxes\TDTToolbox\Circuits\RZ5D';
config.indev.Circuit_Name = 'RZ5D_50k_16In_1Out_zBus.rcx';
config.indev.Dnum = 1; % device number
% output device
config.outdev.hardware = 'RZ6';
config.outdev.Fs = 200000;
config.outdev.Circuit_Path = 'C:\TytoLogy\Toolboxes\TDTToolbox\Circuits\RZ6'; 
config.outdev.Circuit_Name = 'RZ6_2ChannelOutputAtten_zBus.rcx';
config.outdev.Dnum = 1; % device number


% -- TDT parameters
% tdt = FOCHS_init('TDT:PARAMS');
tdt.AcqDuration = 1000;
tdt.SweepPeriod = tdt.AcqDuration + 10;
tdt.TTLPulseDur = 1;
tdt.CircuitGain = 20000;      % gain for TDT circuit
tdt.MonitorGain = 20000;
tdt.HPEnable = 1;         % enable high pass filter
tdt.HPFreq = 100;         % high pass frequency
tdt.LPEnable = 1;         % enable low pass filter
tdt.LPFreq = 10000;       % low pass frequency

% -- animal info
%animal = FOCHS_init('ANIMAL');
animal.Animal = '000';
animal.Unit = '0';
animal.Rec = '0';
animal.Date = TytoLogy_datetime('date');
animal.Time = TytoLogy_datetime('time');
animal.Pen = '0';
animal.AP = '0';
animal.ML = '0';
animal.Depth = '0';
animal.comments = '';

% stimulus = FOCHS_init('STIMULUS:PARAMS');
stimulus.ISI = 500;
stimulus.Duration = 200;
stimulus.Delay = 100;
stimulus.Ramp = 5;
stimulus.RadVary = 0;
stimulus.Frozen = 0;

% tone stimulus
tone.frequency = 5000;
tone.amplitude = 1;

% -- TDT I/O channels ---- default TDT hardware = 'NO_TDT'
% channels = FOCHS_init('CHANNELS:RZ6_RZ5D');
channels.OutputChannelL = 1;
channels.OutputChannelR = 2;
channels.nInputChannels = 16;
channels.InputChannels = 1:channels.nInputChannels;
channels.OpticalChannel = 10;
channels.MonitorChannel = 1;
channels.MonitorOutputChannel = 9; 

% -- parameters for optical stimulus
% optical = FOCHS_init('OPTICAL');
optical.Enable = 1;
optical.Amp = 1000;
optical.Dur = 100;
optical.Delay = 100;
optical.Channel = 10;	% note that this is also set in RZ6+RZ5D

%% start TDT hardware
try
	[outhandles, outflag] = opto_TDTopen(config); %#ok<ASGLU>
catch ME
	disp(ME.identifier)
	disp(ME.message)
	error('Cannot open TDT hardware');
end
indev = outhandles.indev;
outdev = outhandles.outdev;
zBUS = outhandles.zBUS;
PA5L = outhandles.PA5L;
PA5R = outhandles.PA5R;

%% settings
% FOCHS_RZ6RZ5Dsettings() passes settings from the device, tdt, stimulus,
% channels and optical structs on to tags in the running TDT circuits
% Fs is a 1X2 array of sample rates for indev and outdev - this is because
% the actual sample rates often differ from those specified in the software
% settings due to clock frequency divisor issues
Fs = opto_TDTsettings(indev, outdev, tdt, stimulus, channels, optical);

%% do stuff

% frequencies to play out
freqs = 440 * [1 2 3 4];
% number of reps per stimulus
nreps = 1;

% turn on audio monitor for spikes using software trigger 1
RPtrig(indev, 1);

%%
% calculate # of points to acquire (in units of samples)
inpts = ms2bin(tdt.AcqDuration, indev.Fs);

% generate figure
fH = figure;
ax = axes;
xv = linspace(0, tdt.AcqDuration, inpts);
xlim([0, inpts]);
yabsmax = 5;

tmpData = zeros(inpts, channels.nInputChannels);
for n = 1:channels.nInputChannels
	tmpData(:, n) = n*(yabsmax) + 2*(2*rand(inpts, 1)-1);
end
pH = plot(ax, xv, tmpData);

yticks_yvals = yabsmax*(1:channels.nInputChannels);
yticks_txt = cell(channels.nInputChannels, 1);
for n = 1:channels.nInputChannels
	yticks_txt{n} = num2str(n);
end

ylim(yabsmax*[0 channels.nInputChannels+1]);
set(ax, 'YTick', yticks_yvals);
set(ax, 'YTickLabel', yticks_txt);
set(ax, 'TickDir', 'out');
set(ax, 'Box', 'off');
%%

% main loop
pause(0.001*stimulus.ISI);
for f = 1:length(freqs)

	% generate [2XN] stimulus array. row 1 == output A on RZ6, row 2 = output B
	stim = synmonosine(stimulus.Duration, outdev.Fs, freqs(f), tone.amplitude, 0);
	stim = sin2array(stim, 1, outdev.Fs);
	nullstim = syn_null(stimulus.Duration, outdev.Fs, 0);
	S = [stim; nullstim];


	% Set attenuation levels
	RPsettag(outdev, 'AttenL', 0);
	RPsettag(outdev, 'AttenR', 120);
	% make sure mute is off
	RPsettag(outdev, 'Mute', 0);

	for n = 1:nreps
		% play stimulus, return read values
		if indev.status && outdev.status && zBUS.status
			[mcresp, mcpts] = opto_io(S, inpts, indev, outdev, zBUS);
		else
			error('stati == 0');
		end

		% plot returned values
		
		[resp, npts] = mcFastDeMux(mcresp, channels.nInputChannels);

		for c = 1:channels.nInputChannels
			set(pH(c), 'YData', resp(:, c) + c*yabsmax);
		end
		title(sprintf('Freq: %.2f, Rep: %d', freqs(f), n))
		
		drawnow

		pause(0.001*stimulus.ISI)
	end
end

% turn off audio monitor for spikes using software trigger 2
RPtrig(indev, 2);

%% stop TDT hardware
[outhandles, outflag] = opto_TDTclose(config, indev, outdev, zBUS, PA5L, PA5R);
indev = outhandles.indev;
outdev = outhandles.outdev;
zBUS = outhandles.zBUS;
PA5L = outhandles.PA5L;
PA5R = outhandles.PA5R;



