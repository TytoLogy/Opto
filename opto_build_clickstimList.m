function [stimList, varargout] = opto_build_clickstimList(test, audio, ...
	                                                       opto, nullstim)
%--------------------------------------------------------------------------
% [stimList, counts] = opto_build_clickstimList(test, audio, opto, nullstim)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
%  build list of unique stimuli for click test 
%---------------------------------------------------------------------
% calculate Ncombinations:
%		total # of varied variables 
%---------------------------------------------------------------------
% how to calculate:
% 	- each auditory stimulus will (or won't be) 
% 		combined with opto stimuli
% 	- each auditory stimulus will be presented at different stimulus levels
% 		
% 	nOptoStim	# of opto variables (e.g., intensity, delay or duration)
% 	nAudioLevels	# of levels to present auditory stimuli
% 	nNullStim	1 if null presented, 0 if not
% 		
% 	since audio levels don't apply to the null stimulus, the total number
% 	of stimulus combinations are:
% 	
% 	nOptoStim * (nAudioLevels + nNullStim)
%
% for ease, nAudioStim = nAudioLevels + nNullStim
%---------------------------------------------------------------------
% Input Arguments:
%  test
%  audio
%  opto
%  nullstim
% 								
% Output Arguments:
%  stimList
%  counts
%--------------------------------------------------------------------------
% See Also: opto_build_stimList, opto
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Created:	28 October, 2020 (SJS)
%	modification of opto_build_stimList for new click stimulus test
% 
% Revision History:
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

% varied variables for opto and audio
optovar = opto.Amp;

% different elements -> get counts
nOptoStim = numel(optovar);
nAudioLevels = numel(test.Level);
nNoiseStim = test.NoiseStim;
nNullStim = test.NullStim;

% # of audio stimuli
nAudioStim = nAudioLevels + nNullStim;
% # combinations of opto and audio stimuli
nCombinations = nOptoStim * nAudioStim;
% # of total trials will be nCombinations * number of stimulus reps
nTotalTrials = nCombinations * test.Reps;

% user feedback
fprintf('%s:\nBuilding Click stimList with parameters:\n', mfilename);
fprintf('\tnOptoStim: %d\n',	nOptoStim);
fprintf('\tnAudioLevels: %d\n',	nAudioLevels);
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
	% loop through the # of opto stim.
	for oindex = 1:nOptoStim
		sindex = sindex + 1;
		% get opto amplitude
		stimList(sindex).opto.Amp = optovar(oindex);
		% assign null to audio stim
		stimList(sindex).audio = nullstim;
	end
end

% then assign wav stimuli
% loop through opto levels
for oindex = 1:nOptoStim
	% loop through audio levels
	for lindex = 1:nAudioLevels
		% increment stimIndex
		sindex = sindex + 1;
		% get opto amplitude
		stimList(sindex).opto.Amp = optovar(oindex);
		% assign stimulus level
		stimList(sindex).audio.Level = test.Level(lindex);
	end	
end

% assign output
if nargout > 1
	varargout{1} = ...
				struct(	'nOptoStim',	nOptoStim, ...
							'nAudioLevels',	nAudioLevels, ...
							'nNoiseStim',	nNoiseStim, ...
							'nNullStim',	nNullStim, ...
							'nAudioStim',	nAudioStim, ...
							'nCombinations',	nCombinations, ...
							'nTotalTrials',	nTotalTrials ...
						);
end
