function [curvedata, varargout] = wav_opto(handles, datafile)
%--------------------------------------------------------------------------
% [curvedata, rawdata] = wav_opto(handles, datafile)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% Standalone experiment script (relies on hardware setup in handles)
% Demonstrates playback of .WAV format files (assume 16 bit, uncompressed)
%
% Designed for versions of Matlab that have the audioread() function
% (v. 2015 and higher ????)
%
%--------------------------------------------------------------------------
% Input Arguments:
%	H		exp handles from calling gui (H)
%	datafile		name (full path + '.dat' filename) for data
% 
% Output Arguments:
% 	curvedata	data structure	
% 	rawdata		raw response data cell array
% 					{nTrials, nreps}
%
%--------------------------------------------------------------------------
% See Also: noise_opto, opto, opto_playCache
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Sharad J. Shanbhag
%	based on HPCurve_playCache developed 
% 	by Sharad Shanbhag & Jose Luis Pena
% sshanbhag@neomed.edu
% jpena@einstein.edu
%--------------------------------------------------------------------------
% Created:	31 March, 2017 (SJS) from noise_opto
%
% Revision History:
%	31 March, 2017 (SJS) created from noise_opto
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

disp 'running wav_opto!'
curvetype = 'Wav+Opto';

%--------------------------------------------------------
%--------------------------------------------------------
% settings and constants
%--------------------------------------------------------
%--------------------------------------------------------
L = 1;
R = 2; %#ok<NASGU>
MAX_ATTEN = 120; 
% assign temporary outputs
curvedata = []; 
if nargout > 1
	varargout = {};
end

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% local copies of structs and vars
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%------------------------------------
% hardware structs
%------------------------------------
indev = handles.H.TDT.indev;
outdev = handles.H.TDT.outdev;
zBUS = handles.H.TDT.zBUS;
channels = handles.H.TDT.channels;
%------------------------------------
% function handles
%------------------------------------
% setattenfunc is the method to set output signal attenuation
setattenfunc = handles.H.TDT.config.setattenFunc;
% iofunc is used for stimulus output, spike input
iofunc = handles.H.TDT.config.ioFunc;
%------------------------------------
% calibration data
%------------------------------------
caldata = handles.H.caldata;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Experiment settings
%-------------------------------------------------------------------------
%------------------------------------
% Presentation settings
%------------------------------------
test.Reps = 40;
test.Randomize = 0;
audio.ISI = 1;
%------------------------------------
% Experiment settings
%------------------------------------
% save output stimuli? (0 = no, 1 = yes)
test.saveStim = 0;
%------------------------------------
% acquisition/sweep settings
% will have to be adjusted to deal with wav file durations
%------------------------------------
test.AcqDuration = 250;
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
opto.Amp = 2000;
%------------------------------------
% AUDITORY stimulus settings
%------------------------------------
%------------------------------------
% noise signal
%------------------------------------
noise.signal.Type = 'noise';
noise.signal.Fmin = 4000;
noise.signal.Fmax = 80000;
noise.Delay = 100;
noise.Duration = 100;
noise.Level = 80;
noise.Ramp = 5;
noise.Frozen = 0;
%------------------------------------
% null signal
%------------------------------------
null.signal.Type = 'null';
null.Delay = 100;
null.Duration = noise.Duration;
null.Level = 0;
%------------------------------------
% WAV
%------------------------------------
% Specify wav signal(s)
WavesToPlay = {	'MFV_tonal_normalized.wav', ...
						'P100_11_Noisy.wav', ...
						'P100_1_Flat_USV.wav', ...
						'P100_9_LFH.wav' ...
					};
nWavs = length(WavesToPlay);
% and scaling factors (to achieve desired amplitude)
WavScaleFactors = [	2.5, ... 
							1, ...
							1, ...
							2	...
						];
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
% assign wav filenames to wavInfo
for n = 1:nWavs
	[~, basename] = fileparts(tmp{n});
	audio.signal.WavFile{n} = [basename '.wav'];
	% make sure Filename in wavInfo matches
	wavInfo(n).Filename = audio.signal.WavFile{n};
	wavInfo(n).ScaleFactor = WavScaleFactors(n);
end
clear tmp;
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

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% build list of unique stimuli
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% varied variables for opto and audio
optovar = opto.Amp;
audiowavvar = audio.signal.WavFile;
% total # of varied variables (increase # of audio vars by 2
% to account for additional noise and null stimuli)
nCombinations = numel(optovar) * (numel(audiowavvar) + 2);
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
	for aindex = 1:(numel(audiowavvar) + 2)
		sindex = sindex + 1;
		stimList(sindex).opto.Amp = optovar(oindex);
		% assign audio stim 1 to null
		if aindex == 1
			stimList(sindex).audio = null;
		% assign audio stim 2 to noise
		elseif aindex == 2
			stimList(sindex).audio = noise;
		else
			stimList(sindex).audio.signal.WavFile = audiowavvar{aindex-2};
		end
	end
end
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% randomize in blocks (if necessary) by creating a randomized list of 
% indices of the different stimuli within stimList
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% preallocate stimIndices
stimIndices = zeros(nTotalTrials, 1);
% and assign values
if test.Randomize
	% assign random permutations to stimindices
	disp('Randomizing stimulus order');
	for r = 1:test.Reps
		stimIndices( (((r-1)*nCombinations) + 1):(r*nCombinations) ) = ...
							randperm(nCombinations);
	end
else
	% assign blocked indices to stimindices
	disp('NON random stimulus order');
	for r = 1:test.Reps
		stimIndices( (((r-1)*nCombinations) + 1):(r*nCombinations) ) = ...
							1:nCombinations;
	end
end

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
%--------------------------------------------------------
% STIMULUS and Acquisition (timing)
%--------------------------------------------------------
% query the sample rate from the circuit - do this instead of using the
% stored Fs within indev and outdev in order to ensure accuracy!
inFs = RPsamplefreq(indev);
outFs = RPsamplefreq(outdev);
% Set the Stimulus Delay (might be adjusted for each wav file in loop)
RPsettag(outdev, 'StimDelay', ms2bin(audio.Delay, outFs));
% Set the Stimulus Duration
RPsettag(outdev, 'StimDur', ms2bin(audio.Duration, outFs));
% Set the length of time to acquire data
RPsettag(indev, 'AcqDur', ms2bin(test.AcqDuration, inFs));
% Set the total sweep period time - input
RPsettag(indev, 'SwPeriod', ms2bin(test.SweepPeriod, inFs));
% Set the total sweep period time - output
RPsettag(outdev, 'SwPeriod', ms2bin(test.SweepPeriod, outFs));
% Set the sweep count to 1
RPsettag(indev, 'SwCount', 1);
RPsettag(outdev, 'SwCount', 1);
%--------------------------------------------------------
% Input Filtering
%--------------------------------------------------------
% set the high pass filter
RPsettag(indev, 'HPFreq', handles.H.TDT.HPFreq);
% set the low pass filter
RPsettag(indev, 'LPFreq', handles.H.TDT.LPFreq);
%--------------------------------------------------------
% Gain Settings
%--------------------------------------------------------
% set the overall gain for input
RPsettag(indev, 'Gain', handles.H.TDT.CircuitGain);
%--------------------------------------------------------
% Audio monitor
%--------------------------------------------------------
% set electrode channel to monitor via audio output
RPsettag(indev, 'MonChan', channels.MonitorChannel);
% set monitor gain
RPsettag(indev, 'MonGain', handles.H.TDT.MonitorGain);
% set output channel for audio monitor (channel 9 on RZ5D 
% is dedicated to the built-in audio speaker/monitor)
RPsettag(indev, 'MonOutChan', channels.MonitorOutputChannel);
% turn on audio monitor for spikes using software trigger 1
RPtrig(indev, 1);
%--------------------------------------------------------
% attenuation - set to MAX_ATTEN, un-mute
%--------------------------------------------------------
RPsettag(outdev, 'AttenL', MAX_ATTEN);
RPsettag(outdev, 'AttenR', MAX_ATTEN);
RPsettag(outdev, 'Mute', 0);


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

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Write data file header - this will create the binary data file
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% add elements to test for storage
test.stimIndices = stimIndices;
test.nCombinations = nCombinations;
test.optovar_name = 'Amp';
test.optovar = opto.Amp;
test.audiovar_name = 'WavFile';
test.audiovar = audio.signal.WavFile;
% and write header to data file
writeOptoDataFileHeader(datafile, test, audio, opto, channels, ...
								 caldata, indev, outdev);
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Write wav information to mat file
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% create mat filename
[fpath, fname] = fileparts(datafile);
matfile = fullfile(fpath, [fname '_wavinfo.mat']);
save(matfile, 'audio', 'noise', 'null', ...
					'stimList', 'stimIndices', 'wavInfo', ...
					'wavS0', '-MAT');


%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Set up figure for plotting incoming data
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% generate figure, axes
if isempty(handles.H.fH) || ~ishandle(handles.H.fH)
	handles.H.fH = figure;
end
if isempty(handles.H.ax) || ~ishandle(handles.H.ax)
	handles.H.ax = axes;
end
% store local copy of figure handle for simplicity in calls
fH = handles.H.fH;
% create/switch focus to figure, generate axis
figure(fH);
ax = handles.H.ax;
% set up plot
% calculate # of points to acquire (in units of samples)
xv = linspace(0, test.AcqDuration, acqpts);
xlim([0, acqpts]);
yabsmax = 5;
tmpData = zeros(acqpts, channels.nInputChannels);
for n = 1:channels.nInputChannels
	tmpData(:, n) = n*(yabsmax) + 2*(2*rand(acqpts, 1)-1);
end
pH = plot(ax, xv, tmpData);
yticks_yvals = yabsmax*(1:channels.nInputChannels);
yticks_txt = cell(channels.nInputChannels, 1);
for n = 1:channels.nInputChannels
	yticks_txt{n} = num2str(n);
end
ylim(yabsmax*[0 channels.nInputChannels+1]);
set(ax, 'YTick', yticks_yvals);
set(ax, 'YTickLabel', yticks_txt);
set(ax, 'TickDir', 'out');
set(ax, 'Box', 'off');
set(fH, 'Position', [861 204 557 800]);		
xlabel('Time (ms)')
ylabel('Channel')
set(ax, 'Color', 0.75*[1 1 1]);
set(fH, 'Color', 0.75*[1 1 1]);
set(fH, 'ToolBar', 'none');

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Main Data Loop
%--------------------------------------------------
% This is the core of the data acquisition and 
% stimulus presentation 
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Initialize cancel/pause button
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
[PanelHandle, cancelButton, pauseButton] = cancelpausepanel;

%--------------------------------------------------------
%--------------------------------------------------------
% Initialize flags and counters
%--------------------------------------------------------
%--------------------------------------------------------
% RasterIndex = RASTERLIM;
% flag to cancel experiment
cancelFlag = read_ui_val(cancelButton);
% flag to pause experiment
pauseFlag = 0; %#ok<NASGU>
% index through stimuli
sindex = 0;
% save stimuli?
if test.saveStim
	stimWriteFlag = 1; %#ok<NASGU>
else
	stimWriteFlag = 0; %#ok<NASGU>
end

%-------------------------------------------------------
%-------------------------------------------------------
% loop through stims
%-------------------------------------------------------
%-------------------------------------------------------
while ~cancelFlag && (sindex < nTotalTrials)
	%--------------------------------------------------
	% increment counter (was initialized to 0)
	%--------------------------------------------------
	sindex = sindex + 1;
	rep = ceil(sindex/nCombinations);
	
	%--------------------------------------------------
	% get current stimulus settings from stimList,using stimIndices to 
	% index into stimList
	%--------------------------------------------------
	fprintf('sindex: %d (%d)\n', sindex, nTotalTrials);
	fprintf('stimIndices(%d): %d\n', sindex, stimIndices(sindex));
	Stim = stimList(stimIndices(sindex));
	stimtype = Stim.audio.signal.Type;
	
	fprintf('sindex: %d\t rep: %d(%d)\tType: %s\n', sindex, rep, ...
						test.Reps, stimtype);
	fprintf('\taudio:\tDelay:%d\tLevel:%d', ...
			Stim.audio.Delay, Stim.audio.Level)
	if strcmpi(stimtype, 'wav')
		fprintf('\t%s\n', Stim.audio.signal.WavFile);
	else
		fprintf('\n');
	end
	fprintf('\topto:\tEnable:%d\tDelay:%d\tDur:%d\tAmp:%d\n', ...
			Stim.opto.Enable, Stim.opto.Delay, Stim.opto.Dur, Stim.opto.Amp)

	%--------------------------------------------------
	% set audio stimulus based on type
	%--------------------------------------------------
	switch(upper(stimtype))
		case 'NOISE'
			% noise, bandwidth determined by signal.Fmin,Fmax
			if ~Stim.audio.Frozen
				% synthesize stimulus de novo
				Sn = synmononoise_fft(Stim.audio.Duration, outdev.Fs, ...
												Stim.audio.signal.Fmin, ...
												Stim.audio.signal.Fmax, ...
												caldata.DAscale, caldata);
				% ramp the sound on and off (important!)
				Sn = sin2array(Sn, Stim.audio.Ramp, outdev.Fs);
				% compute rms value for use in setting SPL value
				rmsval = rms(Sn);
			else
				% use previously generated, "Frozen" noise
				Sn = noise.signal.S0;
				rmsval = noise.signal.rms;
			end
		case 'NULL'
			% no audio stimulus
			Sn = syn_null(Stim.audio.Duration, outdev.Fs, 0);
			% dummy rms val
			rmsval = 0;
		case 'WAV'
			% wav file.  locate waveform in wavS0{} cell array by
			% finding corresponding location of Stim.audio.signal.WavFile 
			% in the main audio struct, audio.signal.WavFile{}
			wavindex = find(strcmpi(Stim.audio.signal.WavFile, ...
												audio.signal.WavFile));
			Sn = wavS0{wavindex} * wavInfo(wavindex).ScaleFactor;
			% use peak rms value for figuring atten
			rmsval = wavInfo(wavindex).PeakRMS;
			% will need to apply a correction factor to OptoDelay
			% due to variability in in the wav stimulus onset
% 			optoDelayCorr = ms2bin( bin2ms( wavInfo(wavindex).OnsetBin, ...
% 								                 outdev.Fs ), ...
% 										   indev.Fs);
%  			optoDelayCorr = 0;

			% will need to apply a correction factor to OptoDelay
			% due to variability in in the wav stimulus onset
			% compute correction based on outdev.Fs
			optoDelayCorr = wavInfo(wavindex).OnsetBin;
			correctedDelay = ms2bin(Stim.audio.Delay, outFs) - optoDelayCorr;
			if correctedDelay < 0
				warning('%s: correctedDelay < 0! Using 0 as min value', ...
								mfilename);
				correctedDelay = 0;
			end
			% update the Stimulus Delay
			RPsettag(outdev, 'StimDelay', correctedDelay);
			
		otherwise
			fprintf('unknown type %s\n', stimtype);
			keyboard
	end
	
	% need to add dummy channel to Sn since iofunction needs stereo signal
	Sn = [Sn; zeros(size(Sn))]; %#ok<AGROW>
	% get the attenuator settings for the desired SPL
	atten = figure_mono_atten(Stim.audio.Level, rmsval, caldata);
	% set the attenuators
	setattenfunc(outdev, [atten 120]);
	
	% set opto stim
	if Stim.opto.Enable
		% turn on opto trigger
		RPsettag(indev, 'OptoEnable', 1);
		% set opto params
% 		% apply opto delay correction if WAV stim
% 		RPsettag(indev, 'OptoDelay', ...
% 							optoDelayCorr + ms2bin(Stim.opto.Delay, indev.Fs));
		% set opto Delay
		RPsettag(indev, 'OptoDelay', ms2bin(Stim.opto.Delay, indev.Fs));
		% set opto stimulus duration
		RPsettag(indev, 'OptoDur', ...
								ms2bin(Stim.opto.Dur, indev.Fs));
		% set opto stimulus Amplitude (need to convert to Volts!!)
		RPsettag(indev, 'OptoAmp', 0.001*Stim.opto.Amp);
	else
		% ensure opto trigger is OFF
		RPsettag(indev, 'OptoEnable', 0);
	end

	% play the sound and return the response
	try
		[rawdata, ~] = iofunc(Sn, acqpts, indev, outdev, zBUS);
	catch
		keyboard
	end
	
	% demux the response if necessary and store response data in cell array
	% 	Note: by indexing the response using row values from the 
	% 	trialRandomSequence array, the resp{} data will be in SORTED form!
	if channels.nInputChannels > 1
		% demultiplex the returned vector and store the response
		% mcDeMux returns an array that is [nChannels, nPoints]
		tmpD = mcFastDeMux(rawdata, channels.nInputChannels);
		resp{stimIndices(sindex)} = tmpD;
		recdata = tmpD(:, channels.RecordChannelList);
	else
		resp{stimIndices(sindex)} =  rawdata;
		recdata = rawdata;
	end

	% Save Data
	writeOptoTrialData(datafile, ...
								recdata, ...
								[Stim.audio.Level Stim.opto.Amp], ...
								sindex, rep);

	% This is code for letting the user know what in
	% tarnation is going on in text at bottom of window
	wtype = '';
	if strcmpi(stimtype, 'wav')
		wtype = sprintf('%s', Stim.audio.signal.WavFile);
	end
	if Stim.opto.Enable
		wtype = [wtype sprintf('+ Opto %d mV', Stim.opto.Amp)]; %#ok<AGROW>
	end
	optomsg(handles, sprintf('%s, %s repetition = %d  atten = %.0f', ...
								curvetype, [stimtype ' ' wtype], rep, atten(L)) );
	% also, create title for plot for more info
	tstr = {sprintf('%s: %d  Rep: %d(%d)  Atten:%.0f', ...
								curvetype, sindex, rep, test.Reps, atten(L)), ...
				sprintf('Type: %s %s', stimtype, wtype)};
 	title(ax, tstr, 'Interpreter', 'none');
							
	% build data matrix to plot from filtered data
	[monresp, ~] = opto_readbuf(indev, 'monIndex', 'monData');
	[pdata, ~] = mcFastDeMux(monresp, channels.nInputChannels);
	for c = 1:channels.nInputChannels
		if channels.RecordChannels{c}
			tmpY = pdata(:, c)';
		else
			tmpY = -1e6*ones(size(pdata(:, c)'));
		end
		% update plot
		set(pH(c), 'YData', tmpY + c*yabsmax);
	end
	drawnow

	% check state of cancel button
	cancelFlag = read_ui_val(cancelButton);

	% check state of pause button
	pauseFlag = read_ui_val(pauseButton);
	while pauseFlag
		pauseFlag = read_ui_val(pauseButton);
		update_ui_str(pauseButton, 'PAUSED');
		drawnow;
	end
	update_ui_str(pauseButton, 'Pause');

	% pause for the inter-stimulus interval
	pause(0.001*audio.ISI);
end %%% End of REPS LOOP
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% check if loop was completed or user-cancelled
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
if cancelFlag
	optomsg(handles, 'Test Stopped');
else
	optomsg(handles, 'Test Complete!');
end

%--------------------------------------------------------
%--------------------------------------------------------
% get time stamp
%--------------------------------------------------------
%--------------------------------------------------------
time_end = now;

%--------------------------------------------------------
%--------------------------------------------------------
% write the end of data file
%--------------------------------------------------------
%--------------------------------------------------------
closeOptoTrialData(datafile, time_end);

%--------------------------------------------------------
%--------------------------------------------------------
% setup output data structure
%--------------------------------------------------------
%--------------------------------------------------------
if ~cancelFlag
% 	curvedata.depvars = depvars;
% 	curvedata.depvars_sort = depvars_sort;
% 	if stimcache.saveStim
% 		[pathstr, fbase] = fileparts(datafile);
% 		curvedata.stimfile = fullfile(pathstr, [fbase '_stim.mat']);
% 	end
end
if nargout == 2
	varargout{1} = resp;
end

%--------------------------------------------------------
%--------------------------------------------------------
% clean up
%--------------------------------------------------------
%--------------------------------------------------------
% close curve panel
close(PanelHandle)
% turn off monitor using software trigger 2 sent to indev
RPtrig(indev, 2);

%--------------------------------------------------------
%--------------------------------------------------------
% save cancel flag status in curvedata
%--------------------------------------------------------
%--------------------------------------------------------
curvedata.cancelFlag = cancelFlag;
	