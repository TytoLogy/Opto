%-------------------------------------------------------------------------
% Standalone script
%		This default script will play different levels of noise 
%		in combination with different levels of optical stimulution
%-------------------------------------------------------------------------
% indicate that this is a standalone script
test.Type = 'STANDALONE';
test.Function = @noise_opto;

%{
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
test.audio.Level = 60:10:90;
test.audio.Ramp = 1;
test.audio.Frozen = 0;
test.audio.ISI = 1000;

test.Reps = 10;
test.Randomize = 0;

test.saveStim = 0;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% TDT
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
test.AcqDuration = 1000;
test.SweepPeriod = 1001;

%}
