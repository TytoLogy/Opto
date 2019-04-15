


% test types
% 
% LEVEL		rate-level function (for a given stimulus)
% FREQ		frequency-tuning curve (fixed level, vary freq)
% FREQ+LEVEL	frequency response area (vary level, vary freq)
% WAV		usually vocal stimuli stored as .wav files
% * need way to simplify or generalize this...

% make up some values for testing
nLevels = 3;
nFreqs = 5;
nReps = 2;
% number of varied stimulus parameters
stimparams = {'Level', 'Freq'};
nparams = length(stimparams);

% blocked presentation? 
% blocked will create sequence in which each stimulus combination is
% presented once in random order for each repetition and will continue for
% the nReps number of repetitions.
block = 1;

% checks/controls/filters on stimuli
% check for identical successive stimuli?
nSuccesiveStim = 0;

% similarity index between blocks
% %% not yet certain how to do this.
simIndexPct = 0;

% number of stimulus combinations
nCombinations = nLevels * nFreqs * nReps;

%---------------------------------------------------------------------------
% 
%---------------------------------------------------------------------------

% combiList is list of unique combinations
combiList = 1:nCombinations;


% par(ameter)List holds values for the different stimulus characteristics
% par(ameter)Index will store the indices to the different values
parList = cell{



