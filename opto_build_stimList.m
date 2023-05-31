function [stimList, varargout] = opto_build_stimList(test, audio, opto, ...
																			noise, nullstim)
%--------------------------------------------------------------------------
% [stimList, counts] = opto_build_stimList(test, audio, 
%                                              opto, noise, nullstim)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
%  build list of unique stimuli
%---------------------------------------------------------------------
% calculate Ncombinations:
%		total # of varied variables 
%---------------------------------------------------------------------
% how to calculate:
% 	- each auditory stimulus (wav and noise) will (or won't be) 
% 		combined with opto stimuli
% 	- an additional possible stimulus will be "null" stimulus
% 	- each auditory stimulus will be presented at different stimulus levels
% 		(doesn't apply to null stimulus!)
% 		
% 	nOptoStim	# of opto variables (e.g., intensity, delay or duration)
% 	nAudioLevels	# of levels to present auditory stimuli
% 	nWavStim	# of auditory stimuli (e.g., # wav files)
% 	nNoiseStim	1 if noise to be presented, 0 if not
% 	nNullStim	1 if null presented, 0 if not
% 		
% 	since audio levels don't apply to the null stimulus, the total number
% 	of stimulus combinations are:
% 	
% 	nOptoStim * { (nAudioLevels * (nWavStim + nNoiseStim)) + nNullStim}
%
% for ease, nAudioStim = nAudioLevels * (nWavStim + nNoiseStim)
% 											+ nNullStim
%---------------------------------------------------------------------
%--------------------------------------------------------------------------
% Input Arguments:
% 								
% Output Arguments:
%--------------------------------------------------------------------------
% See Also: getWavInfo, buildWavInfo, opto
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Created:	24 April, 2019 (SJS)
%	split off from MTwav standalone function
% 
% Revision History:
%  28 Oct 2020 (SJS): fixed some comments. this should eventually be
%  generalized to allow for all stimulus types (not just WAV).
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

% varied variables for opto and audio
optovar = opto.Amp;
audiowavvar = audio.signal.WavFile;

% different elements -> get counts
nOptoStim = numel(optovar);
nAudioLevels = numel(test.Level);
nWavStim = numel(audiowavvar);
nNoiseStim = test.NoiseStim;
nNullStim = test.NullStim;
% # of audio stimuli
nAudioStim = (nAudioLevels * (nWavStim + nNoiseStim)) + nNullStim;
% # combinations
nCombinations = nOptoStim * nAudioStim;
% # of total trials will be nCombinations * number of stimulus reps
nTotalTrials = nCombinations * test.Reps;

% user feedback
fprintf('%s:\nBuilding stimList with parameters:\n', mfilename);
fprintf('\tnOptoStim: %d\n',	nOptoStim);
fprintf('\tnAudioLevels: %d\n',	nAudioLevels);
fprintf('\tnWavStim: %d\n',	nWavStim);
fprintf('\tnNoiseStim: %d\n',	nNoiseStim);
fprintf('\tnNullStim: %d\n',	nNullStim);
fprintf('\tnAudioStim: %d\n',	nAudioStim);
fprintf('\tnCombinations: %d\n',	nCombinations);
fprintf('\tnTotalTrials: %d\n',	nTotalTrials);


% create list to hold parameters for varied variables - this will be 
% used to randomize the stimulus presentation order
stimList = repmat(	...
							struct(	'opto', opto, ...
										'audio', audio ...
									), ...
							nCombinations, 1);
						
% assign values - in this case, inner loop cycles through audio variables,  
% outer loop cycles through optical variables

% initialize stimList index, sindex
sindex = 0;

% first assign null stimuli (if needed)
%		these will be at the different opto levels, not audio levels
if nNullStim
	for oindex = 1:nOptoStim
		sindex = sindex + 1;
		stimList(sindex).opto.Amp = optovar(oindex);
		% assign null to audio stim
		stimList(sindex).audio = nullstim;
	end
end

% then assign noise stimuli (if needed)
if nNoiseStim
	for oindex = 1:nOptoStim
		for lindex = 1:nAudioLevels
			sindex = sindex + 1;
			stimList(sindex).opto.Amp = optovar(oindex);
			% assign noise to audio stim
			stimList(sindex).audio = noise;
			% assign stimulus level
			stimList(sindex).audio.Level = test.Level(lindex);
		end
	end
end

% then assign wav stimuli
for oindex = 1:nOptoStim
	for windex = 1:nWavStim
		for lindex = 1:nAudioLevels
			sindex = sindex + 1;
			stimList(sindex).opto.Amp = optovar(oindex);
			% assign wav filename
			stimList(sindex).audio.signal.WavFile = audiowavvar{windex};
			% assign stimulus level
			stimList(sindex).audio.Level = test.Level(lindex);
		end
	end	
end

% assign output
if nargout > 1
	varargout{1} = ...
				struct(	'nOptoStim',	nOptoStim, ...
							'nAudioLevels',	nAudioLevels, ...
							'nWavStim',	nWavStim, ...
							'nNoiseStim',	nNoiseStim, ...
							'nNullStim',	nNullStim, ...
							'nAudioStim',	nAudioStim, ...
							'nCombinations',	nCombinations, ...
							'nTotalTrials',	nTotalTrials ...
						);
end
