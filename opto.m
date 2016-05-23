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
	set(handles.popupAudioSignal, 'String', {'Noise'; 'Tone'; 'OFF'});
	update_ui_val(handles.popupAudioSignal, 1);
	
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
%-------------------------------------------------------------------------
% AUDIO Stimulus Settings
%-------------------------------------------------------------------------
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
			handles.H.audio.Signal = 'noise';
			guidata(hObject, handles);
			% enable, make visible Fmax stuff, update Fmax val
		case 'TONE'
			update_ui_str(handles.textMsg, 'Tone stimulus selected');
			handles.H.audio.Signal = 'tone';
			guidata(hObject, handles);
			% disable Fmax ctrls, change Fmin name to Freq, update val
		case 'OFF'
			update_ui_str(handles.textMsg, 'Audio stimulus OFF');
			handles.H.audio.Signal = 'off';
			guidata(hObject, handles);
	end
	update_ui_str(handles.textMsg, ['Stimulus type set to ' stimString]);
	guidata(hObject, handles);
%-------------------------------------------------------------------------	
function editAudioDelay_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, 0.6, handles.H.TDT.SweepPeriod)
		handles.H.audio.Delay = val;
		update_ui_str(handles.textMsg, 'Audio delay set');
		guidata(hObject, handles);
	else
		update_ui_str(handles.textMsg, 'invalid audio Delay');
		update_ui_str(hObject, handles.H.audio.Delay);
	end
	if handles.H.TDT.Enable
		RPsettag(handles.H.TDT.outdev, 'StimDelay', handles.H.audio.Delay);
	end
%-------------------------------------------------------------------------
function editAudioDur_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, 0, handles.H.TDT.SweepPeriod)
		handles.H.audio.Duration = val;
		guidata(hObject, handles);
	else
		update_ui_str(handles.textMsg, 'invalid audio Duration');
		update_ui_str(hObject, handles.H.audio.Duration);
	end
	if handles.H.TDT.Enable
		RPsettag(handles.H.TDT.outdev, 'StimDur', handles.H.audio.Duration);
	end	
%-------------------------------------------------------------------------
function editAudioLevel_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, 0, 100)
		handles.H.audio.Level = val;
		guidata(hObject, handles);
	else
		update_ui_str(handles.textMsg, 'invalid audio Level');
		update_ui_str(hObject, handles.H.audio.Level);
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editAudioRamp_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, 0, handles.H.audio.Duration)
		handles.H.audio.Ramp = val;
		guidata(hObject, handles);
	else
		update_ui_str(handles.textMsg, 'invalid audio Ramp');
		update_ui_str(hObject, handles.H.audio.Ramp);
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editAudioFmin_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	switch handles.H.audio.Signal
		case 'Noise'
			if between(val, 3500, handles.H.audio.Signal.Fmax)
				handles.H.audio.Signal.Fmin = val;
				guidata(hObject, handles);
			else
				update_ui_str(handles.textMsg, 'invalid audio noise Fmin');
				update_ui_str(hObject, handles.H.audio.Signal.Fmin);
			end
		case 'Tone'
			if between(val, 3500, handles.H.TDT.outdev.Fs / 2)
				handles.H.audio.Signal.Frequency = val;
				guidata(hObject, handles);
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
		guidata(hObject, handles);
	else
		update_ui_str(handles.textMsg, 'invalid audio noise Fmax');
		update_ui_str(hObject, handles.H.audio.Signal.Fmax);
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% OPTO Stimulus Settings
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
	if handles.H.TDT.Enable
		RPsettag(handles.H.TDT.indev, 'OptoEnable', handles.H.opto.Enable);
	end
%-------------------------------------------------------------------------
function editOptoDelay_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, 0, handles.H.TDT.SweepPeriod)
		handles.H.opto.Delay = val;
		guidata(hObject, handles);
	else
		update_ui_str(handles.textMsg, 'invalid opto Delay');
		update_ui_str(hObject, handles.H.opto.Delay);
	end
	if handles.H.TDT.Enable
		% set the optical delay (convert to samples)
		RPsettag(handles.H.TDT.indev, 'OptoDelay', ...
						ms2bin(handles.H.opto.Delay, handles.H.TDT.indev.Fs));
	end
%-------------------------------------------------------------------------
function editOptoDur_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, 0, handles.H.TDT.SweepPeriod)
		handles.H.opto.Dur = val;
		guidata(hObject, handles);
	else
		update_ui_str(handles.textMsg, 'invalid opto Dur');
		update_ui_str(hObject, handles.H.opto.Dur);
	end
	if handles.H.TDT.Enable
		% set the optical duration (convert to samples)
		RPsettag(handles.H.TDT.indev, 'OptoDur', ...
						ms2bin(handles.H.opto.Dur, handles.H.TDT.indev.Fs));
	end
%-------------------------------------------------------------------------
function editOptoAmp_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, 0, 2000)
		handles.H.opto.Amp = val;
		guidata(hObject, handles);
	else
		update_ui_str(handles.textMsg, 'invalid opto Amp');
		update_ui_str(hObject, handles.H.opto.Amp);
	end
	if handles.H.TDT.Enable
		% set the optical amplitude (convert to volts)
		RPsettag(handles.H.TDT.indev, 'OptoAmp', 0.001*handles.H.opto.Amp);
	end
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
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% TDT Settings
%-------------------------------------------------------------------------
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
		update_ui_str(handles.textMsg, 'TDT Hardware OFF');
		
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
		update_ui_str(handles.textMsg, 'TDT Hardware ON');
		guidata(hObject, handles)
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editAcqDuration_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	update_ui_str(handles.textMsg, ...
						sprintf('setting AcqDuration to %d ms', val));
	% if TDT HW is enabled, set the tag in the circuit
	if handles.H.TDT.Enable
		% Set the length of time to acquire data
		RPsettag(handles.H.TDT.indev, 'AcqDur', ...
											ms2bin(val, handles.H.TDT.indev.Fs));
		% Set the total sweep period time (AcqDur + 10 ms) on input device
		RPsettag(handles.H.TDT.indev, 'SwPeriod', ...
											ms2bin(val+5, handles.H.TDT.indev.Fs));
		% Set the total sweep period time (AcqDur + 10 ms) on output device
		RPsettag(handles.H.TDT.outdev, 'SwPeriod', ...
											ms2bin(val+5, handles.H.TDT.outdev.Fs));
	end
	% store value
	handles.H.TDT.AcqDuration = val;
	handles.H.TDT.SweepPeriod = val + 10;
	guidata(hObject, handles);
%-------------------------------------------------------------------------

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

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Run Search loop
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function buttonSearch_Callback(hObject, eventdata, handles)
	opto_RunSearch
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Test Script (for curves)
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
