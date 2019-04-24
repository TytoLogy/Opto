function outdata = MTwav(handles, datafile)
%--------------------------------------------------------------------------
% outdata = MTwav(handles, datafile)
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
%	28 Mar, 2019 (SJS): created for use with M. Tehrani's vocal stimuli
%	24 Apr, 2019 (SJS): reworking and testing.
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

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

% # of plots for PSTH and rasters - the product of PLOT_ROWs and PLOT_COLS
% must be greater than or equal to the number of wav files + 2 (need to
% account for "null" stimulus and noise stimulus)
PLOT_ROWS = 4; %#ok<NASGU>
PLOT_COLS = 3; %#ok<NASGU>

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
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% %%% EDIT MTwav_settings TO CHANGE EXPERIMENTAL 
% PARAMETERS (reps, ISI, etc.) %%%%
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%-------------------------------------------------------------------------
run('Scripts\MTwav_settings')

if opto.Enable
	disp 'running wav_optoON!'
	curvetype = 'Wav+OptoON';	
else
	disp 'running wav_optoOFF!'
	curvetype = 'Wav+OptoOFF';
end

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% construct wavInfo struct "database" for desired wav stimuli
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
[wavInfo, audio.signal.WavFile] = opto_create_wav_stimulus_info( ...
														audio.signal.WavPath, ...
														WavesToPlay, ...
														WavScaleFactors, ...
														WavLevelAtScale); %#ok<NODEF>

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% build list of unique stimuli
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

[stimList, counts] = opto_build_stimList(test, audio, opto, noise, nullstim); %#ok<NODEF>

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
					buildStimIndices(counts.nTotalTrials, ...
											counts.nCombinations, test.Reps, ...
											1, 0);
elseif isfield(test, 'Block')
	if test.Block == 1
		disp('Blocked stimulus order')
		[stimIndices, repList] = ...
					buildStimIndices(counts.nTotalTrials, ...
											counts.nCombinations, test.Reps, ...
											0, 1);

	else
		% assign sequential indices to stimindices
		disp('Sequential stimulus order');
		[stimIndices, repList] = ...
					buildStimIndices(counts.nTotalTrials, ...
											counts.nCombinations, test.Reps, ...
											0, 0);
	end
else
	% assign sequential indices to stimindices
	disp('Sequential stimulus order');
		[stimIndices, repList] = ...
					buildStimIndices(counts.nTotalTrials, ...
											counts.nCombinations, test.Reps, ...
											0, 0);
end	% END if test.Randomize

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% some stimulus things
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% check durations of wav stimuli
% first, create a vector stimulus durations
[tmp{1:numel(audio.signal.WavFile)}] = deal(wavInfo.Duration);
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
resp = cell(counts.nTotalTrials, 1);
	
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
test.nCombinations = counts.nCombinations;
test.optovar_name = 'Amp';
test.optovar = opto.Amp;
test.audiovar_name = 'WavFile';
test.audiovar = audio.signal.WavFile;
animal = handles.H.animal;
% and write header to data file
writeOptoDataFileHeader(datafile, test, animal, ...
									audio, opto, channels, ...
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
standalone_wav_setupplots;

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
% loop through stims
%-------------------------------------------------------
%-------------------------------------------------------
% while loop index for stimIndices (stimulus sequence)
sindex = 0;
% loop until done or cancel button is pressed
while ~cancelFlag && (sindex < counts.nTotalTrials)
	%--------------------------------------------------
	% increment counter (was initialized to 0)
	%--------------------------------------------------
	sindex = sindex + 1;
	%--------------------------------------------------
	% index into stimList stored in (possibly) randomized stimulus sequence
	%--------------------------------------------------
	cIndx = stimIndices(sindex);
	%--------------------------------------------------
	% rep #s
	%--------------------------------------------------
	% get current rep;
	rep = repList(sindex);
	%--------------------------------------------------
	% get current stimulus settings from stimList,using stimIndices to 
	% index into stimList
	%--------------------------------------------------
	Stim = stimList(cIndx);
	stimtype = Stim.audio.signal.Type;
	fprintf('sindex: %d(%d)\t rep: %d(%d)\tType: %s\n', ...
		counts.nTotalTrials, sindex, rep, test.Reps, stimtype);
	fprintf('stimIndices(%d): %d\n', sindex, cIndx);
	fprintf('\taudio:\tDelay:%d\tLevel:%d', ...
			Stim.audio.Delay, Stim.audio.Level)
	if strcmpi(stimtype, 'wav')
		fprintf('\t%s\n', Stim.audio.signal.WavFile);
	else
		fprintf('\t%s\n', Stim.audio.signal.Type);
	end
	fprintf('\topto:\tEnable:%d\tDelay:%d\tDur:%d\tAmp:%d\n', ...
			Stim.opto.Enable, Stim.opto.Delay, Stim.opto.Dur, Stim.opto.Amp)

	%--------------------------------------------------
	% set audio stimulus based on type and get index into 
	% array of plots/psths
	%--------------------------------------------------
	switch(upper(stimtype))
		
		case 'NULL'
			% no audio stimulus
			Sn = syn_null(Stim.audio.Duration, outdev.Fs, 0);
			% dummy rms val
			rmsval = 0; %#ok<NASGU>
			% max atten for null stim
			atten = 120;
			% null stimuli will be in psth after the wav psths
			% see standalone_wav_settupplots.m script
			pIndx = counts.nWavStim + 1;
			
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
			% get the attenuator settings for the desired SPL
			atten = figure_mono_atten(Stim.audio.Level, rmsval, caldata);
			% noise stimuli will be 2 psth after the wav psths
			% see standalone_wav_settupplots.m script
			pIndx = counts.nWavStim + 2;

		case 'WAV'
			% wav file.  locate waveform in wavS0{} cell array by
			% finding corresponding location of Stim.audio.signal.WavFile 
			% in the main audio struct, audio.signal.WavFile{}
			wavindex = find(strcmpi(Stim.audio.signal.WavFile, ...
												audio.signal.WavFile));
			Sn = wavS0{wavindex} * wavInfo(wavindex).ScaleFactor; %#ok<USENS>
			%{ 
			%%% OLD
			% use peak rms value for figuring atten
			rmsval = wavInfo(wavindex).PeakRMS;
			%}
			% NEW
			% determine attenuation value by subtracting desired level from
			% WavLevelAtScale
			atten = wavInfo(wavindex).WavLevelAtScale - Stim.audio.Level;

			% use wavindex for psth id
			% see standalone_wav_settupplots.m script
			pIndx = wavindex;
			
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
		% get the spike response
		[spikes, nspikes] = opto_getspikes(indev); %#ok<ASGLU>
	catch
		disp('%s: trapped error in stimulus IO', mfilename);
		keyboard
	end
	
	% demux the response if necessary and store response data in cell array
	% 	Note: by indexing the response using row values from the 
	% 	trialRandomSequence array, the resp{} data will be in SORTED form!
	if channels.nInputChannels > 1
		% demultiplex the returned vector and store the response
		% mcDeMux returns an array that is [nChannels, nPoints]
		tmpD = mcFastDeMux(rawdata, channels.nInputChannels);
		resp{cIndx} = tmpD;
		recdata = tmpD(:, channels.RecordChannelList);
	else
		resp{cIndx} =  rawdata;
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
	SpikeTimes{pIndx}{currentRep(pIndx)} = (1000/indev.Fs) * ...
																	spikebins; %#ok<AGROW>
%----
% what is this for????
% 	SpikeTimes{cIndx}{currentRep(cIndx)} = ...
% 				[SpikeTimes{cIndx}{currentRep(cIndx)} 100*cIndx]; %#ok<AGROW>
%-----
	% draw new hash marks on sweep plot
	set(tH,	'XData', ...
					SpikeTimes{pIndx}{currentRep(pIndx)}, ...
				'YData', ...
					zeros(size(SpikeTimes{pIndx}{currentRep(pIndx)})) + ...
 							handles.H.TDT.channels.MonitorChannel*yabsmax);
	% update PSTH
% 	PSTH.hvals{cIndx} = psth(	SpikeTimes{cIndx}, ...
% 										binSize, ...
% 										[0 handles.H.TDT.AcqDuration]);
	PSTH.hvals{pIndx} = psth(	SpikeTimes{pIndx}, ...
										binSize, ...
										[0 test.AcqDuration]);
	bar(pstAxes(pIndx), PSTH.bins, PSTH.hvals{pIndx}, 1);
% 	% update raster
% 	rasterplot(		SpikeTimes{cIndx}, ...
% 						[0 handles.H.TDT.AcqDuration], ...
% 						'|', ...
% 						12, ...
% 						'k', ...
% 						rstAxes(cIndx)	);
	% check state of cancel button

	% increment current index
	currentRep(pIndx) = currentRep(pIndx) + 1; %#ok<AGROW>
	
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

	