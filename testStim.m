%------------------------------------------------------------------
% Script to test stimuli
%------------------------------------------------------------------
% - will use Calibration IO circuit and function
%------------------------------------------------------------------

%------------------------------------------------------------------
%------------------------------------------------------------------
% Setup
%------------------------------------------------------------------
%------------------------------------------------------------------

%------------------------------------------------------------------
% some constants/definitions
%------------------------------------------------------------------
MAX_ATTEN = 120;	% maximum attenuation in RZ6
L = 1;
R = 2;

%------------------------------------------------------------------
% Load Calibration Data
%------------------------------------------------------------------
% test.calpath = 'C:\TytoLogy\Experiments\WAVs';
% test.calfile = 'LCY-C-4K-100K-1V-20dBatten_29May19.cal';
test.calpath = 'C:\TytoLogy\Experiments\Opto\Tests';
% test.calfile = '7Jun2019_KrohnHite70kHzLP_Fake.mat';
% test.calfile = '10Jun2019_LCY-C_LowFreqTest_cal.mat';
test.calfile = '10Jun2019_LCY-C_Test_cal.mat';
cfile = fullfile(test.calpath, test.calfile);
if ~exist(cfile, 'file')
	error('%s: Calibration file %s not found!', mfilename, ...
						cfile);
else
	% load the calibration data
	fprintf('Loading calibration data from %s\n', cfile);
	caldata = load_cal_and_smooth(cfile, 5);
end
% Plot Calibration Data
figure
plot(caldata.freq, caldata.mag(1, :), 'k.-', ...
	caldata.freq, db(caldata.maginv(1, :)), 'b.-');
grid on
legend('mag', 'corr mag');

%------------------------------------------------------------------
% Calibration Test Settings
%------------------------------------------------------------------
fprintf('Test settings\n');
% % use defaults from Calibrate as a start
% test = Calibrate_init('INIT_ULTRA');

%--------------------------------------------
% modify as needed !!!
%--------------------------------------------

%--------------------------------------------
% broadband noise parameters
%--------------------------------------------
test.noise.Fmin = 4000;
test.noise.Fmax = 95000;
%--------------------------------------------
% tone parameters
%--------------------------------------------
test.tone.Frequency = 1000*[5 10 30 50 90];

%--------------------------------------------
% Common settings for stimuli
%		this could be set for noise and tones individually, but for now use
%		common value for both.
%--------------------------------------------
test.Duration = 150;
test.Delay = 10;
test.Ramp = 5;
% # of times to repeat stimuli
test.Reps = 3;
% target dB SPL level for stimuli
test.Level = 50;
% output voltage level for stimuli
test.DAlevel = 1;

% % Microphone Settings
% test.MicGainL_dB = 0;
% test.MicGainR_dB = 0;
% test.MicSenseL = 1;
% test.MicSenseR = 1;
% test.frfileL = [];
% test.frfileR = [];
% test.UseFR = 1;

%--------------------------------------------
% Sweep & DAQ settings
%--------------------------------------------
% time (ms) to pause between each presentation
test.ISI = 100; 
% time to acquire data
test.AcqDuration = 200;
% this is needed by TDT circuit
test.SweepPeriod = test.AcqDuration + 10;
% trigger output pulse duration in ms (usually can leave this alone)
test.TTLPulseDur = 1;
% Filter settings - frequency in Hz
test.HPFreq = 3800;
test.LPFreq = 97000;


%--------------------------------------------
% Microphone and conversion to dB settings
%	Note that cal.Fs will need to be reset once TDT hardware is initialized
%--------------------------------------------
% microphone sensitivity (Volts/Pascal)
test.RefMicSens = 0.316;
% gain on mic amp
test.MicGain_dB = 0;
% pre-compute some conversion factors:
% Volts to Pascal converstion factor = 1/RefMicSense
test.VtoPa = test.RefMicSens.^-1;
% mic gain factor
test.MicGain = 10.^(test.MicGain_dB./20);

%------------------------------------------------------------------
% Copy wav info from MTwav_settings (6/7/2019)
%------------------------------------------------------------------
% run C:\TytoLogy\Experiments\Opto\Scripts\MTwav_settings;
test.wav.WavPath = 'C:\TytoLogy\Experiments\WAVs';
% names of wav files to use as stimuli
test.wav.WavesToPlay = {	
'1StepUSVMating_adj.wav', ...
'2StepUSVMating_adj.wav', ...
'ChevronMating_adj.wav', ...
'ChevronwNLsMating_adj.wav', ...
'FlatMating_adj.wav', ...
'LFHMating_adj.wav', ...
'MFVtonalRestraint_adj.wav', ...
'MFVwHarmonicsRestraint_adj.wav', ...
'MFVwNLsRestraint_adj.wav', ...
'Noisy_adj.wav' ...
};
% # of wavs to play
test.wav.nWavs = length(test.wav.WavesToPlay);
% and scaling factors (to achieve desired amplitude)
% % % temporarily use 1 as scaling factor - fix after calibration!!!
test.wav.WavScaleFactors = ones(test.wav.nWavs, 1);
% max level achievable at given scale factor 
% (determined using FlatWav program)
test.wav.WavLevelAtScale = [	
	90.24, ...
	91.14, ...
	88.18, ...
	85.41, ...
	90.12, ...
	106.32, ...
	97.46, ...
	108.16, ...
	92.6, ...
	99.96 ...
];
% onset, offset wav ramp duration (aka tapers)
test.wav.WavRamp = 10;
% construct wavInfo struct "database" for desired wav stimuli
[test.wav.wavInfo, tmpWavFile] = opto_create_wav_stimulus_info( ...
														test.wav.WavPath, ...
														test.wav.WavesToPlay, ...
														test.wav.WavScaleFactors, ...
														test.wav.WavLevelAtScale);

%------------------------------------------------------------------
% Hardware Settings
%------------------------------------------------------------------
% use Calibrate_init to get settings, using RZ6_200K
TDT = Calibrate_init('RZ6_200K');


%------------------------------------------------------------------
%------------------------------------------------------------------
%% Initialize Hardware
%------------------------------------------------------------------
%------------------------------------------------------------------

%------------------------------------------------------------------
% Initialize the TDT devices
%------------------------------------------------------------------
% display message
fprintf('Initializing TDT\n')
% make iodev structure
iodev.Circuit_Path = TDT.Circuit_Path;
iodev.Circuit_Name = TDT.Circuit_Name;
iodev.Dnum = TDT.Dnum; 
% initialize RX* 
tmpdev = TDT.RXinitFunc('GB', TDT.Dnum); 
iodev.C = tmpdev.C;
iodev.handle = tmpdev.handle;
iodev.status = tmpdev.status;
% initialize attenuators
if strcmpi(TDT.AttenMode, 'PA5')
	% initialize PA5 attenuators (left = 1 and right = 2)
	PA5L = TDT.PA5initFunc('GB', 1);
	PA5R = TDT.PA5initFunc('GB', 2);
end
% load circuit
iodev.rploadstatus = TDT.RPloadFunc(iodev); 
% start circuit
TDT.RPrunFunc(iodev);
% check status
iodev.status = TDT.RPcheckstatusFunc(iodev);
% Query the sample rate from the circuit 
iodev.Fs = TDT.RPsamplefreqFunc(iodev);
% store in test struct
test.Fs = iodev.Fs;

%------------------------------------------------------------------
% Set up TDT parameters
%------------------------------------------------------------------
TDT.TDTsetFunc(iodev, test); 

%------------------------------------------------------------------
% Set up filtering
%------------------------------------------------------------------
% update bandpass filter for processing the data
% Nyquist frequency
fnyq = iodev.Fs / 2;
% passband definition
fband = [test.HPFreq test.LPFreq] ./ fnyq;
% filter coefficients using a 3rd order Butterworth bandpass filter
[fcoeffb, fcoeffa] = butter(3, fband, 'bandpass');

%------------------------------------------------------------------
% set the start and end bins for the calibration
% ignore onset/offset ramps for calculation of rms and db SPL
%------------------------------------------------------------------
% io function overrides Delay setting to 0 so this is no longer correct
% start_bin = ms2bin(test.Delay + test.Ramp, iodev.Fs);
start_bin = ms2bin(test.Ramp, iodev.Fs);
if start_bin < 1
	start_bin = 1;
end
end_bin = start_bin + ms2bin(test.Duration - 2*test.Ramp, iodev.Fs);
zerostim = syn_null(test.Duration, iodev.Fs, 1);  % make zeros for both channels
outpts = length(zerostim);
acqpts = ms2bin(test.AcqDuration, iodev.Fs);

%------------------------------------------------------------------
%------------------------------------------------------------------
%% Do things
%------------------------------------------------------------------
%------------------------------------------------------------------

%------------------------------------------------------------------
%% test noise using example from Calibrate_test
%------------------------------------------------------------------
% synthesize noise
% stim = synmonosine(cal.Duration, iodev.Fs, freq, caldata.DAscale, caldata);
% stim = synmononoise_fft(	test.Duration, ...
% 									iodev.Fs, ...
% 									test.noise.Fmin, ...
% 									test.noise.Fmax, ...
% 									1, ...
% 									caldata);

test.Level = 80;
stim = synmononoise_fft(test.Duration, iodev.Fs, 4000, 90000, 1, caldata);
% normalize and scale data
stim = caldata.DAscale * normalize(stim);
% stim = caldata.DAscale * (stim);
S = zeros(2, length(stim));
S(1, :) = stim;
S = sin2array(S, test.Ramp, iodev.Fs);
fftdbmagplot(S(1, :), iodev.Fs, figure(11));
% plot the stim array
tvec = (1000/iodev.Fs).*(0:(acqpts-1));
stimvecP = 0 * tvec;
delay_samples = ms2bin(test.Delay, test.Fs);
duration_samples = ms2bin(test.Duration, test.Fs);
% this was original code, but RZ6calibration_io sets delay to 0...
% stimvecP( (delay_samples + 1) : (delay_samples + duration_samples) ) = ...
% 						S(1, :);
% updated
stimvecP(1:duration_samples) = S(1, :);
figure(10);
subplot(311);
plot(tvec, stimvecP);
ylabel('stim');
% figure out attenuation value 
stim_rms = rms(stim);
% current figure_mono_atten_noise algorithm
atten_val = [figure_mono_atten_noise(test.Level, stim_rms, caldata) ...
					MAX_ATTEN];
% other
% atten_val = [caldata.mindbspl(1) + db(caldata.cal.VtoPa(1)*stim_rms) - test.Level ...
% 							MAX_ATTEN];
% atten_val = [caldata.mindbspl(1) + dbspl(caldata.cal.VtoPa(1)*stim_rms) - test.Level ...
% 	MAX_ATTEN];
% atten_val = [ (dbspl(caldata.cal.VtoPa(1)*stim_rms) - test.Level) ...
% 	MAX_ATTEN];
% atten_val = [ (dbspl(caldata.VtoPa(1)*stim_rms) - test.Level) ...
% 	MAX_ATTEN];

% simple
% atten_val = [caldata.mindbspl(1) - test.Level ...
% 					MAX_ATTEN];
fprintf('rms: %.4f\tmax: %.4f\tpred max output: %.2f\tatten: %.2f\n', ...
					stim_rms, max(stim), dbspl(caldata.VtoPa(1)*stim_rms), atten_val(1));


% set attenuation 
TDT.setattenFunc(iodev, atten_val);

% play the sound;
[resp, rate] = TDT.ioFunc(iodev, S, acqpts);
% filter raw data
resp{1} = filtfilt(fcoeffb, fcoeffa, sin2array(resp{1}, 1, iodev.Fs));
% plot the response
subplot(312)
plot(tvec, resp{1}, 'g');
ylabel('resp (V)');
% determine the magnitude of the response/leak
pmag = rms(resp{1}(start_bin:end_bin));
% adjust for the gain of the preamp (for non-calibration mics, this is
% inaccurate!!!!!)
pmag = pmag / test.MicGain;
% store the data in arrays
noisemags = dbspl( test.VtoPa * pmag );
% show calculated values
fprintf('resp rms: %.4f dbSPL: %.4f\n', pmag, dbspl(test.VtoPa*pmag));
% plot signal and dB - use stimulus duration as rms window
dbAx = subplot(313);
[~, ~, test.rVals] = plotSignalAnddB(resp{1}, test.Duration, test.Fs, ...
													'dBSPL', test.VtoPa, ...
													'signalname', 'noise', ...
													'axes', dbAx);

fftdbmagplot(	sin2array(resp{1}(1:ms2bin(test.Duration, iodev.Fs)), ...
																		1, iodev.Fs), ...
				iodev.Fs, figure(12));
			

						
%------------------------------------------------------------------
%% test tones using example from Calibrate_test
%------------------------------------------------------------------
test.Level = 70;
ntones = length(test.tone.Frequency);
tonemags = zeros(ntones, 1);
% loop through frequencies
for fIndx = 1:ntones
	Frequency = test.tone.Frequency(fIndx);
	% synthesize tone
	stim = synmonosine(test.Duration, iodev.Fs, Frequency, caldata.DAscale, caldata, 0);
	S = zeros(2, length(stim));
	S(1, :) = stim;
	S = sin2array(S, test.Ramp, iodev.Fs);
	fftdbmagplot(S(1, :), iodev.Fs, figure(11));
	% plot the stim array
	tvec = (1000/iodev.Fs).*(0:(acqpts-1));
	stimvecP = 0 * tvec;
	delay_samples = ms2bin(test.Delay, test.Fs);
	duration_samples = ms2bin(test.Duration, test.Fs);
	% this was original code, but RZ6calibration_io sets delay to 0...
	% stimvecP( (delay_samples + 1) : (delay_samples + duration_samples) ) = ...
	% 						S(1, :);
	% updated
	stimvecP(1:duration_samples) = S(1, :);
	figure(10);
	subplot(311);
	plot(tvec, stimvecP);
	ylabel('stim');
	% figure out attenuation value 
	stim_rms = rms(stim);
	atten_val = [figure_mono_atten_tone(test.Level, stim_rms, caldata) ...
						MAX_ATTEN];
	fprintf('rms: %.4f\tmax: %.4f\tpred max output: %.2f\tatten: %.2f\n', ...
						stim_rms, max(stim), dbspl(caldata.VtoPa(1)*stim_rms), atten_val(1));


	% set attenuation 
	TDT.setattenFunc(iodev, atten_val);

	% play the sound;
	[resp, rate] = TDT.ioFunc(iodev, S, acqpts);
	% filter raw data
	resp{1} = filtfilt(fcoeffb, fcoeffa, sin2array(resp{1}, 1, iodev.Fs));
	% plot the response
	subplot(312)
	plot(tvec, resp{1}, 'g');
	ylabel('resp (V)');
	% determine the magnitude of the response/leak
	pmag = rms(resp{1}(start_bin:end_bin));
	% adjust for the gain of the preamp (for non-calibration mics, this is
	% inaccurate!!!!!)
	pmag = pmag / test.MicGain;
	% store the data in arrays
	tonemags(fIndx) = dbspl( test.VtoPa * pmag );
	% show calculated values
	fprintf('resp rms: %.4f dbSPL: %.4f\n', pmag, dbspl(test.VtoPa*pmag));
	% plot signal and dB - use stimulus duration as rms window
	dbAx = subplot(313);
	[~, ~, test.rVals] = plotSignalAnddB(resp{1}, test.Duration, test.Fs, ...
									'dBSPL', test.VtoPa, ...
									'signalname', sprintf('%dkHz', 0.001*Frequency), ...
									'axes', dbAx);

	fftdbmagplot(	sin2array(resp{1}(1:ms2bin(test.Duration, iodev.Fs)), ...
																			1, iodev.Fs), ...
					iodev.Fs, figure(12));
	pause(test.ISI * 0.001);
end

%------------------------------------------------------------------
%% test WAVS
%------------------------------------------------------------------
% process wavs
if ~isfield(test.wav, 'wavS0')
	test.wav = condition_wavs(test.wav, iodev.Fs);
end
%%
test.Level = 50;
wavresps = cell(test.wav.nWavs, 1);
wavmags = zeros(test.wav.nWavs, 1);


% loop through wavs
for wIndx = 1:test.wav.nWavs
	% synthesize tone
	stim = test.wav.wavS0{wIndx};
	S = zeros(2, length(stim));
	S(1, :) = stim;
	fftdbmagplot(S(1, :), iodev.Fs, figure(11));
	% get acq duration
	acqdur = ceil(bin2ms(length(stim), iodev.Fs)/50)*50;
	acqpts = ms2bin(acqdur, iodev.Fs);

	% plot the stim array
	tvec = (1000/iodev.Fs).*(0:(acqpts-1));
	stimvecP = 0 * tvec;
	delay_samples = ms2bin(test.Delay, test.Fs);
	duration_samples = length(stim);
	% this was original code, but RZ6calibration_io sets delay to 0...
	% stimvecP( (delay_samples + 1) : (delay_samples + duration_samples) ) = ...
	% 						S(1, :);
	% updated
	stimvecP(1:duration_samples) = S(1, :);
	figure(10);
	subplot(311);
	plot(tvec, stimvecP);
	ylabel('stim');
	% figure out attenuation value 
	stim_rms = rms(stim);
	atten_val = [test.wav.WavLevelAtScale(wIndx) - test.Level ...
						MAX_ATTEN];
	fprintf('rms: %.4f\tmax: %.4f\tpred max output: %.2f\tatten: %.2f\n', ...
						stim_rms, max(stim), dbspl(caldata.VtoPa(1)*stim_rms), atten_val(1));
	
	% set attenuation 
	TDT.setattenFunc(iodev, atten_val);

	% play the sound;
	[resp, rate] = TDT.ioFunc(iodev, S, acqpts);
	% filter raw data
	resp{1} = filtfilt(fcoeffb, fcoeffa, sin2array(resp{1}, 1, iodev.Fs));
	% plot the response
	subplot(312)
	plot(tvec, resp{1}, 'g');
	ylabel('resp (V)');
	% determine the magnitude of the response/leak
	pmag = rms(resp{1});
	% adjust for the gain of the preamp (for non-calibration mics, this is
	% inaccurate!!!!!)
	pmag = pmag / test.MicGain;
	% store the data in arrays
	wavmags(wIndx) = dbspl( test.VtoPa * pmag );
	% show calculated values
	fprintf('resp rms: %.4f dbSPL: %.4f\n', pmag, dbspl(test.VtoPa*pmag));
	% plot signal and dB - use stimulus duration as rms window
	dbAx = subplot(313);
	[~, ~, test.wav.rVals(wIndx)] = plotSignalAnddB(resp{1}, 5, test.Fs, ...
									'dBSPL', test.VtoPa, ...
									'signalname', test.wav.WavesToPlay{wIndx}, ...
									'axes', dbAx);

	fftdbmagplot(	sin2array(resp{1}, 1, iodev.Fs), ...
					iodev.Fs, figure(12));
	wavresps{wIndx} = resp{1};
	pause(test.ISI * 0.001);
end

[test.wav.rVals.dB_max]



%------------------------------------------------------------------
%------------------------------------------------------------------
%% Shut down hardware
%------------------------------------------------------------------
%------------------------------------------------------------------
fprintf('%s: closing TDT hardware\n', mfilename)
if strcmpi(TDT.AttenMode, 'PA5')
	TDT.PA5closeFunc(PA5L);
	TDT.PA5closeFunc(PA5R);
end
try
	errVal = TDT.RPcloseFunc(iodev);
catch errME
	warning('%s: error closing TDT system', mfilename);
	rethrow(errME);
end

