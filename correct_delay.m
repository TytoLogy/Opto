function correctedDelay = correct_delay(originalDelay, wavInfo, outFs)
% computes correction to stimulus output delay to compensate for onset
% delay in .wav file


% get the onset bin from wavInfo
optoDelayCorr = wavInfo.OnsetBin;

% compute the delay correction using the output sample rate
correctedDelay = ms2bin(originalDelay, outFs) - optoDelayCorr;

% check for invalid value
if correctedDelay < 0
	warning('%s: correctedDelay < 0! Using 0 as min value', ...
				mfilename);
	correctedDelay = 0;
end


