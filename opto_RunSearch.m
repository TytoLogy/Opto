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
		% turn off monitor using software trigger 2 sent to indev
		RPtrig(handles.H.TDT.indev, 2);
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
							
		% build filter
		fband = [handles.H.TDT.HPFreq handles.H.TDT.LPFreq] ./ ...
							(0.5 * handles.H.TDT.indev.Fs);
		[filtB, filtA] = butter(3, fband);

		% turn on audio monitor for spikes using software trigger 1
		RPtrig(handles.H.TDT.indev, 1);

		% calculate # of points to acquire (in units of samples)
		inpts = ms2bin(handles.H.TDT.AcqDuration, handles.H.TDT.indev.Fs);
		
		% set acquisition duration and sweep period for indev.
		RPsettag(handles.H.TDT.indev, 'AcqDur', ...
					ms2bin(handles.H.TDT.AcqDuration, handles.H.TDT.indev.Fs));
		RPsettag(handles.H.TDT.indev, 'SwPeriod', ...
				ms2bin(handles.H.TDT.AcqDuration+1, handles.H.TDT.indev.Fs));
	
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
		set(fH, 'Position', [861 204 557 800]);
		xlabel('Time (ms)')
		ylabel('Channel')
		set(ax, 'Color', 0.75*[1 1 1]);
		set(fH, 'Color', 0.75*[1 1 1]);
		set(fH, 'ToolBar', 'none');

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
		
		% make sure mute is off
		RPsettag(outdev, 'Mute', 0);		

		rep = 0;
		pause(0.001*H.audio.ISI);
		
		while get(hObject, 'Value')
			rep = rep + 1;
			% update the H stimulus info from GUI settings
			% this is a kludge, but there's no easy way to do this from
			% within a loop (other than using an "evalin" sort of thing to 
			% evaluate the call within a different workspace, which is
			% perhaps an even greater kludge...)
			H = update_H_from_GUI(handles);

			% generate [2XN] stimulus array. 
			% row 1 == output A on RZ6, row 2 = output B
			switch upper(H.audio.Signal)
				case 'TONE'
					stim = synmonosine(	H.audio.Duration, ...
												outdev.Fs, ...
												H.tone.Frequency, ...
												H.caldata.DAscale, ...
												H.caldata);
					tstr = sprintf('Tone %d Hz, Rep %d', ...
											H.tone.Frequency, rep);
				case 'NOISE'
					stim = synmononoise_fft(	H.audio.Duration, ...
														outdev.Fs, ...
														H.noise.Fmin, ...
														H.noise.Fmax, ...
														H.caldata.DAscale, ...
														H.caldata);
					tstr = sprintf('Noise [%d:%d] kHz, Rep %d', ...
											0.001*H.noise.Fmin, ...
											0.001*H.noise.Fmax, rep);
				case 'OFF'
					stim = syn_null(H.audio.Duration, outdev.Fs, 0);
					tstr = sprintf('Off, Rep = %d', rep);
				otherwise
					warning('unknown signal')
			end
			% ramp onset/offset
			stim = sin2array(stim, H.audio.Ramp, outdev.Fs);
			% build stimulus array (2 channel)
			S = [stim; syn_null(H.audio.Duration, outdev.Fs, 0)];

			if strcmpi(H.audio.Signal, 'OFF')
				AttenL = 120;
			else
				AttenL = figure_mono_atten(H.audio.Level, ...
													rms(stim), H.caldata);
				if AttenL <= 0
					AttenL = 0;
					optomsg(handles, 'Attenuation at minimum!');
				elseif AttenL >= 120
					AttenL = 120;
					optomsg(handles, 'Attenuation at maximum!');
				else
					optomsg(handles, sprintf('Rep %d: %s, atten: %.1f dB', ...
														rep, H.audio.Signal, AttenL));
				end
			end
			% Right attenuator is set to 120 since it is unused
			AttenR = 120;
			% Set attenuation levels
			RPsettag(outdev, 'AttenL', AttenL);
			RPsettag(outdev, 'AttenR', AttenR);
			
			% play stim, record data
			[mcresp, ~] = opto_io(S, inpts, indev, outdev, zBUS);
			
			% plot returned values
			[resp, ~] = mcFastDeMux(mcresp, TDT.channels.nInputChannels);
			for c = 1:TDT.channels.nInputChannels
				if TDT.channels.RecordChannels{c}
					tmpY = filtfilt(filtB, filtA, sin2array(resp(:, c)', 5, indev.Fs));
				else
					tmpY =0*resp(:, c)';
				end
				set(pH(c), 'YData', tmpY + c*yabsmax);
			end
			title(ax, tstr);
			drawnow

			% wait for ISI
			pause(0.001*H.audio.ISI)
		end	% END while get(hObject, 'Value')
	end	% END if
