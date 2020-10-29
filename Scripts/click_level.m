function outdata = click_level(handles, datafile)
%--------------------------------------------------------------------------
% outdata = click_level(handles, datafile)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% Standalone experiment script (relies on hardware setup in handles)
% Delivers click stimuli at different levels (needs to be calibrated
% separately)
%
% To Run: select click_standalone.m in the 
%			script load portion of opto
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
% See Also: MTwav, noise_opto, opto, opto_playCache
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Sharad J. Shanbhag
%	based on HPCurve_playCache developed 
% 	by Sharad Shanbhag & Jose Luis Pena
% sshanbhag@neomed.edu
% jpena@einstein.edu
%--------------------------------------------------------------------------
% Created:	28 October, 2020 (SJS) from MTwav.m
%
% Revision History:
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

fprintf('--------------------------------------------------------\n');
fprintf('Running %s\n', mfilename);
fprintf('--------------------------------------------------------\n');

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
PLOT_ROWS = 1; %#ok<NASGU>
PLOT_COLS = 2; %#ok<NASGU>

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
%------------------------------------
% test settings from xxxx_standalone.m
%------------------------------------
% original type is 'STANDALONE' but analysis scripts and programs will want
% something specific
test.Type = 'LEVEL';
test.Name = handles.H.test.Name;
% store original type as script type
test.ScriptType = handles.H.test.Type;

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Experiment settings
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% %%% EDIT MTwav_settings TO CHANGE EXPERIMENTAL 
% PARAMETERS (reps, ISI, etc.) %%%%
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%-------------------------------------------------------------------------
run('Scripts\click_settings')

if opto.Enable
	disp 'running click level, optogenetic stimulus ON!'
	curvetype = 'LEVEL+OptoON';	
else
	disp 'running click level, no optogenetic stimulus'
	curvetype = 'LEVEL+OptoOFF';
end

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% construct stimuli - can do this ahead of time, since all of these stimuli
% are "frozen" (unlike BBN)
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
Sclick = synmonoclick(audio.Duration, outdev.Fs, ...
								audio.signal.ClickDelay, ...
								audio.signal.ClickDuration, ...
								caldata.DAscale);

% null audio stimulus
Snull = syn_null(audio.Duration, outdev.Fs, 0);

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% build list of unique stimuli
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
[stimList, counts] = opto_build_clickstimList(test, audio, opto, ...
	                                             noise, nullstim); 

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
% Write data file header - this will create the binary data file
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% add elements to test for storage
test.stimIndices = stimIndices;
test.nCombinations = counts.nCombinations;
test.optovar_name = 'Amp';
test.optovar = opto.Amp;
test.audiovar_name = 'ClickLevel';
test.audiovar = 'Level';
test.curvetype = curvetype;
animal = handles.H.animal;
% and write header to data file
writeOptoDataFileHeader(datafile, test, animal, ...
									audio, opto, channels, ...
									caldata, indev, outdev);

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Set up figure for plotting incoming data
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
standalone_click_setupplots;

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
	fprintf('\t%s\n', Stim.audio.signal.Type);
	fprintf('\topto:\tEnable:%d\tDelay:%d\tDur:%d\tAmp:%d\n', ...
			Stim.opto.Enable, Stim.opto.Delay, Stim.opto.Dur, Stim.opto.Amp)

	%--------------------------------------------------
	% set audio stimulus based on type and get index into 
	% array of plots/psths
	%--------------------------------------------------
	switch(upper(stimtype))
		
		case 'NULL'
			% no audio stimulus
			Sn = Snull;
			% dummy rms val
			rmsval = 0; %#ok<NASGU>
			% max atten for null stim
			atten = 120;
			% null stimuli will be in psth after the wav psths
			% see standalone_click_settupplots.m script and
			% opto_build_clickstimList function
			pIndx = counts.nAudioLevels + 1;
			
		case 'CLICK'
			% Click
			Sn = Sclick;
% 			rmsval = rms(Sn);

			% get the attenuator settings for the desired SPL
 			atten = audio.signal.ClickLevelAtScale - Stim.audio.Level;
			if atten < 0
				warning('Desired level %.1f > max possible level (%.1f)', ...
					       Stim.audio.Level, audio.signal.ClickLevelAtScale);
				atten = 0;
			end
			
			% noise stimuli will be 2 psth after the wav psths
			% see standalone_wav_settupplots.m script
			pIndx = find(Stim.audio.Level == test.Level);
			% update the Stimulus Delay
 			RPsettag(outdev, 'StimDelay', ms2bin(Stim.audio.Delay, outFs));
			
		otherwise
			fprintf('unknown type %s\n', stimtype);
			% jump back to user in debug mode
			errordlg({sprintf('unknown type %s\n', stimtype), 'Entering Debug Mode'})
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
	%	write:
	%		- recorded data
	%		- info about stimulus:
	%				audio level, opto amplitude index_into_stimList
	%		- trial #
	%		- rep #
	%
	writeOptoTrialData(datafile, ...
								recdata, ...
								[Stim.audio.Level Stim.opto.Amp cIndx], ...
								sindex, rep);

	% This is code for letting the user know what in
	% tarnation is going on in text at bottom of window
	wtype = sprintf('%s', Stim.audio.signal.Type);
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

	