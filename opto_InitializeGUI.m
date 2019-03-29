function handles = opto_InitializeGUI(hObject, eventdata, ...
																		handles, varargin)
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Opto program
%------------------------------------------------------------------------
% Initialize GUI
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Input Arguments:
%	From opto_OpeningFcn:
%		hObject
% 		eventdata
% 		handles
%		varargin
% 
% Output Arguments:
% 	handles
%------------------------------------------------------------------------
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Sharad Shanbhag 
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Created: 28 September, 2016 (SJS)
%------------------------------------------------------------------------
% Revisions
%	22 Oct 2017 (SJS): new cal file
%------------------------------------------------------------------------
%------------------------------------------------------------------------

%----------------------------------------------------------------
% initialize H struct (contains all internal application data)
%----------------------------------------------------------------
handles.H = opto_InitH;
guidata(hObject, handles);

%----------------------------------------------------------------
% Calibration data
%----------------------------------------------------------------
calpath = 'C:\TytoLogy\Experiments\CalData';
% calfile = 'Optorig_20170601_TDT3981_4k90k_5V_cal.mat';
calfile = 'Optorig_20171022_TDT3981_4k-91k_5V_cal.mat';
if ~exist(fullfile(calpath, calfile), 'file')
	warning('Calibration file %s not found!', fullfile(calpath, calfile));
	tmpcal = [];
else
	% load the calibration data
	tmpcal = load_cal(fullfile(calpath, calfile));
end
% if tmpcal is a structure, load of calibration file was
% hopefully successful, so save it in the handles info
if isstruct(tmpcal)
	handles.H.caldata = tmpcal;
	% update signal limits based on calibration data
	handles.H.Lim.F = [	handles.H.caldata.Freqs(1) ...
								handles.H.caldata.Freqs(end)	];
	update_ui_str(handles.textCalibration, fullfile(calpath, calfile));
	% update noise and tone DA scale factors from calibration data
	handles.H.noise.PeakAmplitude = handles.H.caldata.DAscale;
	handles.H.tone.PeakAmplitude = handles.H.caldata.DAscale;
	% update settings
	guidata(hObject, handles);
else
	% otherwise, throw error dialog
	errordlg(['Error loading calibration file ' ...
					fullfile(calpath, calfile)], ...
					'LoadCal error'); 
end

%----------------------------------------------------------------
% update UI
%----------------------------------------------------------------
% window position and size
set(handles.figure1, 'Units', 'characters');
set(handles.figure1, 'Position', [8.2000 46.3077 120 54]);
% audio stimulus selector (!!!ADD SEARCH!!!)
set(handles.popupAudioSignal, 'String', ...
				{'Noise'; 'Tone'; '.wav'; 'Search'; 'BlockSearch'; 'OFF'});
update_ui_val(handles.popupAudioSignal, 1);	
% channels 
set(handles.tableChannelSelect, 'Data', ...
										handles.H.TDT.channels.RecordChannels);
set(handles.tableChannelSelect, 'ColumnName', 'Record');
guidata(hObject, handles);

% update Level slider limits and values
update_ui_val(handles.sliderAudioLevel, 50);
% update Fmin slider limits and values
set(handles.sliderAudioFmin, 'Min', handles.H.Lim.F(1));
set(handles.sliderAudioFmin, 'Max', handles.H.Lim.F(2));
update_ui_val(handles.sliderAudioFmin, handles.H.Lim.F(1));
% update Fmax slider limits and values
set(handles.sliderAudioFmax, 'Min', handles.H.Lim.F(1));
set(handles.sliderAudioFmax, 'Max', handles.H.Lim.F(2));
update_ui_val(handles.sliderAudioFmax, handles.H.Lim.F(2));
guidata(hObject, handles);


%----------------------------------------------------------------
% list of channels for monitor popup
%----------------------------------------------------------------
clist = cell(16, 1);
for c = 1:16
	clist{c} = num2str(c);
end
set(handles.popupMonitorChannel, 'String', clist);
update_ui_val(handles.popupMonitorChannel, ...
										handles.H.TDT.channels.MonitorChannel);

%----------------------------------------------------------------
% TDT things
%----------------------------------------------------------------
update_ui_str(handles.editTLo, sprintf('%d', handles.H.TDT.TLo));

