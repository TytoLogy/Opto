function varargout = opto(varargin)
% OPTO MATLAB code for opto.fig
%      OPTO, by itself, creates a new OPTO or raises the existing
%      singleton*.
%
%      H = OPTO returns the handle to a new OPTO or the handle to
%      the existing singleton*.
%
%      OPTO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPTO.M with the given input arguments.
%
%      OPTO('Property','Value',...) creates a new OPTO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before opto_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to opto_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help opto

% Last Modified by GUIDE v2.5 18-May-2016 17:23:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @opto_OpeningFcn, ...
                   'gui_OutputFcn',  @opto_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% --- Executes just before opto is made visible.
function opto_OpeningFcn(hObject, eventdata, handles, varargin)
	% This function has no output args, see OutputFcn.
	% hObject    handle to figure
	% eventdata  reserved - to be defined in a future version of MATLAB
	% handles    structure with handles and user data (see GUIDATA)
	% varargin   command line arguments to opto (see VARARGIN)

	% Choose default command line output for opto
	handles.output = hObject;
	
	handles.H = opto_InitH;
	set(handles.popupAudioSignal, 'String', {'Noise'; 'Tone'});
	clist = cell(16, 1);
	for c = 1:16
		clist{c} = num2str(c);
	end
	set(handles.popupMonitorChannel, 'String', clist);
	% Update handles structure
	guidata(hObject, handles);


%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = opto_OutputFcn(hObject, eventdata, handles) 
	% varargout  cell array for returning output args (see VARARGOUT);
	% hObject    handle to figure
	% eventdata  reserved - to be defined in a future version of MATLAB
	% handles    structure with handles and user data (see GUIDATA)

	% Get default command line output from handles structure
	varargout{1} = handles.output;
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
% --- Executes on button press in checkOptoOnOff.
function checkOptoOnOff_Callback(hObject, eventdata, handles)
	val = read_ui_val(hObject);
	if val == 1
		update_ui_str(hObject, 'ON');
	else
		update_ui_str(hObject, 'OFF');
	end
	handles.H.opto.Enable = val;
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editOptoDelay_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, 0, handles.H.TDT.SweepPeriod)
		handles.H.opto.Delay = val;
	else
		update_ui_str(handles.textMsg, 'invalid opto Delay');
		update_ui_str(hObject, handles.H.opto.Delay);
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editOptoDur_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, 0, handles.H.TDT.SweepPeriod)
		handles.H.opto.Dur = val;
	else
		update_ui_str(handles.textMsg, 'invalid opto Dur');
		update_ui_str(hObject, handles.H.opto.Dur);
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editOptoAmp_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, 0, 2000)
		handles.H.opto.Amp = val;
	else
		update_ui_str(handles.textMsg, 'invalid opto Amp');
		update_ui_str(hObject, handles.H.opto.Amp);
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% --- Executes on selection change in popupAudioSignal.
function popupAudioSignal_Callback(hObject, eventdata, handles)
	% get the Audio Signal String (cell array)
	stimTypes = read_ui_str(hObject);
	% retrieve the search stim  type string that is selected
	stimString = upper(stimTypes{read_ui_val(hObject)});
	switch stimString
		case 'NOISE'
			update_ui_str(handles.textMsg, 'Noise stimulus selected');
			handles.H.audio.signal = handles.H.noise;
			% enable, make visible Fmax stuff, update Fmax val
		case 'TONE'
			update_ui_str(handles.textMsg, 'Tone stimulus selected');
			handles.H.audio.signal = handles.H.tone;
			% disable Fmax ctrls, change Fmin name to Freq, update val
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------	
function checkAudioOnOff_Callback(hObject, eventdata, handles)
	val = read_ui_val(hObject);
	if val == 1
		update_ui_str(hObject, 'ON');
	else
		update_ui_str(hObject, 'OFF');
	end
	handles.H.audio.On = val;
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editAudioDelay_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, 0, handles.H.TDT.SweepDuration)
		handles.H.audio.Delay = val;
	else
		update_ui_str(handles.textMsg, 'invalid audio Delay');
		update_ui_str(hObject, handles.H.audio.Dur);
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editAudioDur_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, 0, handles.H.TDT.SweepDuration)
		handles.H.audio.Duration = val;
	else
		update_ui_str(handles.textMsg, 'invalid audio Duration');
		update_ui_str(hObject, handles.H.audio.Duration);
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editAudioLevel_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, 0, 100)
		handles.H.audio.Level = val;
	else
		update_ui_str(handles.textMsg, 'invalid audio Level');
		update_ui_str(hObject, handles.H.audio.Level);
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editAudioRamp_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, 0, handles.H.audio.Dur)
		handles.H.audio.Ramp = val;
	else
		update_ui_str(handles.textMsg, 'invalid audio Ramp');
		update_ui_str(hObject, handles.H.audio.Ramp);
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editAudioFmin_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	switch handles.H.audio.Signal.Type
		case 'Noise'
			if between(val, 0, handles.H.audio.Signal.Fmax)
				handles.H.audio.Signal.Fmin = val;
			else
				update_ui_str(handles.textMsg, 'invalid audio noise Fmin');
				update_ui_str(hObject, handles.H.audio.Signal.Fmin);
			end
		case 'Tone'
			if between(val, 0, handles.H.TDT.outdev.Fs / 2)
				handles.H.audio.Signal.Frequency = val;
			else
				update_ui_str(handles.textMsg, 'invalid audio tone Frequencu');
				update_ui_str(hObject, handles.H.audio.Signal.Frequency);
			end
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editAudioFmax_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, handles.H.audio.Signal.Fmin, handles.H.TDT.outdev.Fs / 2)
		handles.H.audio.Signal.Fmax = val;
	else
		update_ui_str(handles.textMsg, 'invalid audio noise Fmax');
		update_ui_str(hObject, handles.H.audio.Signal.Fmax);
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% TDT
%-------------------------------------------------------------------------
function buttonTDTEnable_Callback(hObject, eventdata, handles)
	val = read_ui_val(hObject);
	if ( (handles.H.TDT.Enable == 1) && (val == 0) )
		% turn off audio monitor for spikes using software trigger 2
		RPtrig(handles.H.TDT.indev, 2);
		% stop TDT hardware
		[outhandles, ~] = opto_TDTclose(	handles.H.TDT.config, ...
													handles.H.TDT.indev, ... 
													handles.H.TDT.outdev, ...
													handles.H.TDT.zBUS, ...
													handles.H.TDT.PA5L, ...
													handles.H.TDT.PA5R);
		handles.H.TDT.indev = outhandles.indev;
		handles.H.TDT.outdev = outhandles.outdev;
		handles.H.TDT.zBUS = outhandles.zBUS;
		handles.H.TDT.PA5L = outhandles.PA5L;
		handles.H.TDT.PA5R = outhandles.PA5R;
		handles.H.TDT.Enable = 0;
		update_ui_str(hObject, 'TDT Enable');
		
	elseif ( (handles.H.TDT.Enable == 0) && (val == 1) )
		% start TDT hardware
		try
			[outhandles, ~] = opto_TDTopen(	handles.H.TDT.config, ...
														handles.H.TDT.indev, ...
														handles.H.TDT.outdev);
		catch ME
			disp(ME.identifier)
			disp(ME.message)
			error('Cannot open TDT hardware');
		end
		handles.H.TDT.indev = outhandles.indev;
		handles.H.TDT.outdev = outhandles.outdev;
		handles.H.TDT.zBUS = outhandles.zBUS;
		handles.H.TDT.PA5L = outhandles.PA5L;
		handles.H.TDT.PA5R = outhandles.PA5R;
		guidata(hObject, handles);
		% settings
		% opto_TDTsettings() passes settings from the device, tdt, stimulus,
		% channels and optical structs on to tags in the running TDT circuits
		% Fs is a 1X2 array of sample rates for indev and outdev - this is because
		% the actual sample rates often differ from those specified in the software
		% settings due to clock frequency divisor issues
		Fs = opto_TDTsettings(	handles.H.TDT.indev, ...
										handles.H.TDT.outdev, ...
										handles.H.TDT, ...
										handles.H.audio, ...
										handles.H.TDT.channels, ...
										handles.H.opto);		

		handles.H.TDT.indev.Fs = Fs(1);
		handles.H.TDT.outdev.Fs = Fs(2);
		handles.H.TDT.Enable = 1;
		update_ui_str(hObject, 'TDT Disable');
		guidata(hObject, handles)
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editAcqDuration_Callback(hObject, eventdata, handles)
	val = read_ui_val(hObject);
	update_ui_str(handles.textMsg, ...
						sprintf('setting AcqDuration to %d ms', val));
	% if TDT HW is enabled, set the tag in the circuit
	if handles.H.TDT.Enable
		RPsettag(handles.H.TDT.indev, 'AcqDur', ...
											ms2bin(val, handles.H.TDT.indev.Fs));
		RPsettag(handles.H.TDT.indev, 'SwpDur', ...
											ms2bin(val+1, handles.H.TDT.indev.Fs));
	end
	% store value
	handles.H.TDT.AcqDuration = val;
	guidata(hObject, handles);

%-------------------------------------------------------------------------
% Monitor
%-------------------------------------------------------------------------
function checkMonitorOnOff_Callback(hObject, eventdata, handles)
	val = read_ui_val(hObject);
	if val
		update_ui_str(handles.textMsg, 'turning monitor ON');
	else
		update_ui_str(handles.textMsg, 'turning monitor OFF');
	end
	% if TDT HW is enabled, send trigger to turn monitor on or off
	if handles.H.TDT.Enable
		if val == 1
			% turn on audio monitor for spikes using software trigger 1
			RPtrig(handles.H.TDT.indev, 1);
			% update values just to be sure
			RPsettag(handles.H.TDT.indev, 'MonChan', handles.H.TDT.MonChan);
			RPsettag(handles.H.TDT.indev, 'MonGain', handles.H.TDT.MonitorGain);
		else
			% turn off audio monitor for spikes using software trigger 2
			RPtrig(handles.H.TDT.indev, 2);
		end
	end
	% store value
	handles.H.TDT.MonEnable = val;
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function popupMonitorChannel_Callback(hObject, eventdata, handles)
	val = read_ui_val(hObject);
	update_ui_str(handles.textMsg, ...
						sprintf('setting monitor channel to %d', val));
	% if TDT HW is enabled, set the tag in the circuit
	if handles.H.TDT.Enable
		RPsettag(handles.H.TDT.indev, 'MonChan', val);
	end
	% store value
	handles.H.TDT.MonChan = val;
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editMonGain_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	update_ui_str(handles.textMsg, ...
						sprintf('setting monitor gain to %d', val));
	% if TDT HW is enabled, set the tag in the circuit
	if handles.H.TDT.Enable
		RPsettag(handles.H.TDT.indev, 'MonGain', val);
	end
	% store value
	handles.H.TDT.MonitorGain = val;
	guidata(hObject, handles);
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------


function editISI_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if val < 0
		update_ui_str(handles.textMsg, 'ISI must be positive');
		update_ui_str(hObject, handles.H.audio.ISI);
	else
		handles.H.audio.ISI = val;
	end
	guidata(hObject, handles);


%-------------------------------------------------------------------------
% Run Search loop
%-------------------------------------------------------------------------
function buttonSearch_Callback(hObject, eventdata, handles)
	% Determine run state from value of button - need to do this in order to be
	% able to stop/start 
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

		% turn on audio monitor for spikes using software trigger 1
		RPtrig(handles.H.TDT.indev, 1);

		% calculate # of points to acquire (in units of samples)
		inpts = ms2bin(handles.H.TDT.AcqDuration, handles.H.TDT.indev.Fs);
		
		RPsettag(handles.H.TDT.indev, 'AcqDur', ...
					ms2bin(handles.H.TDT.AcqDuration, handles.H.TDT.indev.Fs));
		RPsettag(handles.H.TDT.indev, 'SwPeriod', ...
				ms2bin(handles.H.TDT.AcqDuration+1, handles.H.TDT.indev.Fs));
	
		% generate figure
		if isempty(handles.H.fH)
			handles.H.fH = figure;
			handles.H.ax = axes;
			guidata(hObject, handles);
		end
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

		%------------------------------------------------------------
		% main loop
		%------------------------------------------------------------
		audio = handles.H.audio;
		indev = handles.H.TDT.indev;
		outdev = handles.H.TDT.outdev;
		zBUS = handles.H.TDT.zBUS;
		% make sure mute is off
		RPsettag(outdev, 'Mute', 0);		

		rep = 0;
		pause(0.001*audio.ISI);
		
		freq = 8000;
		
		while get(hObject, 'Value')
			rep = rep + 1;
			% generate [2XN] stimulus array. row 1 == output A on RZ6, row 2 = output B
			stim = synmonosine(audio.Duration, outdev.Fs, freq, 1, 0);
			stim = sin2array(stim, audio.Ramp, outdev.Fs);
			nullstim = syn_null(audio.Duration, outdev.Fs, 0);
			S = [stim; nullstim];
		

			% Set attenuation levels
			RPsettag(outdev, 'AttenL', 0);
			RPsettag(outdev, 'AttenR', 120);

			[mcresp, ~] = opto_io(S, inpts, indev, outdev, zBUS);
			% plot returned values
			[resp, ~] = mcFastDeMux(mcresp, handles.H.TDT.channels.nInputChannels);

			for c = 1:handles.H.TDT.channels.nInputChannels
				set(pH(c), 'YData', resp(:, c)' + c*yabsmax);
			end
			title(ax, sprintf('Freq: %.2f, Rep: %d', freq, rep));
			
			drawnow

			pause(0.001*audio.ISI)
			
		end	% END while get(hObject, 'Value')
		
	end	% END if

	
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Test Script
%-------------------------------------------------------------------------
function buttonRunTestScript_Callback(hObject, eventdata, handles)
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function buttonEditTestScript_Callback(hObject, eventdata, handles)
	edit(handles.H.TestScript)
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function buttonLoadTestScript_Callback(hObject, eventdata, handles)
	[filename, pathname, findex] = uigetfile('*.m', 'Select Test Script File');
	if findex
		update_ui_str(handles.textMsg, 'loading test script');
		handles.H.TestScript = fullfile(pathname, filename);
	else
		update_ui_str(handles.textMsg, 'cancelled test script load');
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------


	
	





%-------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
%-------------------------------------------------------------------------
function editAcqDuration_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
%-------------------------------------------------------------------------
function editMonGain_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
%-------------------------------------------------------------------------
function textTestScript_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
	
%-------------------------------------------------------------------------
function editISI_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
%-------------------------------------------------------------------------
function editOptoDelay_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function editOptoDur_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function editOptoAmp_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
%-------------------------------------------------------------------------
	function popupAudioSignal_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function editAudioDelay_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function editAudioDur_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function editAudioLevel_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function editAudioRamp_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function editAudioFmin_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
function editAudioFmax_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
%-------------------------------------------------------------------------
function popupMonitorChannel_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------


% --- Executes on button press in buttonTest.
function buttonTest_Callback(hObject, eventdata, handles)
	% indev frequency (Hz) = 48828.125
	% outdev frequency (Hz) = 195312.5

	%% configure structs
	% lock file
	config.TDTLOCKFILE = fullfile(pwd, 'tdtlockfile.mat');
	config.CONFIGNAME = 'RZ6OUT200K_RZ5DIN';
	% function handles
	config.ioFunc = @opto_io;
	config.TDTsetFunc = @TDT_opto_settings;
	config.setattenFunc = @RZ6setatten;
	% input device
	config.indev.hardware = 'RZ5D';
	config.indev.Fs = 50000;
	config.indev.Circuit_Path = 'C:\TytoLogy\Toolboxes\TDTToolbox\Circuits\RZ5D';
	config.indev.Circuit_Name = 'RZ5D_50k_16In_1Out_zBus.rcx';
	config.indev.Dnum = 1; % device number
	% output device
	config.outdev.hardware = 'RZ6';
	config.outdev.Fs = 200000;
	config.outdev.Circuit_Path = 'C:\TytoLogy\Toolboxes\TDTToolbox\Circuits\RZ6'; 
	config.outdev.Circuit_Name = 'RZ6_2ChannelOutputAtten_zBus.rcx';
	config.outdev.Dnum = 1; % device number


	% -- TDT parameters
	% tdt = FOCHS_init('TDT:PARAMS');
	tdt.AcqDuration = 1000;
	tdt.SweepPeriod = tdt.AcqDuration + 10;
	tdt.TTLPulseDur = 1;
	tdt.CircuitGain = 20000;      % gain for TDT circuit
	tdt.MonitorGain = 20000;
	tdt.HPEnable = 1;         % enable high pass filter
	tdt.HPFreq = 100;         % high pass frequency
	tdt.LPEnable = 1;         % enable low pass filter
	tdt.LPFreq = 10000;       % low pass frequency

	% -- animal info
	%animal = FOCHS_init('ANIMAL');
	animal.Animal = '000';
	animal.Unit = '0';
	animal.Rec = '0';
	animal.Date = TytoLogy_datetime('date');
	animal.Time = TytoLogy_datetime('time');
	animal.Pen = '0';
	animal.AP = '0';
	animal.ML = '0';
	animal.Depth = '0';
	animal.comments = '';

	% stimulus = FOCHS_init('STIMULUS:PARAMS');
	stimulus.ISI = 500;
	stimulus.Duration = 200;
	stimulus.Delay = 100;
	stimulus.Ramp = 5;
	stimulus.RadVary = 0;
	stimulus.Frozen = 0;

	% tone stimulus
	tone.frequency = 5000;
	tone.amplitude = 1;

	% -- TDT I/O channels ---- default TDT hardware = 'NO_TDT'
	% channels = FOCHS_init('CHANNELS:RZ6_RZ5D');
	channels.OutputChannelL = 1;
	channels.OutputChannelR = 2;
	channels.nInputChannels = 16;
	channels.InputChannels = 1:channels.nInputChannels;
	channels.OpticalChannel = 10;
	channels.MonitorChannel = 1;
	channels.MonitorOutputChannel = 9; 

	% -- parameters for optical stimulus
	% optical = FOCHS_init('OPTICAL');
	optical.Enable = 1;
	optical.Amp = 1000;
	optical.Dur = 100;
	optical.Delay = 100;
	optical.Channel = 10;	% note that this is also set in RZ6+RZ5D

	%% start TDT hardware
	try
		[outhandles, outflag] = opto_TDTopen(config); %#ok<ASGLU>
	catch ME
		disp(ME.identifier)
		disp(ME.message)
		error('Cannot open TDT hardware');
	end
	indev = outhandles.indev;
	outdev = outhandles.outdev;
	zBUS = outhandles.zBUS;
	PA5L = outhandles.PA5L;
	PA5R = outhandles.PA5R;

	%% settings
	% FOCHS_RZ6RZ5Dsettings() passes settings from the device, tdt, stimulus,
	% channels and optical structs on to tags in the running TDT circuits
	% Fs is a 1X2 array of sample rates for indev and outdev - this is because
	% the actual sample rates often differ from those specified in the software
	% settings due to clock frequency divisor issues
	Fs = opto_TDTsettings(indev, outdev, tdt, stimulus, channels, optical);

	%% do stuff

	% frequencies to play out
	freqs = 440 * [1 2 3 4];
	% number of reps per stimulus
	nreps = 1;

	% turn on audio monitor for spikes using software trigger 1
	RPtrig(indev, 1);

	%%
	% calculate # of points to acquire (in units of samples)
	inpts = ms2bin(tdt.AcqDuration, indev.Fs);

	% generate figure
	fH = figure;
	ax = axes;
	xv = linspace(0, tdt.AcqDuration, inpts);
	xlim([0, inpts]);
	yabsmax = 5;

	tmpData = zeros(inpts, channels.nInputChannels);
	for n = 1:channels.nInputChannels
		tmpData(:, n) = n*(yabsmax) + 2*(2*rand(inpts, 1)-1);
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
	%%

	% main loop
	pause(0.001*stimulus.ISI);
	for f = 1:length(freqs)

		% generate [2XN] stimulus array. row 1 == output A on RZ6, row 2 = output B
		stim = synmonosine(stimulus.Duration, outdev.Fs, freqs(f), tone.amplitude, 0);
		stim = sin2array(stim, 1, outdev.Fs);
		nullstim = syn_null(stimulus.Duration, outdev.Fs, 0);
		S = [stim; nullstim];


		% Set attenuation levels
		RPsettag(outdev, 'AttenL', 0);
		RPsettag(outdev, 'AttenR', 120);
		% make sure mute is off
		RPsettag(outdev, 'Mute', 0);

		for n = 1:nreps
			% play stimulus, return read values
			if indev.status && outdev.status && zBUS.status
				[mcresp, mcpts] = opto_io(S, inpts, indev, outdev, zBUS);
			else
				error('stati == 0');
			end

			% plot returned values
			[resp, npts] = mcFastDeMux(mcresp, channels.nInputChannels);

			for c = 1:channels.nInputChannels
				set(pH(c), 'YData', resp(:, c) + c*yabsmax);
			end
			title(sprintf('Freq: %.2f, Rep: %d', freqs(f), n));
			drawnow
			pause(0.001*stimulus.ISI)
		end
	end

	% turn off audio monitor for spikes using software trigger 2
	RPtrig(indev, 2);

	%% stop TDT hardware
	[outhandles, outflag] = opto_TDTclose(config, indev, outdev, zBUS, PA5L, PA5R);
	indev = outhandles.indev;
	outdev = outhandles.outdev;
	zBUS = outhandles.zBUS;
	PA5L = outhandles.PA5L;
	PA5R = outhandles.PA5R;



