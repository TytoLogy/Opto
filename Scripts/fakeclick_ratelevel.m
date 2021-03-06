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
test.Type = 'LEVEL';
test.Name = 'FAKECLICK_LEVEL';

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% OPTICAL settings
%-------------------------------------------------------------------------
test.opto.Enable = 0;
test.opto.Delay = 0;
test.opto.Dur = 300;
test.opto.Amp = 2000;
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Auditory stimulus settings
%-------------------------------------------------------------------------

% signal
test.audio.signal.Type = 'noise';
test.audio.signal.Fmin = 4000;
test.audio.signal.Fmax = 80000;
test.audio.Delay = 100;
test.audio.Duration = 5;
test.audio.Level = [0 40 60 80];
test.audio.Ramp = .1;
test.audio.Frozen = 0;
test.audio.ISI = 250;

test.Reps = 10;
test.Randomize = 1;
test.Block = 0;
test.saveStim = 0;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% TDT
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
test.AcqDuration = 400;
test.SweepPeriod = test.AcqDuration + 5;

 


