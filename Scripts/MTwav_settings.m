%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Experiment settings
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% %%% EDIT THESE TO CHANGE EXPERIMENTAL PARAMETERS (reps, ISI, etc.) %%%%
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%-------------------------------------------------------------------------
%----------------------------------------------------------
% Presentation settings - ISI, # reps, randomize, etc.
%	Note that Randomize in this context will mean a 
%	blocked randomization, e.g., random sequence of each stimulus
%	without repeats for 1 rep, then another, then .... etc.
%----------------------------------------------------------
test.Reps = 10;
test.Randomize = 1;
test.Block = 0;
audio.ISI = 100;
%------------------------------------
% Experiment settings
%------------------------------------
% save output stimuli? (0 = no, 1 = yes)
test.saveStim = 0;
% stimulus levels to test
% !!! note that levels for individual stimulus types set below are
% overridden by these values
test.Level = [20 40 60 70];
% use null stim?
test.NullStim = 1;
% use Noist stim?
test.NoiseStim = 1;
%------------------------------------
% acquisition/sweep settings
% will have to be adjusted to deal with wav file durations
%------------------------------------
test.AcqDuration = 400;
test.SweepPeriod = test.AcqDuration + 5;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% define stimulus (optical, audio) structs
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%------------------------------------
% OPTICAL settings
%	Enable	0 -> optical stim OFF, 1 -> optical stim ON
%	Delay		onset of optical stim from start of sweep (ms)
% 	Dur		duration (ms) of optical stimulus
% 	Amp		amplitude (mV) of optical stim
% 					*** IMPORTANT NOTE ***
% 					This method of amplitude control will only work with the 
% 					Thor Labs fiber-coupled LED driver.
% 					For the Shanghai Dream Laser, output level can only be 
% 					controlled using the rotary potentiometer on the Laser power
% 					supply. If using the Shanghai Dream Laser for stimulation,
% 					set Amp to 5000 millivolts (5 V)
% 
% 	To test a range of values (for Delay, Dur, Amp), use a vector of values
% 	instead of a single number (e.g., [20 40 60] or 20:20:60)
%------------------------------------
% opto.Enable = 1;
% opto.Delay = 100;
% opto.Dur = 50;
% opto.Amp = 200;
opto.Enable = 0;
opto.Delay = 0;
opto.Dur = 200;
opto.Amp = 0;
%------------------------------------
% AUDITORY stimulus settings
%------------------------------------
%------------------------------------
% general audio properties
%------------------------------------
% Delay 
audio.Delay = 100;
% Duration is variable for WAV files - this information
% will be found in the audio.signal.WavInfo
% For now, this will be a dummy value
audio.Duration = 100;
% Level(s) for wav output (has no effect in this experiment)
audio.Level = 80;
audio.Ramp = 5;
audio.Frozen = 0;
%------------------------------------
% noise signal
%------------------------------------
noise.signal.Type = 'noise';
noise.signal.Fmin = 4000;
noise.signal.Fmax = 80000;
noise.Delay = audio.Delay;
noise.Duration = 100;
noise.Level = 60;
noise.Ramp = 5;
noise.Frozen = 0;
%------------------------------------
% null signal
%------------------------------------
nullstim.signal.Type = 'null';
nullstim.Delay = audio.Delay;
nullstim.Duration = noise.Duration;
nullstim.Level = 0;
%------------------------------------
% WAV
%------------------------------------
audio.signal.Type = 'wav';
audio.signal.WavPath = 'C:\TytoLogy\Experiments\WAVs';
% names of wav files to use as stimuli
WavesToPlay = {
'1StepUSV.wav', ...
'2StepUSV.wav', ...
'Chevron.wav', ...
'ChevronNL.wav', ...
'Flat.wav', ...
'LFH.wav', ...
'MFVtonal.wav', ...
'MFVHarmonics.wav', ...
'MFVNLs.wav', ...
'Noisy.wav', ...
'FlatTone.wav' ...
};


% # of wavs to play
nWavs = length(WavesToPlay);

% and scaling factors (to achieve desired amplitude)
% % % temporarily use 1 as scaling factor - fix after calibration!!!
WavScaleFactors = ones(nWavs, 1);

% max level achievable at given scale factor 
% (determined using FlatWav program)
WavLevelAtScale = [	
96.28, ...
96.29, ...
94.14, ...
93.45, ...
100.10, ...
104.48, ...
103.53, ...
108.7, ...
94.21, ...
103.21, ...
101.37	...
];

% onset, offset wav ramp duration (aka tapers)
WavRamp = 10;

