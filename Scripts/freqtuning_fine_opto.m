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
test.Type = 'FREQ';
test.Name = 'FREQ';

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% OPTICAL settings
%-------------------------------------------------------------------------
test.opto.Enable = 1;
test.opto.Delay = 200;
test.opto.Dur = 150;
test.opto.Amp = 4000; % mV

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Auditory stimulus settings
%-------------------------------------------------------------------------
% signal
test.audio.signal.Type = 'tone';
% test.audio.signal.Frequency = 5000:5000:80000;
% test.audio.signal.Frequency = 5000:2500:25000;
% test.audio.signal.Frequency = 5000:2500:35000;
test.audio.signal.Frequency = 5000:1250:25000;
% test.audio.signal.Frequency = 5000;
test.audio.signal.RadVary = 1;
test.audio.Delay = 200;
test.audio.Duration = 100;
test.audio.Level = 20;
% test.audio.Level = 0;
test.audio.Ramp = 5;
test.audio.Frozen = 0;

test.Reps = 10;
test.Randomize = 1;
test.Block = 0;
test.saveStim = 0;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% TDT
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
test.audio.ISI = 100;
test.AcqDuration = 600;
test.SweepPeriod = test.AcqDuration + 1;

if test.opto.Enable
	test.Name = [test.Name '_optoON'];
end


