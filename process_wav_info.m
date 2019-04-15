function wavInfo = process_wav_info(audio)

%------------------------------------
% wav properties
%------------------------------------
% select only waves in list
% get information about stimuli
AllwavInfo = getWavInfo(fullfile(audio.signal.WavPath, 'wavinfo.mat'));
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
% and, using filenames, select only wav files in list WavesToPlay
wavInfo = repmat( AllwavInfo(1), length(WavesToPlay), 1);
for w = 1:length(WavesToPlay)
	wavInfo(w) = AllwavInfo(strcmp(WavesToPlay(w), AllwavNames));
end
%--------------------------------------------------------------------
% create list of filenames - need to do a bit of housekeeping
%--------------------------------------------------------------------
audio.signal.WavFile = cell(nWavs, 1);
tmp = {};
[tmp{1:nWavs, 1}] = deal(wavInfo.Filename);
% assign wav filenames to wavInfo
for n = 1:nWavs
	[~, basename] = fileparts(tmp{n});
	audio.signal.WavFile{n} = [basename '.wav'];
	% make sure Filename in wavInfo matches
	wavInfo(n).Filename = audio.signal.WavFile{n};
	% assign scaling factor
	wavInfo(n).ScaleFactor = WavScaleFactors(n);
end
clear tmp;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% build list of stimuli
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% varied variables for opto and audio
optovar = opto.Amp;
audiowavvar = audio.signal.WavFile;
% total # of varied variables = # opto vars * # audio vars
nCombinations = numel(optovar) * (numel(audiowavvar));
% # of total trials;
nTotalTrials = nCombinations * test.Reps;
% create list to hold parameters for varied variables
stimList = repmat(	...
							struct(	'opto', opto, ...
										'audio', audio ...
									), ...
							nCombinations, 1);
% assign values - in this case, inner loop cycles through audio variables,  
% outer loop cycles through optical variables
sindex = 0;
for oindex = 1:numel(optovar)
	for aindex = 1:(numel(audiowavvar))
		sindex = sindex + 1;
		stimList(sindex).opto.Amp = optovar(oindex);
		stimList(sindex).audio.signal.WavFile = audiowavvar{aindex};
	end
end
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% randomize in blocks (if necessary) by creating a randomized list of 
% indices of the different stimuli within stimList
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
if test.Randomize
	% assign random permutations to stimindices
	disp('Randomizing stimulus order');
	[stimIndices, repList] = ...
					buildStimIndices(nTotalTrials, nCombinations, test.Reps, ...
											1, 0);
elseif isfield(test, 'Block')
	if test.Block == 1
		disp('Blocked stimulus order')
		[stimIndices, repList] = ...
					buildStimIndices(nTotalTrials, nCombinations, test.Reps, ...
											0, 1);

	else
		% assign sequential indices to stimindices
		disp('Sequential stimulus order');
		[stimIndices, repList] = ...
					buildStimIndices(nTotalTrials, nCombinations, test.Reps, ...
											0, 0);
	end
else
	% assign sequential indices to stimindices
	disp('Sequential stimulus order');
		[stimIndices, repList] = ...
					buildStimIndices(nTotalTrials, nCombinations, test.Reps, ...
											0, 0);
end	% END if test.Randomize

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% some stimulus things
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% check durations of wav stimuli
% first, create a vector stimulus durations
[tmp{1:numel(audiowavvar)}] = deal(wavInfo.Duration);
durations = cell2mat(tmp);
clear tmp;
maxDur = max(1000*durations);
if maxDur > test.AcqDuration
	error('%s: max wav duration (%d) is > AcqDuration (%d)', mfilename, ...
							maxDur, test.AcqDuration);
end

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% If noise is frozen, save noise spectrum for future synthesis
% need to do this AFTER stimList has been built to avoid using up
% extra memory
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
if noise.Frozen
	[noise.signal.S0, noise.signal.Smag0, noise.signal.Sphase0] = ...
								synmononoise_fft(noise.Duration, outdev.Fs, ...
															noise.signal.Fmin, ...
															noise.signal.Fmax, ...
															caldata.DAscale, caldata);
	% ramp the sound on and off (important!) and compute RMS
	noise.signal.S0 = sin2array(noise.signal.S0, noise.Ramp, outdev.Fs);
	noise.signal.rms = rms(noise.signal.S0);
end

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% calculations of samples for various things
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% First, get the # of points to send out and to collect
% for multi-channel data, the number of samples will be
% given by the product of the # channels and # sample in the acquisition
% period (tdt.nChannels * AcqDuration * Fs / 1000)
% acqpts = tdt.nChannels * ms2samples(tdt.AcqDuration, indev.Fs);
%
% ¡¡¡ Note that if stimulus duration is a variable, this will have to put
% within the stimulus output loop!!!
%-------------------------------------------------------------------------
acqpts = ms2samples(test.AcqDuration, indev.Fs);
% outpts = ms2samples(audio.Duration, outdev.Fs); 
% stimulus start and stop in samples
% stim_start = ms2samples(audio.Delay, outdev.Fs);
% stim_end = stim_start + ms2samples(audio.Duration, outdev.Fs); 

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% initialize some cells and arrays for storing data and variables
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% resp = raw data traces
resp = cell(nTotalTrials, 1);
	
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%  setup hardware
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
standalone_setuphardware

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Load and condition wav stimuli
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
standalone_condition_wavs
