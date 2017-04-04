handles.H = opto_initH;
% function [curvedata, varargout] = wav_opto(handles, datafile)
%--------------------------------------------------------------------------
% [curvedata, rawdata] = noise_opto(handles, datafile)
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

%--------------------------------------------------------
%--------------------------------------------------------
% settings and constants
%--------------------------------------------------------
%--------------------------------------------------------
L = 1;
R = 2;
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
opto.Enable = 1;
opto.Delay = 0;
opto.Dur = 100;
opto.Amp = 0:25:100;
%------------------------------------
% Auditory stimulus settings
%
% list of all possible .wav files:
% 	LFH_1.wav
% 	LFH_2.wav
% 	LFH_3.wav
% 	MFV_1.wav
% 	MFV_2.wav
% 	MFV_3.wav
% 	noisy_1.wav
% 	noisy_2.wav
% 	noisy_3.wav
% 	p100_3_11_v1.wav
% 	p100_3_11_v2.wav
% 	p100_3_11_v3.wav
% 	P100_11.wav
%------------------------------------
% signal
audio.signal.Type = 'wav';
audio.signal.WavPath = 'C:\TytoLogy\Experiments\Wavs';
audio.signal.WavFile = {	'LFH_1.wav', ...
									'MFV_1.wav', ...
									'noisy_1.wav', ...
									'p100_3_11_v1.wav' };
audio.signal.WavInfo = fullfile(audio.signal.WavPath, 'wavinfo.mat');
audio.Delay = 100;
% Duration is variable for WAV files - this information
% will be found in the audio.signal.WavInfo
% audio.Duration = 200;
audio.Level = 0:10:60;
audio.Ramp = 1;
audio.Frozen = 0;
%------------------------------------
% Presentation settings
%------------------------------------
test.Reps = 10;
test.Randomize = 1;
audio.ISI = 1000;

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
test.SweepPeriod = 1001;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% build list of unique stimuli
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% varied variables for opto and audio
optovar = opto.Amp;
audiolevelvar = audio.Level;
audiowavvar = audio.signal.WavFile;
% total # of varied variables
nCombinations = numel(optovar) * numel(audiolevelvar);
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
	for aindex = 1:numel(audiolevelvar)
		stimList(sindex).opto.Amp = optovar(oindex);
		stimList(sindex).audio.Level = audiolevelvar(aindex);
		sindex = sindex + 1;
	end
end
% # of total trials;
nTotalTrials = nCombinations * Reps;
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% randomize in blocks (if necessary) by creating a randomized list of 
% indices of the different stimuli within stimList
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% preallocate stimIndices
stimIndices = zeros(nTotalTrials, 1);
% and assign values
if Randomize
	% assign random permutations to stimindices
	for r = 1:Reps
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

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% some stimulus things
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% If noise is frozen, save noise spectrum for future synthesis
% need to do this AFTER stimList has been built to avoid using up
% extra memory
if audio.Frozen
	[audio.signal.S0, audio.signal.Smag0, audio.signal.Sphase0] = ...
								synmononoise_fft(audio.Duration, outdev.Fs, ...
															audio.signal.Fmin, ...
															audio.signal.Fmax, ...
															caldata.DAscale, caldata);
	% ramp the sound on and off (important!) and compute RMS
	audio.signal.S0 = sin2array(audio.signal.S0, audio.Ramp, outdev.Fs);
	audio.signal.rms = rms(audio.signal.S0);
end

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Setup Plots using the _configurePlots script
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% 	HPCurve_configurePlots

%{
% make sure we have lowercase stimtype and curvetype
curvetype = upper(stimcache.curvetype);
stimtype = lower(stimcache.stimtype);
% init the curvedata as empty matrix
curvedata = [];
	
%--------------------------------------------------------
%--------------------------------------------------------
% feedback to user about curve
%--------------------------------------------------------
%--------------------------------------------------------
disp(['Running ' curvetype ' Curve using ' stimtype '...'])
fprintf('\t Nreps: %d', stimcache.nreps);
% 	fprintf('\t ITD range: %s', curve.ITDrangestr);
% 	fprintf('\t ILD range: %s', curve.ILDrangestr);
% 	fprintf('\t ABI range: %s', curve.ABIrangestr);
% 	fprintf('\t FREQ range: %s', curve.FREQrangestr);
% 	fprintf('\t BC range: %s', curve.BCrangestr);
% 	fprintf('\t sAM Pct range: %s', curve.sAMPCTrangestr);
% 	fprintf('\t sAM Freq range: %s', curve.sAMFREQrangestr);
fprintf('\t saveStim: %d', stimcache.saveStim);
fprintf('\t freezeStim: %d', stimcache.freezeStim);
fprintf('\t display channel: %d\n', handles.H.TDT.channels.MonitorChannel);
%}

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
acqpts = ms2samples(AcqDuration, indev.Fs);
outpts = ms2samples(audio.Duration, outdev.Fs); %#ok<NASGU>
% stimulus start and stop in samples
stim_start = ms2samples(audio.Delay, outdev.Fs);
stim_end = stim_start + ms2samples(audio.Duration, outdev.Fs); %#ok<NASGU>

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% initialize some cells and arrays for storing data and variables
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% resp = raw data traces
resp = cell(nTotalTrials, 1);
	
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Write data file header - this will create the binary data file
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% add elements to test for storage
test.stimIndices = stimIndices;
test.stimList = stimList;
test.nCombinations = nCombinations;
test.optovar_name = 'Amp';
test.optovar = opto.Amp;
test.audiovar_name = 'Level';
test.audiovar = opto.audio.Level;
% and write header to data file
writeOptoDataFileHeader(datafile, test, audio, opto, channels, ...
								 caldata, indev, outdev);

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Initialize cancel/pause button
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
[PanelHandle, cancelButton, pauseButton] = cancelpausepanel;
	
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
% Set the Stimulus Delay
RPsettag(outdev, 'StimDelay', ms2bin(audio.Delay, outFs));
% Set the Stimulus Duration
RPsettag(outdev, 'StimDur', ms2bin(audio.Duration, outFs));
% Set the length of time to acquire data
RPsettag(indev, 'AcqDur', ms2bin(AcqDuration, inFs));
% Set the total sweep period time - input
RPsettag(indev, 'SwPeriod', ms2bin(SweepPeriod, inFs));
% Set the total sweep period time - output
RPsettag(outdev, 'SwPeriod', ms2bin(SweepPeriod, outFs));
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

% % build filter for plotting data
% fband = [handles.H.TDT.HPFreq handles.H.TDT.LPFreq] ./ ...
% 					(0.5 * handles.H.TDT.indev.Fs);
% [filtB, filtA] = butter(3, fband);

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
xv = linspace(0, AcqDuration, acqpts);
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

%--------------------------------------------------------
%--------------------------------------------------------
% Initialize flags and counters
%--------------------------------------------------------
%--------------------------------------------------------
% RasterIndex = RASTERLIM;
% flag to cancel experiment
cancelFlag = 0;
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
while ~cancelFlag && (sindex <= nTotalTrials)
	% increment counter (was initialized to 0)
	sindex = sindex + 1;
	rep = ceil(sindex/nCombinations);
	
	% get current stimulus settings from stimList (using stimIndices to 
	% index into stimList)
	Stim = stimList(stimIndices(sindex));
	
	% synthesize stimulus
	if ~audio.Frozen
		% de novo
		Sn = synmononoise_fft(Stim.audio.Duration, outdev.Fs, ...
										Stim.audio.signal.Fmin, ...
										Stim.audio.signal.Fmax, ...
										caldata.DAscale, caldata);
		% ramp the sound on and off (important!)
		Sn = sin2array(Sn, Stim.audio.Ramp, outdev.Fs);
		rmsval = rms(Sn);
	else
		% use same noise
		Sn = audio.signal.S0;
		rmsval = audio.signal.rms;
	end
	% need to add dummy channel to Sn since iofunction needs stereo signal
	Sn = [Sn; zeros(size(Sn))];
		
	% get the attenuator settings for the desired SPL
	atten = figure_mono_atten(Stim.audio.Level, rmsval, caldata);
	% set the attenuators
	setattenfunc(outdev, [atten 120]);
	
	% set opto stim
	if Stim.opto.Enable
		% turn on opto trigger
		RPsettag(indev, 'OptoEnable', 1);
		% set opto params
		RPsettag(indev, 'OptoDelay', ...
								ms2bin(Stim.opto.Delay, indev.Fs));
		RPsettag(indev, 'OptoDur', ...
								ms2bin(Stim.opto.Dur, indev.Fs));
		RPsettag(indev, 'OptoAmp', 0.001*Stim.opto.Amp);
	else
		% ensure opto trigger is OFF
		RPsettag(indev, 'OptoEnable', 0);
	end

	% play the sound and return the response
	[rawdata, ~] = iofunc(Sn, acqpts, indev, outdev, zBUS);
	
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
	optomsg(handles, sprintf('%s = %d repetition = %d  atten = %.0f', ...
								curvetype, sindex, rep, atten(L)) );
	% also, create title for plot for more info
	tstr = sprintf('%s: %d  Rep: %d  Atten:%.0f', ...
								curvetype, sindex, rep, atten(L));

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
 	title(ax, tstr);
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
	if nargout == 2
		varargout{1} = resp;
	end
	curvedata.depvars = depvars;
	curvedata.depvars_sort = depvars_sort;

	if stimcache.saveStim
		[pathstr, fbase] = fileparts(datafile);
		curvedata.stimfile = fullfile(pathstr, [fbase '_stim.mat']);
	end
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
	