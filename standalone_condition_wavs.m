%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Load and condition wav stimuli
%
% steps:
% 	1) read in wav file
% 	2) make sure wav data are in row vector form
% 	3) adjust the sample rate if it does not match D/A converter rate
% 		if adjustment needed, need to modify other sample-rate-dependent things:
% 			- stored sample rate
% 			- # of samples
% 			- onset, offset time of sound
% 			- onset, offset sample (aka bin) of sound
% 	4) apply short onset/offset ramp to ensure start and end of stimulus are 
%		0 and smooth onset and offset
%-------------------------------------------------------------------------
% Revisions:
% 22 Apr 2019 (SJS): added comments
%-------------------------------------------------------------------------
% wav data
wavS0 = cell(nWavs, 1);
% original sampling rate
tmpFs = zeros(nWavs, 1);
% loop through wavs
for n = 1:nWavs
	tmpfile = fullfile(audio.signal.WavPath, wavInfo(n).Filename);
	[wavS0{n}, tmpFs(n)] = audioread(tmpfile);
	% need to make sure wav data is in row vector form
	if ~isrow(wavS0{n})
		wavS0{n} = wavS0{n}';
	end
	% check to make sure sample rate of signal matches
	% hardware output sample rate
	if outFs ~= tmpFs(n)
		% if not, resample...
		fprintf('Resampling %s\n', wavInfo(n).Filename);
		wavS0{n} = correctFs(wavS0{n}, tmpFs(n), outFs);
		% and adjust other information
		wavInfo(n).SampleRate = outFs; %#ok<*SAGROW>
		wavInfo(n).TotalSamples = length(wavS0{n});
		onsettime = wavInfo(n).OnsetBin / tmpFs(n);
		offsettime = wavInfo(n).OffsetBin / tmpFs(n);
		wavInfo(n).OnsetBin = ms2bin(1000*onsettime, outFs);
		wavInfo(n).OffsetBin = ms2bin(1000*offsettime, outFs);
	end
	% apply *short* 1 ms duration ramp to ensure wav start and end is 0
	wavS0{n} = sin2array(wavS0{n}, 1, outFs);
end