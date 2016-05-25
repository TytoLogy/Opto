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

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% OPTICAL settings
%-------------------------------------------------------------------------
test.opto.Enable = 0;
test.opto.Delay = 0;
test.opto.Dur = 100;
test.opto.Amp = 50;
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Auditory stimulus settings
%-------------------------------------------------------------------------

% signal
test.audio.signal.Type = 'noise';
test.audio.signal.Fmin = 4000;
test.audio.signal.Fmax = 80000;
test.audio.Delay = 100;
test.audio.Duration = 200;
test.audio.Level = 0:10:60;
test.audio.Ramp = 1;
test.audio.Frozen = 0;
test.audio.ISI = 1000;

test.Reps = 10;
test.Randomize = 0;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% TDT
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
test.TDT.AcqDuration = 1000;
test.TDT.AcqDuration.SweepPeriod = 1001;

 


