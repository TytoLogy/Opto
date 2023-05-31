%-------------------------------------------------------------------------
% Standalone script for Mahtab
%  19 Oct 2020 (SJS): trying to track down persisten problem with error:
% 		Undefined function or variable 'noise'.
% 
% 		Error in MTwav (line 143) [stimList, counts] =
% 		opto_build_stimList(test, audio, opto, noise, nullstim); %#ok<NODEF>
%-------------------------------------------------------------------------
% indicate that this is a standalone script
test.Type = 'STANDALONE';
test.Name = 'WAV';
% test.Function = @wav;
test.Function = @MTwav;
% test.Function = @MTwav_19Oct20;
