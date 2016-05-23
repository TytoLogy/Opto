	% Determine run state from value of button - need to do this in order to
	% be able to stop/start
	state = read_ui_val(hObject);
	
	% if user wants to start run, check if tdt hardware is initialized
	if state && ~handles.H.TDT.Enable
		% user started run, but HW not init'ed so abort
		update_ui_val(hObject, 0);
		update_ui_str(handles.textMsg, 'TDT HW not enabled!!!!');
		guidata(hObject, handles);
		return
	
	% if state of button is 0 and TDT hardware is started, stop run
	elseif ~state && handles.H.TDT.Enable
		% Terminate the Run
		update_ui_str(handles.textMsg, 'Search ending...');
		RPtrig(handles.H.TDT.indev, 2);
		guidata(hObject, handles);
		return
	
	else
		% Start I/O
		update_ui_str(handles.textMsg, 'Starting search...');
		
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
		
		RPsettag(handles.H.TDT.indev, 'AcqDur', ...
					ms2bin(handles.H.TDT.AcqDuration, handles.H.TDT.indev.Fs));
		RPsettag(handles.H.TDT.indev, 'SwPeriod', ...
				ms2bin(handles.H.TDT.AcqDuration+1, handles.H.TDT.indev.Fs));
	
		% generate figure, axes
		if isempty(handles.H.fH) || ~ishandle(handles.H.fH)
			handles.H.fH = figure;
			guidata(hObject, handles);
		end
		if isempty(handles.H.ax) || ~ishandle(handles.H.ax)
			handles.H.ax = axes;
			guidata(hObject, handles);
		end
		% store local copy of handle for simplicity in calls
		fH = handles.H.fH;
		figure(fH);
		ax = handles.H.ax;
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
		set(fH, 'Position', [1221 537 560 420]);

		%------------------------------------------------------------
		% main loop
		%------------------------------------------------------------
		% make some local copies of things that won't change in loop
		% to make things more compact textually
		indev = handles.H.TDT.indev;
		outdev = handles.H.TDT.outdev;
		zBUS = handles.H.TDT.zBUS;
		TDT = handles.H.TDT;

		% make sure mute is off
		RPsettag(outdev, 'Mute', 0);		

		rep = 0;
		pause(0.001*handles.H.audio.ISI);
		
		while get(hObject, 'Value')
			rep = rep + 1;
			% generate [2XN] stimulus array. row 1 == output A on RZ6, row 2 = output B
			handles.H.audio.Signal
			switch upper(handles.H.audio.Signal)
				case 'TONE'
					stim = synmonosine(	handles.H.audio.Duration, ...
												outdev.Fs, ...
												handles.H.tone.Frequency, ...
												handles.H.tone.PeakAmplitude, ...
												handles.H.caldata);
					tstr = sprintf('Tone %d Hz, Rep %d', ...
											handles.H.tone.Frequency, rep);
				case 'NOISE'
					stim = synmononoise_fft(	handles.H.audio.Duration, ...
														outdev.Fs, ...
														handles.H.noise.Fmin, ...
														handles.H.noise.Fmax, ...
														handles.H.noise.PeakAmplitude, ...
														handles.H.caldata);
					tstr = sprintf('Noise, Rep %d', rep);
				case 'OFF'
					stim = syn_null(handles.H.audio.Duration, outdev.Fs, 0);
					tstr = sprintf('Off, Rep = %d', rep);
				otherwise
					warning('unknown signal')
			end
			% ramp onset/offset
			stim = sin2array(stim, handles.H.audio.Ramp, outdev.Fs);
			% build stimulus array (2 channel)
			S = [stim; syn_null(handles.H.audio.Duration, outdev.Fs, 0)];

			% Set attenuation levels
			RPsettag(outdev, 'AttenL', handles.H.audio.AttenL);
			RPsettag(outdev, 'AttenR', handles.H.audio.AttenR);

			% play stim, record data
			[mcresp, ~] = opto_io(S, inpts, indev, outdev, zBUS);
			% plot returned values
			[resp, ~] = mcFastDeMux(mcresp, TDT.channels.nInputChannels);
			
			for c = 1:TDT.channels.nInputChannels
				set(pH(c), 'YData', resp(:, c)' + c*yabsmax);
			end
			title(ax, tstr);
			drawnow

			% wait for ISI
			pause(0.001*handles.H.audio.ISI)
		end	% END while get(hObject, 'Value')
	end	% END if
