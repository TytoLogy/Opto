%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Experiment settings
%-------------------------------------------------------------------------
%----------------------------------------------------------
% Presentation settings - ISI, # reps, randomize, etc.
%----------------------------------------------------------
test.Reps = 10;
test.Randomize = 1;
test.Block = 0;
audio.ISI = 200;
%------------------------------------
% Experiment settings
%------------------------------------
% save output stimuli? (0 = no, 1 = yes)
test.saveStim = 0;
%------------------------------------
% acquisition/sweep settings
% will have to be adjusted to deal with wav file durations
%------------------------------------
test.AcqDuration = 500;
test.SweepPeriod = test.AcqDuration + 5;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%% define stimulus (optical, audio) structs
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%------------------------------------
% OPTICAL settings
%	Enable	0 -> optical stim OFF, 1 -> optical stim ON
%	Delay		onset of optical stim from start of sweep (ms)
% 	Dur		duration (ms) of optical stimulus
% 	Amp		amplitude (mV) of optical stim
% 					*** IMPORTANT NOTE ***
% 					This method of amplitude control will only work with the 
% 					Thor Labs fiber-coupled LED driver.
% 					For the Shanghai Dream Laser, output level can only be 
% 					controlled using the rotary potentiometer on the Laser power
% 					supply. If using the Shanghai Dream Laser for stimulation,
% 					set Amp to 5000 millivolts (5 V)
% 
% 	To test a range of values (for Delay, Dur, Amp), use a vector of values
% 	instead of a single number (e.g., [20 40 60] or 20:20:60)
%------------------------------------
% opto.Enable = 1;
% opto.Delay = 100;
% opto.Dur = 100;
% opto.Amp = 250;
opto.Enable = 0;
opto.Delay = 0;
opto.Dur = 200;
opto.Amp = 0;
%------------------------------------
% AUDITORY stimulus settings
%------------------------------------
%------------------------------------
% general audio properties
%------------------------------------
% Delay 
audio.Delay = 100;
% Duration is variable for WAV files - this information
% will be found in the audio.signal.WavInfo
% For now, this will be a dummy value
audio.Duration = 200;
audio.Level = 80;
audio.Ramp = 5;
audio.Frozen = 0;
%------------------------------------
% noise signal
%------------------------------------
noise.signal.Type = 'noise';
noise.signal.Fmin = 4000;
noise.signal.Fmax = 80000;
noise.Delay = audio.Delay;
noise.Duration = 100;
noise.Level = 80;
noise.Ramp = 5;
noise.Frozen = 0;
%------------------------------------
% null signal
%------------------------------------
null.signal.Type = 'null';
null.Delay = audio.Delay;
null.Duration = noise.Duration;
null.Level = 0;
%------------------------------------
% WAV
%------------------------------------
WavesToPlay = {	'MFV_NL_filtered_normalized.wav', ...
						'MFV_harmonic_normalized.wav', ...
						'MFV_tonal_normalized.wav', ...
						'chevron_nl_USV.wav', ...
						'matingcontext_LFHUSV_3.wav', ...
						'matingcontext_LFHUSV_7.wav', ...
						'matingcontext_LFHUSV_8.wav', ...
						'matingcontext_USV_1.wav', ...
						'matingcontext_USV_2.wav', ...
					};
nWavs = length(WavesToPlay);
% and scaling factors (to achieve desired amplitude)
% % % temporarily use 1 as scaling factor - fix after calibration!!!
WavScaleFactors = ones(nWavs, 1);
% orig from calibration
% WavScaleFactors = [	2.5, ... 
% 							1, ...
% 							1, ...
%  							2	...
% 						];
% WavScaleFactors = [	1.953, ...
% 							2.173, ...
% 							4.436, ...
% 							1.872, ...
% 							1.703, ...
% 							1.292, ...
% 							2.120, ...
% 							2.553, ...
% 							2.765 ...
% 						];

audio.signal.Type = 'wav';
audio.signal.WavPath = 'C:\TytoLogy\Experiments\Wavs';
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
%------------------------------------
% create list of filenames - need to do a bit of housekeeping
%------------------------------------
audio.signal.WavFile = cell(nWavs, 1);
tmp = {};
[tmp{1:nWavs, 1}] = deal(wavInfo.Filename);
% assign wav filenames to wavInfo (if they already have .wav attached, this
% should not affect things due to use of fileparts function to extract
% basename from file name in wavInfo)
for n = 1:nWavs
	[~, basename] = fileparts(tmp{n});
	audio.signal.WavFile{n} = [basename '.wav'];
	% make sure Filename in wavInfo matches
	wavInfo(n).Filename = audio.signal.WavFile{n};
	wavInfo(n).ScaleFactor = WavScaleFactors(n);
end
clear tmp;

%% check durations of wav files
wavDurs = zeros(size(nWavs));
for n = 1:nWavs
	wavDurs(n) = wavInfo(n).Duration * 1000;
end
wavDurs = ceil(wavDurs);
[maxdur, maxind] = max(wavDurs);
if max(wavDurs) > audio.Delay + test.AcqDuration
	warning('Wav Duration exceeds delat + sweep acquisition time!')
	fprintf('Wav: %s\n', wavInfo(maxind).Filename);
	fprintf('Wav Duration (ms): %.1f\n', wavInfo(maxind).Duration * 1000);
	fprintf('Delay + Sweep (ms): %d\n', audio.Delay + test.AcqDuration);
end
