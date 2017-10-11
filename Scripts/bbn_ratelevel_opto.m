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
test.Name = 'BBN';

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% OPTICAL settings
%-------------------------------------------------------------------------
test.opto.Enable = 1;
% test.opto.Delay = 100;
% test.opto.Dur = 300;
% test.opto.Delay = 200;
% test.opto.Dur = 100;
test.opto.Delay = 300;
test.opto.Dur = 50;
test.opto.Amp = 4000;
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Auditory stimulus settings
%-------------------------------------------------------------------------
% signal
test.audio.signal.Type = 'noise';
test.audio.signal.Fmin = 4000;
test.audio.signal.Fmax = 80000;
test.audio.Delay = 200;
test.audio.Duration = 100;
% test.audio.Level = 0:10:80;
% test.audio.Level = [0 5 10:2:24];
% test.audio.Level = 0;
test.audio.Level = 0:2:30;
test.audio.Ramp = 5;
test.audio.Frozen = 0;
test.audio.ISI = 500;
% test.audio.ISI = 100;

test.Reps = 10;
test.Randomize = 1;

test.saveStim = 0;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% TDT
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
test.AcqDuration = 600;
test.SweepPeriod = test.AcqDuration + 5;

if test.opto.Enable
	test.Name = [test.Name '_optoON'];
end
	

 


