%-------------------------------------------------------------------------
% Set Type of test
%-------------------------------------------------------------------------
% 	'LEVEL'			firing rate vs. stimulus level (dB)
%	`FREQ'			frequency-tuning curve (tones)
%	'FREQ+LEVEL'	frequency-response area (tones)
% 	'OPTO'			simple optical stimulation (nothing varies)
% 	'OPTO-xxx'		optical stim, with 'xxx' as variable, where 'xxx' is
% 		'DELAY'			opto stim delay 
% 		'DUR'				opto stim duration
% 		'AMP'				opto stim amplitude
% 						or some combination of these
%-------------------------------------------------------------------------
test.Type = 'FREQ+LEVEL';
test.Name = 'FRA';

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% OPTICAL settings
%-------------------------------------------------------------------------
test.opto.Enable = 0;
test.opto.Delay = 150;
test.opto.Dur = 200;
test.opto.Amp = 2000; % mV

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Auditory stimulus settings
%-------------------------------------------------------------------------
% signal
test.audio.signal.Type = 'tone';
test.audio.signal.Frequency = floor(octaves(3, 4000, 90000, 2));
% test.audio.signal.Frequency = 7500:2500:40000;
test.audio.signal.RadVary = 1;
test.audio.Delay = 100;
test.audio.Duration = 100;
test.audio.Level = 0:10:80;
test.audio.Ramp = 5;
test.audio.Frozen = 0;
test.audio.ISI = 100;

test.Reps = 10;
test.Randomize = 1;
test.Block = 0;
test.saveStim = 0;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% TDT
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
test.AcqDuration = 200;
test.SweepPeriod = test.AcqDuration + 1;

 if test.opto.Enable
	test.Name = [test.Name 'optoON'];
end



