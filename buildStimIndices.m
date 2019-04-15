function [stimIndices, repList] = ...
					buildStimIndices(nTotalTrials, nCombinations, nReps, ...
											Randomize, Block)
%--------------------------------------------------------------------------
% buildStimIndices
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% randomize in blocks (if necessary) by creating a randomized list of 
% indices of the different stimuli within a stimulus list. The calling
% function/script/program will have a list of stimuli (i.e. stimList in
% opto program/script) that will be randomized by stepping through the
% stimList using indices returned in stimIndices)
%--------------------------------------------------------------------------
% Input Arguments:
%	nTotalTrials		total number of stimulus presentations 
%							(necessary?	should be able to calculate this from 
%							nCombinations *nReps)
%	nCombinations		number of stimulus parameter combinations
%								e.g., # frequencies * # levels
%	nReps					number of repetitions for each stimulus combination
%	Randomize			randomize sequence of stimuli?
%	Block					randomize stimuli within blocks for each repetition
% 								each stimulus combination ispresented once in 
% 								random order for each repetition and will 
% 								continue for the nReps # of repetitions.
% 
% Output Arguments:
%	stimIndices			indices into the nTotalTrials # of stimuli
%	repList				indicates which repetition is present in sequence
%
% See Also: randperm, opto_buildStimCache
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Created:	12 June April, 2017 (SJS)
%	Pulled out of standalone scripts
% Revision History:
%	15 Apr 2019 (SJS): adding checks for repeating stimuli or blocks
% 	!!! superceded by randomSequence and blockSequence!
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

% quick check
if nTotalTrials ~= nCombinations * nReps
	warning('buildStimIndices: odd mismatch, nTotalTrials ~= nComb*nReps');
end

% preallocate stimIndices which will hold the indices to the stimuli
% in stimList - these can then be randomized, blocked or sequential.
stimIndices = zeros(nTotalTrials, 1);

% repList will indicate which repetition of the stimulus is being played
repList = zeros(nTotalTrials, 1);

if (Randomize == 1) && (Block == 1)
	% assign random permutations to stimindices
	for r = 1:nReps
		stimIndices( (((r-1)*nCombinations) + 1):(r*nCombinations) ) = ...
							randperm(nCombinations);
		repList((((r-1)*nCombinations) + 1):(r*nCombinations) ) = ...
							r * ones(nCombinations, 1);
	end
elseif (Randomize == 0) && (Block == 1)
	% Blocked stimulus order - not randomized
	blockindex = 1;
	for cIndx = 1:nCombinations
		for r = 1:nReps
			stimIndices(blockindex) = cIndx;
			repList(blockindex) = r;
			blockindex = blockindex + 1;
		end
	end
else
	% assign sequential indices to stimindices
	for r = 1:nReps
		stimIndices( (((r-1)*nCombinations) + 1):(r*nCombinations) ) = ...
							1:nCombinations;
		repList((((r-1)*nCombinations) + 1):(r*nCombinations) ) = ...
							r * ones(nCombinations, 1);
	end
end