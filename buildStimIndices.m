function [stimIndices, repList] = ...
					buildStimIndices(nTotalTrials, nCombinations, nReps, ...
											Randomize, Block)
%--------------------------------------------------------------------------
% buildStimIndices
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% randomize in blocks (if necessary) by creating a randomized list of 
% indices of the different stimuli within stimList
%--------------------------------------------------------------------------
% Input Arguments:
%	nTotalTrials, nCombinations, nReps, Randomize, Block
% Output Arguments:
%	stimIndices, repList
% See Also: 
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Created:	12 June April, 2017 (SJS)
%	Pulled out of standalone scripts
% Revision History:
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

% preallocate stimIndices which will hold the indices to the stimuli
% in stimList - these can then be randomized, blocked or sequential.
stimIndices = zeros(nTotalTrials, 1);

% repList will indicate which repetition of the stimulus is being played
repList = zeros(nTotalTrials, 1);

if Randomize == 1
	% assign random permutations to stimindices
	for r = 1:nReps
		stimIndices( (((r-1)*nCombinations) + 1):(r*nCombinations) ) = ...
							randperm(nCombinations);
		repList((((r-1)*nCombinations) + 1):(r*nCombinations) ) = ...
							r * ones(nCombinations, 1);
	end
elseif Block == 1
	% Blocked stimulus order
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