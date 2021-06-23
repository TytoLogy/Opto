%-------------------------------------------------------------------------
% Set Type of test
%-------------------------------------------------------------------------
% 	'LEVEL'			firing rate vs. stimulus level (dB)
%	`FREQ'			frequency-tuning curve (tones)
%	'FRA'				frequency-response area (tones)
% 	'OPTO'			simple optical stimulation (nothing varies)
% 	'OPTO-xxx'		optical stim, with 'xxx' as variable, where 'xxx' is
% 		'DELAY'			opto stim delay  (set values in test.opto.Delay)
% 		'DUR'          opto stim duration (set values in test.opto.Dur)
% 		'AMP'          opto stim amplitude (set values in test.opto.Amp)
%-------------------------------------------------------------------------
test.Type = 'OPTO-AMP';

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% OPTOGENETIC stimulation settings
% test.opto.Enable   0 = OFF, 1 = ON
% test.opto.Delay    delay of opto onset from start of sweep (ms)
% test.opto.Dur      duration of opto stimulus (ms)
% test.opto.Amp      output level of opto command/trigger sent to LED
%                    controller or laser trigger* (mV)
%                    !!! BE SURE TO CHECK THAT VALUE DOES NOT EXCEED
%                    SPECIFIED MAX OF LED !!!!!!!!!!!!!!!!!!!!!!!!!!!
% *for laser, this should be set to 1000 mV (1V) and power is controlled by
% dial on laser controller
%-------------------------------------------------------------------------
test.opto.Enable = 1;
test.opto.Delay = 50;
test.opto.Dur = 100;
test.opto.Amp = [0 100 300:500:3000];

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Auditory stimulus settings
%-------------------------------------------------------------------------
% *** these are mostly ignored for OPTO stimuli!!!!
%-------------------------------------------------------------------------
% signal
test.audio.signal.Type = 'noise';
test.audio.signal.Fmin = 4000;
test.audio.signal.Fmax = 80000;
test.audio.Delay = 100;
test.audio.Duration = 200;
test.audio.Level = 0;
test.audio.Ramp = 1;
test.audio.Frozen = 0;
test.audio.ISI = 300;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Reps, randomization, save stimuli?
%-------------------------------------------------------------------------
test.Reps = 20;
test.Randomize = 1;
test.saveStim = 0;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% TDT circuit settings
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
test.AcqDuration = 300;
test.SweepPeriod = test.AcqDuration + 1;

 


