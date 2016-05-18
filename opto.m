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

% Last Modified by GUIDE v2.5 17-May-2016 19:54:58

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
		handles.H.TDT.indev.Fs = Fs(2);
		handles.H.TDT.Enable = 1;
		update_ui_str(hObject, 'TDT Disable');
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function checkMonitorOnOff_Callback(hObject, eventdata, handles)
	val = read_ui_val(hObject);
	if handles.H.TDT.Enable
		if val == 1
			% turn on audio monitor for spikes using software trigger 1
			RPtrig(handles.H.TDT.indev, 1);
			handles.H.TDT.MonEnable = 1;
			RPsettag(handles.H.TDT.indev, 'MonChan', handles.H.TDT.MonChan);
		else
			% turn off audio monitor for spikes using software trigger 2
			RPtrig(handles.H.TDT.indev, 2);
			handles.H.TDT.MonEnable = 0;
		end
	else
		update_ui_str(handles.textMsg, ...
							'Cannot use monitor - TDT not enabled');
		update_ui_val(hObject, 0);
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function popupMonitorChannel_Callback(hObject, eventdata, handles)
	val = read_ui_val(hObject);
	if handles.H.TDT.Enable
		RPsettag(handles.H.TDT.indev, 'MonChan', val);
		handles.H.TDT.MonChan = val;
	else
		update_ui_str(handles.textMsg, ...
							'Cannot set monitor channel - TDT not enabled');
		update_ui_val(hObject, handles.H.TDT.MonChan);
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------






%-------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
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
