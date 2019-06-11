function varargout = condition_wavs(W, outFs)
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
if nargin ~= 2
	error('%s: need wav struct and output Fs', mfilename);
end

% allocate wav data
% wavforms
W.wavS0 = cell(W.nWavs, 1);
% original sampling rate
tmpFs = zeros(W.nWavs, 1);

% loop through wavs
for n = 1:W.nWavs
	tmpfile = fullfile(W.WavPath, W.wavInfo(n).Filename);
	[W.wavS0{n}, tmpFs(n)] = audioread(tmpfile);
	% need to make sure wav data is in row vector form
	if ~isrow(W.wavS0{n})
		W.wavS0{n} = W.wavS0{n}';
	end
	% check to make sure sample rate of signal matches
	% hardware output sample rate
	if outFs ~= tmpFs(n)
		% if not, resample...
		fprintf('Resampling %s\n', W.wavInfo(n).Filename);
		W.wavS0{n} = correctFs(W.wavS0{n}, tmpFs(n), outFs);
		% and adjust other information
		W.wavInfo(n).SampleRate = outFs; %#ok<*SAGROW>
		W.wavInfo(n).TotalSamples = length(W.wavS0{n});
		onsettime = W.wavInfo(n).OnsetBin / tmpFs(n);
		offsettime = W.wavInfo(n).OffsetBin / tmpFs(n);
		W.wavInfo(n).OnsetBin = ms2bin(1000*onsettime, outFs);
		W.wavInfo(n).OffsetBin = ms2bin(1000*offsettime, outFs);
	end
	if isfield(W, 'WavRamp')
		if W.WavRamp > 0
			% apply specified ramp
			W.wavS0{n} = sin2array(W.wavS0{n}, W.WavRamp, outFs);
		else
			% apply *short* 1 ms duration ramp to ensure wav start and end is 0
			W.WavRamp = 1;
			W.wavS0{n} = sin2array(W.wavS0{n}, 1, outFs);
		end
	else
		% apply *short* 1 ms duration ramp to ensure wav start and end is 0
		W.WavRamp = 1;
		W.wavS0{n} = sin2array(W.wavS0{n}, 1, outFs);
	end
end

varargout{1} = W;