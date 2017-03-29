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
opto.Enable = 1;
opto.Delay = 0;
opto.Dur = 100;
opto.Amp = 0:25:100;
%------------------------------------
% Auditory stimulus settings
%------------------------------------
% signal
audio.signal.Type = 'noise';
audio.signal.Fmin = 4000;
audio.signal.Fmax = 80000;
audio.Delay = 100;
audio.Duration = 200;
audio.Level = 0:10:60;
audio.Ramp = 1;
audio.Frozen = 0;
%------------------------------------
% Presentation settings
%------------------------------------
Reps = 10;
Randomize = 1;
audio.ISI = 1000;

%------------------------------------
% Experiment settings
%------------------------------------
% save output stimuli? (0 = no, 1 = yes)
saveStim = 0;

%------------------------------------
% acquisition/sweep settings
%------------------------------------
AcqDuration = 1000;
SweepPeriod = 1001;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% build list of unique stimuli
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% varied variables for opto and audio
optovar = opto.Amp;
audiovar = audio.Level;
% total # of varied variables
nCombinations = numel(optovar) * numel(audiovar);
% create list to hold parameters for varied variables
stimList = repmat(	...
							struct(	'opto', opto, ...
										'audio', audio ...
									), ...
							nCombinations, 1);
% assign values - in this case, inner loop cycles through audio variables,  
% outer loop cycles through optical variables
sindex = 1;
for oindex = 1:numel(optovar)
	for aindex = 1:numel(audiovar)
		stimList(sindex).opto.Amp = optovar(oindex);
		stimList(sindex).audio.Level = audiovar(aindex);
		sindex = sindex + 1;
	end
end

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% randomize in blocks (if necessary) by creating a randomized list of 
% indices of the different stimuli within stimList
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% preallocate stimIndices
stimIndices = zeros(nCombinations * Reps, 1);
% and assign values
if Randomize
	% assign random permutations to stimindices
	for r = 1:Reps
		stimIndices( (((r-1)*nCombinations) + 1):(r*nCombinations) ) = ...
							randperm(nCombinations);
	end
else
	% assign blocked indices to stimindices
	for r = 1:Reps %#ok<UNRCH>
		stimIndices( (((r-1)*nCombinations) + 1):(r*nCombinations) ) = ...
							1:nCombinations;
	end
end

