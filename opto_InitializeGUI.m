function handles = opto_InitializeGUI(hObject, eventdata, handles, varargin)
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
calfile = 'Optorig_20170601_TDT3981_4k90k_5V_cal.mat';
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
	% updatelimits based on calibration data
	handles.H.Lim.F = [	handles.H.caldata.Freqs(1) ...
								handles.H.caldata.Freqs(end)	];
	update_ui_str(handles.textCalibration, fullfile(calpath, calfile));
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
set(handles.figure1, 'Position', [8.2000 46.3077 148.4000 34.5385]);
% audio stimulus selector (!!!ADD SEARCH!!!)
set(handles.popupAudioSignal, 'String', ...
								{'Noise'; 'Tone'; '.wav'; 'Search'; 'BlockSearch'; 'OFF'});
update_ui_val(handles.popupAudioSignal, 1);	
% channels 
set(handles.tableChannelSelect, 'Data', ...
										handles.H.TDT.channels.RecordChannels);
set(handles.tableChannelSelect, 'ColumnName', 'Record');
guidata(hObject, handles)

%----------------------------------------------------------------
% list of channels for monitor popup
%----------------------------------------------------------------
clist = cell(16, 1);
for c = 1:16
	clist{c} = num2str(c);
end
set(handles.popupMonitorChannel, 'String', clist);

%----------------------------------------------------------------
% TDT things
%----------------------------------------------------------------
update_ui_str(handles.editTLo, sprintf('%d', handles.H.TDT.TLo));

