function [wavInfo, varargout] = opto_create_wav_stimulus_info(...
												wpath, wnames, scalef, levels)
%--------------------------------------------------------------------------
% wavInfo = opto_create_wav_stimulus_info(...
% 												wpath, wnames, scalef, levels)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% creates wav stimulus file for use in experiments
%--------------------------------------------------------------------------
% Input Arguments:
%		wpath			path to wavfiles
%		wnames		cell array of wav file names
%		scalef		wav stimulus scaling factors obtained from calibration
%		levels		wav stimulus output levels at scaling factor, obtained
% 						from calibration
% 								
% Output Arguments:
%	wavInfo				struct array with information about wavfiles
%		Fields in struct wavInfo:
% 			Filename						name of file
% 			CompressionMethod			compressed?
% 			NumChannels					# of audio channels
% 			SampleRate					sampling rate
% 			TotalSamples				length of audio in samples
% 			Duration						duration of audio in seconds
% 			Title							metadata
% 			Comment						metadata
% 			Artist						metadata
% 			BitsPerSample				bit depth
% 			OnsetBin						sound onset sample
% 			OffsetBin					sound offset sample
% 			PeakRMS						max RMS value
% 			PeakRMSTime					max RMS value time
% 			PeakRMSWin					window size (ms) used to compute RMS
%
%	 wavFiles = cell array of wav file names
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
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

nWavs = length(wnames);

if ~nWavs
	error('%s: wnames is empty', mfilename);
end

%------------------------------------
% wav properties - use to build database of properties stored in wavInfo
% struct
%------------------------------------
% select only waves in list
% get information about stimuli
AllwavInfo = getWavInfo(fullfile(wpath, 'wavinfo.mat'));
% create list of ALL filenames - need to do a bit of housekeeping
% deal function will pull out all values of the Filename field from
% the AllwavInfo struct array
AllwavNames = {};
[AllwavNames{1:length(AllwavInfo), 1}] = deal(AllwavInfo.Filename);
% need to strip paths from filenames...
for w = 1:length(AllwavNames)
	[~, basename] = fileparts(AllwavNames{w});
	AllwavNames{w} = [basename '.wav'];
end
% and, using filenames, select only wav files in list wnames
wavInfo = repmat( AllwavInfo(1), nWavs, 1);
for w = 1:nWavs
	wavInfo(w) = AllwavInfo(strcmp(wnames(w), AllwavNames));
end
%------------------------------------
% create list of filenames - need to do a bit of housekeeping
%------------------------------------
wavFiles = cell(nWavs, 1);
tmp = {};
[tmp{1:nWavs, 1}] = deal(wavInfo.Filename);
% assign wav filenames to wavInfo (if they already have .wav attached, this
% should not affect things due to use of fileparts function to extract
% basename from file name in wavInfo)
for n = 1:nWavs
	[~, basename] = fileparts(tmp{n});
	wavFiles{n} = [basename '.wav'];
	% make sure Filename in wavInfo matches
	wavInfo(n).Filename = wavFiles{n};
	wavInfo(n).ScaleFactor = scalef(n);
	wavInfo(n).WavLevelAtScale = levels(n);
end
clear tmp;

if nargout > 1
	varargout{1} = wavFiles;
end

