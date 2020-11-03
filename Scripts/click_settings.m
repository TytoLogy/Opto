%-------------------------------------------------------------------------
% click_settings
%-------------------------------------------------------------------------
% Experiment settings
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% %%% EDIT THESE TO CHANGE EXPERIMENTAL PARAMETERS (reps, ISI, etc.) %%%%
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%-------------------------------------------------------------------------

%----------------------------------------------------------
% Presentation settings - ISI, # reps, randomize, etc.
%	Note that Randomize in this context will mean a 
%	blocked randomization, e.g., random sequence of each stimulus
%	without repeats for 1 rep, then another, then .... etc.
%----------------------------------------------------------
test.Reps = 20;
test.Randomize = 1;
test.Block = 0;
audio.ISI = 100;

%------------------------------------
% Experiment settings
%------------------------------------
% save output stimuli? (0 = no, 1 = yes)
test.saveStim = 0;
% stimulus levels to test
% !!! note that levels for individual stimulus types set below are
% overridden by these values
test.Level = [ 70];
% use null stim?
test.NullStim = 0;
% use Noise stim?
test.NoiseStim = 0;

%------------------------------------
% acquisition/sweep settings
% will have to be adjusted to deal with wav file durations
%------------------------------------
test.AcqDuration = 400;
test.SweepPeriod = test.AcqDuration + 5;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% define stimulus (optical, audio) structs
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%------------------------------------
% OPTICAL settings
%	Enable	0 -> optical stim OFF, 1 -> optical stim ON
%	Delay		onset of optical stim from start of sweep (ms)
% 	Dur		duration (ms) of optical stimulus
% 	Amp		amplitude (mV) of optical stim
% 					*** IMPORTANT NOTE ***
% 					This method of amplitude control will only work with the 
% 					Thor Labs fiber-coupled LED driver.
% 					For the Shanghai Dream Laser, output level can only be 
% 					controlled using the rotary potentiometer on the Laser power
% 					supply. If using the Shanghai Dream Laser for stimulation,
% 					set Amp to 5000 millivolts (5 V)
% 
% 	To test a range of values (for Delay, Dur, Amp), use a vector of values
% 	instead of a single number (e.g., [20 40 60] or 20:20:60)
%------------------------------------
% opto.Enable = 1;
% opto.Delay = 100;
% opto.Dur = 50;
% opto.Amp = 200;
opto.Enable = 0;
opto.Delay = 0;
opto.Dur = 200;
opto.Amp = 0;

%----------------------------------------------
% AUDITORY stimulus settings (audio struct)
%----------------------------------------------
%------------------------------------
% general audio properties
%------------------------------------
% Delay - this will set the delay in TDT hardware (don't need to add
% delay in the click stimulus itself
audio.Delay = 10;
% Duration is total signal duration - not click duration
% click duration will be set in the audio.signal.ClickDuration field
audio.Duration = 100;
% % Level(s) for click output
% audio.Level = test.Level;
% no ramp needed
audio.Ramp = 0;
% frozen is meaningless for clicks
audio.Frozen = 0;

%----------------------------------------------
% Click specific bits go into audio.signal stuct
%----------------------------------------------
audio.signal.Type = 'click';
% duration of the click (in milliseconds)
audio.signal.ClickDuration = 0.050;
% delay of click in signal (usually set to 0)
audio.signal.ClickDelay = 0;
% amplitude of click - set to DAscale from caldata for now
audio.signal.ClickScale = caldata.DAscale;
% output level at scale, with zero attenuation. need to 
% get this using calibration rig to measure output
audio.signal.ClickLevelAtScale = 70;

%------------------------------------
% null signal
%------------------------------------
nullstim.signal.Type = 'null';
nullstim.Delay = audio.Delay;
nullstim.Duration = audio.Duration;
nullstim.Level = 0;
%------------------------------------
% noise signal
%------------------------------------
noise.signal.Type = 'noise';
noise.signal.Fmin = 4000;
noise.signal.Fmax = 80000;
% set this to 100 ms
noise.Delay = 100;
noise.Duration = 100;
noise.Level = 60;
noise.Ramp = 5;
noise.Frozen = 0;

%%%%%%%%%%%%%
%{
note: not sure yet how to deal with levels. specify max click amplitude
based on calibration (DAscale) and then scale based on max calibration
level? or keep attenuator off (0 atten) and use scaling to determine
amplitude?

for now, use first approach
%}



