% wav signal
WavesToPlay = {	'MFV_tonal_normalized.wav', ...
						'P100_11_Noisy.wav', ...
						'P100_1_Flat_USV.wav', ...
						'P100_9_LFH.wav' ...
					};
audio.signal.Type = 'wav';
audio.signal.WavPath = 'C:\TytoLogy\Experiments\Wavs';

% get information about stimuli
AllwavInfo = getWavInfo(fullfile(audio.signal.WavPath, 'wavinfo.mat'));
% create list of ALL filenames - need to do a bit of housekeeping
AllwavNames = {};
[AllwavNames{1:length(AllwavInfo), 1}] = deal(AllwavInfo.Filename);
% need to strip paths from filenames
for w = 1:length(AllwavNames)
	[~, basename] = fileparts(AllwavNames{w});
	AllwavNames{w} = [basename '.wav'];
end
% select only waves in list
wavInfo = repmat( AllwavInfo(1), length(WavesToPlay), 1);
for w = 1:length(WavesToPlay)
	wavInfo(w) = AllwavInfo(strcmp(WavesToPlay(w), AllwavNames));
end




%{
wavInfo = AllwavInfo;
nWavs = length(wavInfo);
% create list of filenames - need to do a bit of housekeeping
audio.signal.WavFile = cell(nWavs, 1);
tmp = {};
[tmp{1:nWavs, 1}] = deal(wavInfo.Filename);
% assign wav filenames to wavInfo
for n = 1:nWavs
	[~, basename] = fileparts(tmp{n});
	audio.signal.WavFile{n} = [basename '.wav'];
	% make sure Filename in wavInfo matches
	wavInfo(n).Filename = audio.signal.WavFile{n};
end
clear tmp;
%}