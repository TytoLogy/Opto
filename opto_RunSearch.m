%--------------------------------------------------------------------------
% opto_RunSearch script
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% Sets up and runs search stimulus. called by 
% opto.m:buttonRunTestScript_Callback function
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Revision History
%	4 Oct 2016 (SJS): 
%	 - working on wav file output
%	 - added header/comments
%	22 Oct 2017 (SJS): changed attenuation calc for noise vs. tones
%	24 Oct 2017 (SJS): last change broke search and blocksearch stim
%							output - fix!
%--------------------------------------------------------------------------

% kludge until this is put into UI
monitorHPFc = 350;
hashColor = 'c';

% Determine run state from value of button - need to do this in order to
% be able to stop/start
state = read_ui_val(hObject);

% if user wants to start run, check if tdt hardware is initialized
if state && ~handles.H.TDT.Enable
	% user started run, but HW not init'ed so abort
	update_ui_val(hObject, 0);
	update_ui_str(hObject, 'Search');
	optomsg(handles, 'TDT HW not enabled!!!!');
	guidata(hObject, handles);
	return

% if state of button is 0 and TDT hardware is started, stop run
elseif ~state && handles.H.TDT.Enable
	% Terminate the Run
	optomsg(handles, 'Search ending...');
	update_ui_str(hObject, 'Search');
	% if MonEnable == 0,
	% turn off monitor using software trigger 2 sent to indev
	if handles.H.TDT.MonEnable == 0
		RPtrig(handles.H.TDT.indev, 2);
	end
	guidata(hObject, handles);
	return

else
	%------------------------------------------------------------
	% Start I/O
	%------------------------------------------------------------
	optomsg(handles, 'Starting search...');
	update_ui_str(hObject, 'Stop Search');

	% update settings
	opto_TDTsettings(	handles.H.TDT.indev, ...
							handles.H.TDT.outdev, ...
							handles.H.TDT, ...
							handles.H.audio, ...
							handles.H.TDT.channels, ...
							handles.H.opto);

	% turn on audio monitor for spikes using software trigger 1
	RPtrig(handles.H.TDT.indev, 1);

	% calculate # of points to acquire (in units of samples)
	inpts = ms2bin(handles.H.TDT.AcqDuration, handles.H.TDT.indev.Fs);

	% set acquisition duration and sweep period for indev.
	RPsettag(handles.H.TDT.indev, 'AcqDur', ...
				ms2bin(handles.H.TDT.AcqDuration, handles.H.TDT.indev.Fs));
	RPsettag(handles.H.TDT.indev, 'SwPeriod', ...
			ms2bin(handles.H.TDT.AcqDuration+1, handles.H.TDT.indev.Fs));

	% set monitor high pass filter cutoff monitorHPFc on indev.
	RPsettag(handles.H.TDT.indev, 'MonHPFc', monitorHPFc);

	%------------------------------------------------------------
	% create figure for plotting neural data
	%------------------------------------------------------------
	% generate figure, axes
	if isempty(handles.H.fH) || ~ishandle(handles.H.fH)
		handles.H.fH = figure;
		guidata(hObject, handles);
	end
	if isempty(handles.H.ax) || ~ishandle(handles.H.ax)
		handles.H.ax = axes;
		guidata(hObject, handles);
	end
	% store local copy of figure handle for simplicity in calls
	fH = handles.H.fH;
	% create/switch focus to figure, generate axis
	figure(fH);
	ax = handles.H.ax;
	% set up plot
	xv = linspace(0, handles.H.TDT.AcqDuration, inpts);
	xlim([0, inpts]);
	yabsmax = 5;
	tmpData = zeros(inpts, handles.H.TDT.channels.nInputChannels);
	for n = 1:handles.H.TDT.channels.nInputChannels
		tmpData(:, n) = n*(yabsmax) + 2*(2*rand(inpts, 1)-1);
	end
	pH = plot(ax, xv, tmpData);
	yticks_yvals = yabsmax*(1:handles.H.TDT.channels.nInputChannels);
	yticks_txt = cell(handles.H.TDT.channels.nInputChannels, 1);
	for n = 1:handles.H.TDT.channels.nInputChannels
		yticks_txt{n} = num2str(n);
	end
	ylim(yabsmax*[0 handles.H.TDT.channels.nInputChannels+1]);
	set(ax, 'YTick', yticks_yvals);
	set(ax, 'YTickLabel', yticks_txt);
	set(ax, 'TickDir', 'out');
	set(ax, 'Box', 'off');
	set(fH, 'Position', [792 225 557 800]);
	xlabel('Time (ms)')
	ylabel('Channel')
	set(ax, 'Color', 0.75*[1 1 1]);
	set(fH, 'Color', 0.75*[1 1 1]);
	set(fH, 'ToolBar', 'none');
	% spike hashes
	hold(ax, 'on')
	tH = scatter(ax, [], [], '.', hashColor);
	hold(ax, 'off')
	grid(ax, 'on');
	
	%------------------------------------------------------------
	% main loop
	%------------------------------------------------------------
	% make some local copies of things that won't change in loop
	% to make things more compact textually
	indev = handles.H.TDT.indev;
	outdev = handles.H.TDT.outdev;
	zBUS = handles.H.TDT.zBUS;
	TDT = handles.H.TDT;
	H = handles.H;
	% make local copy of block
	block = H.block;
	% make sure mute is off
	RPsettag(outdev, 'Mute', 0);
	% set rep counter to 0
	rep = 0;
	% short pause (necessary?)
	pause(0.001*H.audio.ISI);
	% loop while Search Button is engaged
	while get(hObject, 'Value')
		rep = rep + 1;
		% update the H stimulus info from GUI settings
		% this is a kludge, but there's no easy way to do this from
		% within a loop (other than using an "evalin" sort of thing to 
		% evaluate the call within a different workspace, which is
		% perhaps an even greater kludge...)
		H = update_H_from_GUI(handles);
		H.block = block;
		% generate stimulus
		[stim, tstr, block] = opto_getSearchStim(H, outdev);
		tstr = sprintf('%s, Rep %d', tstr, rep);
		% convert to [2XN] stimulus array. 
		% row 1 == output A on RZ6, row 2 = output B
		% (opto_io function expects 2Xn array)
		S = [stim; zeros(size(stim))];
		% calculate attenuation factor
		if strcmpi(H.audio.Signal, 'OFF')
			AttenL = 120;
		else
			% if signal type is .wav, use Level as attenuation factor
			if strcmpi(H.audio.Signal, '.wav')
				%AttenL = H.audio.Level;
				AttenL = 0;
			else
				% otherwise, calculate atten to achieve desired output level
				if strcmpi(H.audio.Signal, 'TONE')
					AttenL = figure_mono_atten_tone(H.audio.Level, ...
												rms(stim), H.caldata);
				elseif strcmpi(H.audio.Signal, 'NOISE')
					AttenL = figure_mono_atten_noise(H.audio.Level, ...
												rms(stim), H.caldata);
				else
					AttenL = figure_mono_atten_noise(H.audio.Level, ...
												rms(stim), H.caldata);
				end
% -------debugging
% 				fprintf('level: %.2f rms: %.4f rmsdb: %.4f Atten: %.2f\n', ...
% 								H.audio.Level, rms(stim), ...
% 								db(H.caldata.cal.VtoPa(1).*rms(stim)), AttenL);
			end
			% some checks on AttenL value
			if AttenL <= 0
				AttenL = 0;
				optomsg(handles, 'Attenuation at minimum!', 'echo', 'off');
			elseif AttenL >= 120
				AttenL = 120;
				optomsg(handles, 'Attenuation at maximum!', 'echo', 'off');
			else
				optomsg(handles, sprintf('Rep %d: %s, atten: %.1f dB', ...
													rep, H.audio.Signal, AttenL), ...
													'echo', 'off');
			end
		end
		% Right attenuator is set to 120 since it is unused
		AttenR = 120;
		% Set attenuation levels
		RPsettag(outdev, 'AttenL', AttenL);
		RPsettag(outdev, 'AttenR', AttenR);
		% Set the Stimulus Delay
		RPsettag(outdev, 'StimDelay', ms2bin(H.audio.Delay, outdev.Fs));
		% Set the spike threshold
		RPsettag(indev, 'TLo', H.TDT.TLo);
		% play stim, record data
		[mcresp, ~] = opto_io(S, inpts, indev, outdev, zBUS);      
		% get the monitor response
		[monresp, ~] = opto_readbuf(indev, 'monIndex', 'monData');
		% get the spike response
		[spikes, nspikes, spikerms] = opto_getspikes(indev);
        % get the spike times
		spiketimes = (1000/indev.Fs) * ...
							getSpikebinsFromSpikes(spikes, ...
															handles.H.TDT.SnipLen);
		update_ui_str(handles.textRMS, sprintf('%.4f', spikerms));
		% plot returned values
		% first, demux input data matrices
		[resp, ~] = mcFastDeMux(mcresp, TDT.channels.nInputChannels);
		[pdata, ~] = mcFastDeMux(monresp, TDT.channels.nInputChannels);
        
		% then assign values to plot
		for c = 1:TDT.channels.nInputChannels
			if TDT.channels.RecordChannels{c}
				tmpY = pdata(:, c)';
			else 
				% null values for unrecorded channels (set off of axes limit)
				tmpY = -1e6*ones(size(pdata(:, c)'));
			end
			set(pH(c), 'YData', tmpY + c*yabsmax);
		end
		% show detected spikes
		% draw new ones
		set(tH,	'XData', spiketimes, ...
					'YData', zeros(size(spiketimes)) + ...
											TDT.channels.MonitorChannel*yabsmax);
		% set title string
		title(ax, tstr, 'Interpreter', 'none');
		% force drawing
 		drawnow
		refreshdata

% 		fs = indev.Fs;
% 		incchannels = TDT.channels.nInputChannels;
% 		sniplen = TDT.SnipLen;
% 		save('spikedat.mat', 'spikes', 'nspikes', 'spikerms', 'sniplen', ...
% 							'fs', 'monresp', 'mcresp', 'incchannels', '-MAT');
% 		spikebins = spikes(1 + (0:H.TDT.SnipLen:(length(spikes)-1)));
% 		figure(99)
% 		subplot(211)
% 		plot(pdata(:, 8));
% 		for s = 1:length(spikebins)
% 			text(spikebins(s), pdata(spikebins(s), 8), '*', 'Color', 'g');
% 		end
% 		subplot(212)
% 		plot(spikes);

		% wait for ISI
		pause(0.001*H.audio.ISI)
	end	% END while get(hObject, 'Value')
end	% END if
