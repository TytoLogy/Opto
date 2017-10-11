%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Load and condition wav stimuli
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
wavS0 = cell(nWavs, 1);
tmpFs = zeros(nWavs, 1);
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
		wavInfo(n).SampleRate = outFs;
		wavInfo(n).TotalSamples = length(wavS0{n});
		onsettime = wavInfo(n).OnsetBin / tmpFs(n);
		offsettime = wavInfo(n).OffsetBin / tmpFs(n);
		wavInfo(n).OnsetBin = ms2bin(1000*onsettime, outFs);
		wavInfo(n).OffsetBin = ms2bin(1000*offsettime, outFs);
	end
	% apply *short* ramp to ensure wav start and end is 0
	wavS0{n} = sin2array(wavS0{n}, 1, outFs);
end