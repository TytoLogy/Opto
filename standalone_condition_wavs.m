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
%	22 Apr 2019 (SJS): added comments
%	1 Oct 2019 (SJS): added comments
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
		fprintf('\t%.2f (original) -> %.2f (TDT output)\n', tmpFs(n), outFs);
		wavS0{n} = correctFs(wavS0{n}, tmpFs(n), outFs);
		% and adjust other information
		% store new sample rate
		wavInfo(n).SampleRate = outFs; %#ok<*SAGROW>
		% duration (# samples)
		wavInfo(n).TotalSamples = length(wavS0{n});
		% recalculate onset/offset time and sample (bin)
		onsettime = wavInfo(n).OnsetBin / tmpFs(n);
		offsettime = wavInfo(n).OffsetBin / tmpFs(n);
		wavInfo(n).OnsetBin = ms2bin(1000*onsettime, outFs);
		wavInfo(n).OffsetBin = ms2bin(1000*offsettime, outFs);
	end
	if exist('WavRamp', 'var')
		% if WavRamp was specified, apply it...
		if WavRamp > 0
			% apply specified ramp
			fprintf('Applying %d ms ramp to stimulus %s\n', ...
									WavRamp, wavInfo(n).Filename);
			wavS0{n} = sin2array(wavS0{n}, WavRamp, outFs);
		else
			% apply *short* 1 ms duration ramp to ensure wav start and end is 0
			fprintf('Applying 1ms ramp to stimulus %s\n', wavInfo(n).Filename);
			wavS0{n} = sin2array(wavS0{n}, 1, outFs);
		end
	else
		% apply *short* 1 ms duration ramp to ensure wav start and end is 0
		fprintf('Applying 1ms ramp to stimulus %s\n', wavInfo(n).Filename);
		wavS0{n} = sin2array(wavS0{n}, 1, outFs);
	end
% 	figure
% 	plot(wavS0{n});
% 	title(wavInfo(n).Filename, 'Interpreter', 'none');
% 	grid on
end