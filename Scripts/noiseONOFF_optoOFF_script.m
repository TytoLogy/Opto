%-------------------------------------------------------------------------
% Set Type of test
%-------------------------------------------------------------------------
% 	'LEVEL'			firing rate vs. stimulus level (dB)
%	`FREQ'			frequency-tuning curve (tones)
%	'FRA'				frequency-response area (tones)
% 	'OPTO'			simple optical stimulation (nothing varies)
% 	'OPTO-xxx'		optical stim, with 'xxx' as variable, where 'xxx' is
% 		'DELAY'			opto stim delay 
% 		'DUR'				opto stim duration
% 		'AMP'				opto stim amplitude
% 						or some combination of these
%
% *** for STANDALONE type, see default_standalone.m ***
%-------------------------------------------------------------------------
test.Type = 'LEVEL';

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% TEST: general settings for experiment
%-------------------------------------------------------------------------
test.Reps = 20;
test.Randomize = 1;
test.saveStim = 0;
% TDT
test.AcqDuration = 1000;
test.SweepPeriod = test.AcqDuration + 2;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% OPTO: optical stimulus settings
%-------------------------------------------------------------------------
test.opto.Enable = 0;
test.opto.Delay = 0;
test.opto.Dur = 500;
test.opto.Amp = [0];

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% AUDIO: Auditory stimulus settings 
%-------------------------------------------------------------------------
test.audio.signal.Type = 'noise';
test.audio.signal.Fmin = 4000;
test.audio.signal.Fmax = 80000;
test.audio.Delay = 200;
test.audio.Duration = 100;
test.audio.Level = [0 80];
test.audio.Ramp = 5;
test.audio.Frozen = 0;
test.audio.ISI = 1000;
