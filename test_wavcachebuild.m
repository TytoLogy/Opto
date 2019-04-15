%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% test_stimcachebuild
%	tests opto_buildStimCache
%	rev. 15 Apr, 2019 (SJS)
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% define stimulus (optical, audio) structs
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
opto.Enable = 0;
opto.Delay = 0;
opto.Dur = 100;
opto.Amp = 0:25:100;
%------------------------------------
% Auditory stimulus settings
%------------------------------------
% signal
% for wav: 
%------------------------------------
% WAV
%------------------------------------
% Specify wav signal(s)
audio.signal.Type = 'wav';
audio.signal.WavPath = 'C:\TytoLogy\Experiments\Wavs';
audio.signal.WavesToPlay = {	'MFV_NL_filtered_normalized.wav', ...
						'MFV_harmonic_normalized.wav', ...
						'MFV_tonal_normalized.wav', ...
						'chevron_nl_USV.wav', ...
						'matingcontext_LFHUSV_3.wav', ...
						'matingcontext_LFHUSV_7.wav', ...
						'matingcontext_LFHUSV_8.wav', ...
						'matingcontext_USV_1.wav', ...
						'matingcontext_USV_2.wav', ...
					};
% and scaling factors (to achieve desired amplitude)
% % % temporarily use 1 as scaling factor - fix after calibration!!!
audio.signal.WavScaleFactors = ...
						ones(length(test.audio.signal.WavesToPlay, 1));
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
audio.Delay = 100;
% this will be adjusted later, but for now, fill in place holder
audio.Duration = 200;
% output levels desired
audio.Level = 0:30:60;
audio.Ramp = 1;
%------------------------------------
% Presentation settings
%------------------------------------
Reps = 2;
Randomize = 0;
Block = 1;
audio.ISI = 1000;

%------------------------------------
% Experiment settings
%------------------------------------
% save output stimuli? (0 = no, 1 = yes)
saveStim = 0;

%------------------------------------
% acquisition/sweep settings
%------------------------------------
% make sure this is long enough!
AcqDuration = 1000;
SweepPeriod = 1001;

%------------------------------------
% TDT settings
%------------------------------------
outdev.Fs = 200000;
%----------------------------------------------------------------
% Calibration data
%----------------------------------------------------------------
if ispc
	calpath = '..\CalData';
else
	calpath = '../CalData';
end
% calfile = 'Optorig_20170601_TDT3981_4k90k_5V_cal.mat';
calfile = 'Optorig_20171022_TDT3981_4k-91k_5V_cal.mat';
if ~exist(fullfile(calpath, calfile), 'file')
	warning('Calibration file %s not found!', fullfile(calpath, calfile));
	fprintf('\nUsing fake cal data\n');
	caldata = fake_caldata('Fs', outdev.Fs, 'calshape', 'flat', ...
														'freqs', 4000:1000:200000, ...
														'DAscale', 5);
else
	% load the calibration data
	caldata = load_cal(fullfile(calpath, calfile));
end

%-------------------------------------------------------------------------
% assign values to required structs
%-------------------------------------------------------------------------
test = struct(	'audio',audio, ...
					'opto', opto, ...
					'Reps', Reps, ...
					'Randomize', Randomize, ...
					'Block', Block, ...
					'saveStim', saveStim, ...
					'Type', 'WAV+LEVEL', ...
					'Name', 'WAV');
tdt = struct('outdev', outdev);

%{
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% build list of unique stimuli
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% varied variables for opto and audio
optovar = opto.Amp;
audiovar = audio.Level;
% total # of varied variables
nCombinations = numel(optovar) * numel(audiovar);
% create list to hold parameters for varied variables
stimList = repmat(	...
							struct(	'opto', opto, ...
										'audio', audio ...
									), ...
							nCombinations, 1);
% assign values - in this case, inner loop cycles through audio variables,  
% outer loop cycles through optical variables
sindex = 1;
for oindex = 1:numel(optovar)
	for aindex = 1:numel(audiovar)
		stimList(sindex).opto.Amp = optovar(oindex);
		stimList(sindex).audio.Level = audiovar(aindex);
		sindex = sindex + 1;
	end
end
%}

%% test build cache

[C, S] = opto_buildStimCache(test, tdt, caldata)


%% other stuff
%{
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% randomize in blocks (if necessary) by creating a randomized list of 
% indices of the different stimuli within stimList
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% preallocate stimIndices using total number of stimulus presentations
stimIndices = zeros(nCombinations * Reps, 1);
% and assign values
if Randomize
	% assign random permutations to stimindices
	for r = 1:Reps %#ok<*UNRCH>
		stimIndices( (((r-1)*nCombinations) + 1):(r*nCombinations) ) = ...
							randperm(nCombinations);
	end
else
	% assign blocked indices to stimindices
	for r = 1:Reps
		stimIndices( (((r-1)*nCombinations) + 1):(r*nCombinations) ) = ...
							1:nCombinations;
	end
end

[S, R] = buildStimIndices(nCombinations*Reps, nCombinations, Reps, Randomize, Block);
%}
