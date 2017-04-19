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
%-------------------------------------------------------------------------
test.Type = 'OPTO-AMP';

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% OPTICAL settings
%-------------------------------------------------------------------------
test.opto.Enable = 1;
test.opto.Delay = 100;
test.opto.Dur = 10;
test.opto.Amp = 0:200:600;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Auditory stimulus settings
%-------------------------------------------------------------------------
% *** these are mostly ignored for OPTO stimuli!!!!
% signal
test.audio.signal.Type = 'noise';
test.audio.signal.Fmin = 4000;
test.audio.signal.Fmax = 80000;
test.audio.Delay = 100;
test.audio.Duration = 200;
test.audio.Level = 0;
test.audio.Ramp = 1;
test.audio.Frozen = 0;
test.audio.ISI = 500;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Reps
%-------------------------------------------------------------------------

test.Reps = 20;
test.Randomize = 1;

test.saveStim = 0;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% TDT
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
test.AcqDuration = 500;
test.SweepPeriod = test.AcqDuration + 1;

 


