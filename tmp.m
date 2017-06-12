test.Reps = 3;
nStimuli = 5;
nCombinations = nStimuli;
nTotalTrials = nCombinations * test.Reps;
randIndices = zeros(nTotalTrials, 1); 
seqIndices = zeros(nTotalTrials, 1);
blockIndices = zeros(nTotalTrials, 1);

for r = 1:test.Reps
	randIndices( (((r-1)*nCombinations) + 1):(r*nCombinations) ) = ...
						randperm(nCombinations);
end
for r = 1:test.Reps
		seqIndices( (((r-1)*nCombinations) + 1):(r*nCombinations) ) = ...
							1:nCombinations;
end

blockIndices = zeros(nTotalTrials, 1);
blockindex = 1;
for c = 1:nCombinations
	for r = 1:test.Reps
		blockIndices(blockindex) = c;
		blockindex = blockindex + 1;
	end
end

[randIndices seqIndices blockIndices]