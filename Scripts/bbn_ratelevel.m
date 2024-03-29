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
test.opto.Enable = 0;
test.opto.Delay = 75;
test.opto.Dur = 100;
test.opto.Amp = 3000;
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Auditory stimulus settings
%-------------------------------------------------------------------------

% signal
test.audio.signal.Type = 'noise';
test.audio.signal.Fmin = 4000;
% test.audio.signal.Fmin = 40000;
test.audio.signal.Fmax = 80000;
test.audio.Delay = 100;
test.audio.Duration = 100;
% test.audio.Level = [0 40 60 80];
test.audio.Level = 0:10:70;
test.audio.Ramp = 5;
test.audio.Frozen = 0;
%MTcomment 2/10/23:for IC
% test.audio.ISI = 100;
%MTcomment 2/10/23:for BLA
test.audio.ISI = 700;
test.Reps = 20;
% test.Reps = 5;
test.Randomize = 1;
test.Block = 0;
test.saveStim = 0;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% TDT
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
test.AcqDuration = 250;
test.SweepPeriod = test.AcqDuration + 5;

 if test.opto.Enable
	test.Name = [test.Name '_optoON'];
end


