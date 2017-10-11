function outdata = OptoInhib(handles, datafile)
%--------------------------------------------------------------------------
% outdata = OptoInhib(handles, datafile)
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
%	handles		exp handles from calling gui (H)
%	datafile		name (full path + '.dat' filename) for data
% 
% Output Arguments:
% 	outdata{1}	curvedata structure	
% 	outdata{2}	rawdata		raw response data cell array
% 					{nTrials, nreps}
%	outdata{3}	handles
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
%	12 Jun 2017 (SJS): pulled off common elements into separate subscripts
%	13 Jun 2017 (SJS): working on separate psths for each stimulus 
%	15 Jun 2017 (SJS): fixed stimulus delay problem
%	16 Jun 2017 (SJS): added pre, post background collection
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

disp(['running ' mfilename])

%--------------------------------------------------------
%--------------------------------------------------------
% settings and constants
%--------------------------------------------------------
%--------------------------------------------------------
L = 1;
R = 2; %#ok<NASGU>
MAX_ATTEN = 120;  %#ok<NASGU>
% assign temporary outputs
outdata = {};

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
test.Name = handles.H.test.Name;
test.Reps = 5;
test.Randomize = 1;
test.Block = 0;
audio.ISI = 300;
%------------------------------------
% Experiment settings
%------------------------------------
% save output stimuli? (0 = no, 1 = yes)
test.saveStim = 0;
%------------------------------------
% acquisition/sweep settings
% will have to be adjusted to deal with wav file durations
%------------------------------------
test.AcqDuration = 1000;
test.SweepPeriod = test.AcqDuration + 5;
test.PreStimulusTime = handles.H.test.PreStimulusTime;
test.PostStimulusTime = handles.H.test.PostStimulusTime;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%% define stimulus (optical, audio) structs
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
opto = handles.H.test.opto;
if opto.Enable
	curvetype = 'OptoON';
else
	curvetype = 'OptoOFF';
end

%------------------------------------
% AUDITORY stimulus settings
%------------------------------------
%------------------------------------
% general audio properties
%------------------------------------
% Delay 
audio.Delay = 200;
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
% Specify wav signal(s)
WavesToPlay = {	'MFV_tonal_normalized.wav', ...
						'P100_11_Noisy.wav', ...
						'P100_1_Flat_USV.wav', ...
						'P100_9_LFH.wav' ...
					};
nWavs = length(WavesToPlay);
% and scaling factors (to achieve desired amplitude)
% from calibration 01 Jun 2017
WavScaleFactors = [	4.436, ... 
							1.872, ...
							1.703, ...
							2.765	...
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
standalone_write_wavinfomatfile;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Set up figure for plotting incoming data
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
standalone_setupplots;

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
[PanelHandle, cancelButton, pauseButton] = cancelpausepanel; %#ok<ASGLU>

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
% save stimuli?
if test.saveStim
	stimWriteFlag = 1; %#ok<NASGU>
else
	stimWriteFlag = 0; %#ok<NASGU>
end

%-------------------------------------------------------
%-------------------------------------------------------
% collect background
%-------------------------------------------------------
%-------------------------------------------------------
% set acq duration
% no audio stimulus
Sn = syn_null(100, outdev.Fs, 0);
% need to add dummy channel to Sn since iofunction needs stereo signal
Sn = [Sn; zeros(size(Sn))];
% set the attenuators
setattenfunc(outdev, [120 120]);
% ensure opto trigger is OFF
RPsettag(indev, 'OptoEnable', 0);
% Set the length of time to acquire data
RPsettag(indev, 'AcqDur', ms2bin(test.PreStimulusTime, inFs));
% Set the total sweep period time - input
RPsettag(indev, 'SwPeriod', ms2bin(test.PreStimulusTime + 5, inFs));
% Set the total sweep period time - output
RPsettag(outdev, 'SwPeriod', ms2bin(test.PreStimulusTime + 5, outFs));
% play the sound and return the response
try
	[rawdata, ~] = iofunc(Sn, ms2bin(test.PreStimulusTime, inFs), ...
															indev, outdev, zBUS);
	% get the spike response
	[spikes, nspikes] = opto_getspikes(indev); %#ok<ASGLU>
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
	recdata = tmpD(:, channels.RecordChannelList);
else
	recdata = rawdata;
end
% Save Data
% open the file for appending
fp = fopen(datafile, 'a');
% check to make sure this worked
if fp == -1
	% error occurred, return error code -1
	error('%s: data file error', mfilename);
end
% write a string that says 'PRE_BACKGROUND_BEGIN'
writeString(fp, 'PRE_BACKGROUND_BEGIN');
% write the data
writeOptoTrialData(datafile, ...
							recdata, ...
							[0 0], ...
							-1, -1);
% write a string that says 'PRE_BACKGROUND_END'
writeString(fp, 'PRE_BACKGROUND_END');
keyboard
clear recdata rawdata;
%-----------------------------------
% reset acq and sweep duration
%-----------------------------------
% Set the length of time to acquire data
RPsettag(indev, 'AcqDur', ms2bin(test.AcqDuration, inFs));
% Set the total sweep period time - input
RPsettag(indev, 'SwPeriod', ms2bin(test.SweepPeriod, inFs));
% Set the total sweep period time - output
RPsettag(outdev, 'SwPeriod', ms2bin(test.SweepPeriod, outFs));

%-------------------------------------------------------
%-------------------------------------------------------
% loop through stims
%-------------------------------------------------------
%-------------------------------------------------------
% index to stimuli
sindex = 0;
% loop until done or cancel button is pressed
while ~cancelFlag && (sindex < nTotalTrials)
	%--------------------------------------------------
	% increment counter (was initialized to 0)
	%--------------------------------------------------
	sindex = sindex + 1;
	%--------------------------------------------------
	% psth and stimulus index
	%--------------------------------------------------
	pIndx = stimIndices(sindex);
	%--------------------------------------------------
	% rep #s
	%--------------------------------------------------
	% get current rep;
	rep = repList(sindex);
	% increment current index
	currentRep(pIndx) = currentRep(pIndx) + 1; %#ok<AGROW>
	%--------------------------------------------------
	% get current stimulus settings from stimList,using stimIndices to 
	% index into stimList
	%--------------------------------------------------
	Stim = stimList(pIndx);
	stimtype = Stim.audio.signal.Type;	
% 	fprintf('sindex: %d (%d)\n', sindex, nTotalTrials);
% 	fprintf('stimIndices(%d): %d\n', sindex, pIndx);
	fprintf('sindex: %d(%d)\t rep: %d(%d)\tType: %s\n', sindex, nTotalTrials, rep, ...
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
			% update the Stimulus Delay
			RPsettag(outdev, 'StimDelay',  ms2bin(Stim.audio.Delay, outFs));
		case 'NULL'
			% no audio stimulus
			Sn = syn_null(Stim.audio.Duration, outdev.Fs, 0);
			% update the Stimulus Delay (useless for this, but for
			% consistency's sake....)
			RPsettag(outdev, 'StimDelay',  ms2bin(Stim.audio.Delay, outFs));
			% dummy rms val
			rmsval = 0;
		case 'WAV'
			% wav file.  locate waveform in wavS0{} cell array by
			% finding corresponding location of Stim.audio.signal.WavFile 
			% in the main audio struct, audio.signal.WavFile{}
			wavindex = find(strcmpi(Stim.audio.signal.WavFile, ...
												audio.signal.WavFile));
			Sn = wavS0{wavindex} * wavInfo(wavindex).ScaleFactor; %#ok<USENS>
			% use peak rms value for figuring atten
			rmsval = wavInfo(wavindex).PeakRMS;
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
% 		% apply opto delay correction if WAV stim (cancelling due to
% 		complication of what to do if opto delay == 0...)
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
		% get the spike response
		[spikes, nspikes] = opto_getspikes(indev); %#ok<ASGLU>
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
		resp{pIndx} = tmpD;
		recdata = tmpD(:, channels.RecordChannelList);
	else
		resp{pIndx} =  rawdata;
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
		wtype = sprintf('%s', Stim.audio.signal.WavFile(1:(end-4)));
	end
	if Stim.opto.Enable
		wtype = [wtype sprintf(' + Opto %d mV', Stim.opto.Amp)]; %#ok<AGROW>
	end
	optomsg(handles, sprintf('%s, %s repetition = %d  atten = %.0f', ...
								curvetype, [stimtype ' ' wtype], rep, atten(L)) );
	% also, create title for plot for more info
	tstr = {sprintf('%s: %d  Rep: %d(%d)  Atten:%.0f', ...
								curvetype, sindex, rep, test.Reps, atten(L)), ...
				sprintf('Type: %s %s', stimtype, wtype)};
 	title(aX, tstr, 'Interpreter', 'none');
							
	% build data matrix to plot from filtered data
	% get monitor data from buffer
	[monresp, ~] = opto_readbuf(indev, 'monIndex', 'monData');
	% demux input data matrices	
	[pdata, ~] = mcFastDeMux(monresp, channels.nInputChannels);
	% assign data to plot
	for c = 1:channels.nInputChannels
		if channels.RecordChannels{c}
			tmpY = pdata(:, c)';
		else
			tmpY = -1e6*ones(size(pdata(:, c)'));
		end
		% update plot
		set(pH(c), 'YData', tmpY + c*yabsmax);
	end
	% update plots
	refreshdata
	% show detected spikes
	% compute spike bins
	spikebins = getSpikebinsFromSpikes(spikes, handles.H.TDT.SnipLen);
	% assign spiketimes to currentRep within storage cell array
	SpikeTimes{pIndx}{currentRep(pIndx)} = (1000/indev.Fs) * spikebins; %#ok<AGROW>
	% draw new hash marks on sweep plot
	set(tH,	'XData', ...
					SpikeTimes{pIndx}{currentRep(pIndx)}, ...
				'YData', ...
					zeros(size(SpikeTimes{pIndx}{currentRep(pIndx)})) + ...
 							handles.H.TDT.channels.MonitorChannel*yabsmax);
	% update PSTH
	PSTH.hvals{pIndx} = psth(	SpikeTimes{pIndx}, ...
										binSize, ...
										[0 handles.H.TDT.AcqDuration]);
	set(pstBar(pIndx), 'YData', PSTH.hvals{pIndx});
	refreshdata;
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
% finish up
%--------------------------------------------------------
%--------------------------------------------------------
standalone_cleanup

	