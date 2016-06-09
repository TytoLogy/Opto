function [curvedata, varargout] = opto_playCache(handles, datafile, ...
											stimcache, test, analysis, varargin)
%--------------------------------------------------------------------------
% [curvedata, rawdata] = opto_playCache(handles, datafile, ...
% 											stimcache, curve, analysis, varargin)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% Runs through stimuli in stimcache
%
%--------------------------------------------------------------------------
% Input Arguments:
%	H		exp handles from calling gui (H)
%	datafile		name (full path + '.dat' filename) for data
%	stimcache	sturct containing stimuli and info
% 	analysis		structure of analysis parameters
% 
% 	Optional:
% 	 varargin{1}		figure handle to response plot
% 	 varargin{2}		figure handle for raster plot 
% 	 varargin{3}		handle to text object
% 
% Output Arguments:
% 	curvedata	data structure	
% 	rawdata		raw response data cell array
% 					{nTrials, nreps}
%
%--------------------------------------------------------------------------
% See Also: opto, HPSearch, HPSearch_Run
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Sharad J. Shanbhag
%	based on HPCurve_playCache developed 
% 	by Sharad Shanbhag & Jose Luis Pena
% sshanbhag@neomed.edu
% jpena@einstein.edu
%--------------------------------------------------------------------------
% Revision History:
%	25 May, 2016 (SJS) created from HPCurve_playCache of HPSearch program
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------


%--------------------------------------------------------
%--------------------------------------------------------
% local copies of structs and vars
%--------------------------------------------------------
%--------------------------------------------------------

% hardware structs
indev = handles.H.TDT.indev;
outdev = handles.H.TDT.outdev;
zBUS = handles.H.TDT.zBUS;
channels = handles.H.TDT.channels;
% function handles
setattenfunc = handles.H.TDT.config.setattenFunc;
iofunc = handles.H.TDT.config.ioFunc;

% stimulus structs - get these from test struct!!!!
audio = test.audio;
opto = test.opto;
caldata = handles.H.caldata;

%--------------------------------------------------------
%--------------------------------------------------------
% Setup Plots using the _configurePlots script
%--------------------------------------------------------
%--------------------------------------------------------
% 	HPCurve_configurePlots

%--------------------------------------------------------
%--------------------------------------------------------
% settings and constants, some defined in _constants script
%--------------------------------------------------------
%--------------------------------------------------------
L = 1;
R = 2;
MAX_ATTEN = 120;

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
fprintf('\t display channel: %d\n', handles.H.TDT.MonChan);
	
%--------------------------------------------------------
%--------------------------------------------------------
% calculations of samples for various things
%--------------------------------------------------------
%--------------------------------------------------------
%-------------------------------------------------------
% First, get the # of points to send out and to collect
% for multi-channel data, the number of samples will be
% given by the product of the # channels and # sample in the acquisition
% period (tdt.nChannels * AcqDuration * Fs / 1000)
% acqpts = tdt.nChannels * ms2samples(tdt.AcqDuration, indev.Fs);
%-------------------------------------------------------
acqpts = ms2samples(test.AcqDuration, indev.Fs);
outpts = ms2samples(audio.Duration, outdev.Fs);
%-------------------------------------------------------
% stimulus start and stop in samples
%-------------------------------------------------------
stim_start = ms2samples(audio.Delay, outdev.Fs);
stim_end = stim_start + ms2samples(audio.Duration, outdev.Fs);

%--------------------------------------------------------
%--------------------------------------------------------
% initialize some cells and arrays for storing data and variables
%--------------------------------------------------------
%--------------------------------------------------------
% resp = raw data traces
resp = cell(stimcache.ntrials, stimcache.nreps);
% index of dependent (varying) parameter
depvars = zeros(stimcache.ntrials, stimcache.nreps);
depvars_sort = zeros(stimcache.ntrials, stimcache.nreps);
	
%--------------------------------------------------------
%--------------------------------------------------------
% Write data file header - this will create the binary data file
%--------------------------------------------------------
%--------------------------------------------------------
% initialize the data file. write data file header
testopts = rmfield(test, {'audio', 'opto'});
writeDataFileHeader(datafile, testopts, audio, opto, channels, caldata, ...
								indev, outdev);

%--------------------------------------------------------
%--------------------------------------------------------
% Initialize cancel/pause button
%--------------------------------------------------------
%--------------------------------------------------------
[PanelHandle, cancelButton, pauseButton] = cancelpausepanel;
	
%--------------------------------------------------------
%--------------------------------------------------------
% Initialize flags and counters
%--------------------------------------------------------
%--------------------------------------------------------
% RasterIndex = RASTERLIM;
cancelFlag = 0;
pauseFlag = 0;
sindex = 1;

if stimcache.saveStim
	stimWriteFlag = 1;
else
	stimWriteFlag = 0;
end

%--------------------------------------------------------
%--------------------------------------------------------
%  setup hardware
%--------------------------------------------------------
%--------------------------------------------------------
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
%--------------------------------------------------------
% attenuation
%--------------------------------------------------------
RPsettag(outdev, 'AttenL', 90);
RPsettag(outdev, 'AttenR', 90);
RPsettag(outdev, 'Mute', 0);
%--------------------------------------------------------
% turn on audio monitor for spikes using software trigger 1
%--------------------------------------------------------
RPtrig(handles.H.TDT.indev, 1);

%--------------------------------------------------------
%--------------------------------------------------------
% Main Data Loop
%--------------------------------------------------
% This is the core of the data acquisition and 
% stimulus presentation 
%--------------------------------------------------------
%--------------------------------------------------------

%-------------------------------------------------------
% loop through stims
%-------------------------------------------------------
while ~cancelFlag && (sindex <= stimcache.nstims)	
	rep = stimcache.repnum(sindex);
	trial = stimcache.trialnum(sindex);

	% get the attenuator values
	atten = stimcache.atten{sindex};
	% stimulus 
	Sn = [stimcache.Sn{sindex}; zeros(size(stimcache.Sn{sindex}));];
	% set the attenuators
	setattenfunc(outdev, [atten(L) 120]);
	% set opto stim
	if stimcache.opto{sindex}.Enable
		% turn on opto trigger
		RPsettag(indev, 'OptoEnable', 1);
		% set opto params
		RPsettag(indev, 'OptoDelay', ...
								ms2bin(stimcache.opto{sindex}.Delay, indev.Fs));
		RPsettag(indev, 'OptoDur', ...
								ms2bin(stimcache.opto{sindex}.Dur, indev.Fs));
		RPsettag(indev, 'OptoAmp', 0.001*stimcache.opto{sindex}.Amp);
	else
		% ensure opto trigger is OFF
		RPsettag(indev, 'OptoEnable', 0);
	end

	% play the sound and return the response
	[datatrace, ~] = iofunc(Sn, acqpts, indev, outdev, zBUS);

	% Save Data
	writeTrialData(datafile, datatrace, stimcache.stimvar{sindex}, ...
								trial, rep);

	% store the dependent variable parameters for later use
	depvars(trial, rep) = stimcache.stimvar{sindex};
	depvars_sort(stimcache.trialRandomSequence(rep, trial), rep) = ...
															stimcache.stimvar{sindex};

	% This is code for letting the user know what in
	% tarnation is going on in text at bottom of window
	optomsg(handles, sprintf('%s = %d repetition = %d  atten = %d', ...
								curvetype, stimcache.stimvar{sindex}, rep, ...
								atten(L)) );

	% Store response data in cell array
	% 	Note: by indexing the response using row values from the 
	% 	trialRandomSequence array, the resp{} data will be in SORTED form!
	if channels.nInputChannels > 1
		% demultiplex the returned vector and store the response
		% mcDeMux returns an array that is [nChannels, nPoints]
		resp{stimcache.trialRandomSequence(rep, trial), rep} = ...
										mcDeMux(datatrace, channels.nInputChannels);
	else
		resp{stimcache.trialRandomSequence(rep, trial), rep} =  datatrace;
	end

% 	% RespPlot: plot trace
% 	% plot trace
% 	axes(RespPlot);
% 	plot(tvec, current_trace)
% 	ylim(analysis.respscale.*[-1 1]);
% 	xlim([0 round(max(tvec))]);
% 	line(xlim, analysis.spikeThreshold * [1 1], 'Color', 'r');
% 
% 	% detect and plot spikes using software Schmitt trigger detector
% 	spiketimes = spikeschmitt2(current_trace, analysis.spikeThreshold, ...
% 														analysis.spikeWindow, indev.Fs);
% 	spiketimes = 1000 * spiketimes / indev.Fs;
% 	hold on
% 		yl = ylim;
% 		plot(spiketimes, yl(2)*ones(size(spiketimes)), 'r.')
% 	hold off
% 	% draw lines to show start and stop of analysis window
% 	respv1 = line(analysis.spikeStartTime*[1 1], yl, 'Color', 'g');
% 	respv2 = line(analysis.spikeEndTime*[1 1], yl, 'Color', 'r');		
% 
% 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
% 	% Raster Plot
% 	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%			
% 	% select the raster axes
% 	axes(RasterPlot);
% 	if RasterIndex < 1
% 		RasterIndex = RASTERLIM;
% 	end
% 	% is RasterIndex == RASTERLIM?
% 	if RasterIndex == RASTERLIM
% 		% first, plot a "dummy" point to set Left hand scale
% 		xlim([0 max(tvec)])
% 		plot(xlim, RASTERLIM.*[1 1], '.', 'Color', [1 1 1]);
% 		% then plot the spike "ticks"
% 		hold on
% 			plot(spiketimes, RasterIndex*ones(size(spiketimes)), 'b.')
% 		hold off
% 		ylim('manual');
% 		ylim([0 RASTERLIM + 1]);
% 		set(RasterPlot, 'YTickLabel', []);
% 		rasterv1 = line(analysis.spikeStartTime*[1 1], ylim, 'Color', 'g');
% 		rasterv2 = line(analysis.spikeEndTime*[1 1], ylim, 'Color', 'r');		
% 	else
% 		hold on
% 			plot(spiketimes, RasterIndex*ones(size(spiketimes)), 'b.')
% 		hold off
% 	end
% 	% decrement RasterIndex to move next plot down a row
% 	RasterIndex = RasterIndex - 1;
% 	drawnow

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
	pause(0.001*test.audio.ISI);
	% increment counter
	sindex = sindex + 1;
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
closeTrialData(datafile, time_end);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Compute mean spike count as a function of depvars and std error bars
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 	if ~cancelFlag
% 		spike_times = cell(curve.nTrials, curve.nreps);
% 		spike_counts = zeros(curve.nTrials, curve.nreps);
% 
% 		% find the start and end times for counting spikes
% 		spike_start = ms2samples(analysis.spikeStartTime, indev.Fs);
% 		spike_end = ms2samples(analysis.spikeEndTime, indev.Fs);
% 
% 		if tdt.nChannels > 1
% 			% loop through the reps
% 			for q=1:curve.nreps
% 				% loop through the completed trials (values for the curve)
% 				for r=1:size(resp, 1)			
% 					% threshold the data within the spike analysis window
% 					spikes = spikeschmitt2(resp{r, q}(spike_start:spike_end, SPIKECHAN), ...
% 													analysis.spikeThreshold, ...
% 													analysis.spikeWindow, indev.Fs);
% 					% convert to milliseconds, accounting for offset due to the
% 					% start of the analysis window
% 					spike_times{r,q} = analysis.spikeStartTime + 1000*dt*spikes;
% 					spike_counts(r,q) = length(spike_times{r,q});
% 				end
% 			end
% 		else
% 			% loop through the reps
% 			for q=1:curve.nreps
% 				% loop through the completed trials (values for the curve)
% 				for r=1:size(resp, 1)			
% 					% threshold the data within the spike analysis window
% 					spikes = spikeschmitt2(resp{r, q}(spike_start:spike_end), ...
% 													analysis.spikeThreshold, ...
% 													analysis.spikeWindow, indev.Fs);
% 					% convert to milliseconds, accounting for offset due to the
% 					% start of the analysis window
% 					spike_times{r,q} = analysis.spikeStartTime + 1000*dt*spikes;
% 					spike_counts(r,q) = length(spike_times{r,q});
% 				end
% 			end
% 		end
% 	end
% 	
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
% 	curvedata.spike_times = spike_times;
% 	curvedata.spike_counts = spike_counts;
	if stimcache.saveStim
		[pathstr, fbase] = fileparts(datafile);
		curvedata.stimfile = fullfile(pathstr, [fbase '_stim.mat']);
	end
end

%--------------------------------------------------------
%--------------------------------------------------------
% close curve panel
%--------------------------------------------------------
%--------------------------------------------------------
close(PanelHandle)


% turn off monitor using software trigger 2 sent to indev
RPtrig(indev, 2);

	
%--------------------------------------------------------
%--------------------------------------------------------
% save cancel flag status in curvedata
%--------------------------------------------------------
%--------------------------------------------------------
curvedata.cancelFlag = cancelFlag;
	