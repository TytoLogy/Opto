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

% Last Modified by GUIDE v2.5 08-Sep-2016 12:58:51

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

	%----------------------------------------------------------------
	% Choose default command line output for opto
	%----------------------------------------------------------------
	handles.output = hObject;
	%----------------------------------------------------------------
	% initialize H struct (contains all internal application data)
	%----------------------------------------------------------------
	handles.H = opto_InitH;
	guidata(hObject, handles);
	%----------------------------------------------------------------
	% Calibration data
	%----------------------------------------------------------------
	calfile = 'Optorig_TDTxxxx_4k-90k_5V_cal.mat';
	% load the calibration data
	tmpcal = load_cal(calfile);
	% if tmpcal is a structure, load of calibration file was
	% hopefully successful, so save it in the handles info
	if isstruct(tmpcal)
		handles.H.caldata = tmpcal;
		% updatelimits based on calibration data
		handles.H.Lim.F = [handles.H.caldata.Freqs(1) handles.H.caldata.Freqs(end)];
		update_ui_str(handles.textCalibration, calfile);
		% update settings
		guidata(hObject, handles);
	else
		errordlg(['Error loading calibration file ' calfile], ...
					'LoadCal error'); 
	end
	
	%----------------------------------------------------------------
	% update UI
	%----------------------------------------------------------------
	% window position and size
 	set(handles.figure1, 'Position', [38 557 739 447]);
	% audio stimulus selector
	set(handles.popupAudioSignal, 'String', {'Noise'; 'Tone'; '.wav'; 'OFF'});
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
			optomsg(handles, 'Noise stimulus selected');
			handles.H.audio.Signal = 'noise';
			guidata(hObject, handles);
			% enable, make visible Fmax stuff, update Fmax val
% 			enable_ui(handles.textAudioFmin);
% 			update_ui_str(handles.textAudioFmin, 'Fmin (Hz)');
% 			enable_ui(handles.editAudioFmin);
% 			enable_ui(handles.textAudioFmax);
% 			enable_ui(handles.editAudioFmax);
			handles = updateAudioControlsFromType(hObject, handles, stimString);
			guidata(hObject, handles);
		case 'TONE'
			optomsg(handles, 'Tone stimulus selected');
			handles.H.audio.Signal = 'tone';
			guidata(hObject, handles);
			% disable Fmax ctrls, change Fmin name to Freq, update val
% 			enable_ui(handles.textAudioFmin);
% 			update_ui_str(handles.textAudioFmin, 'Freq. (Hz)');
% 			enable_ui(handles.editAudioFmin);
% 			disable_ui(handles.textAudioFmax);
% 			disable_ui(handles.editAudioFmax);
			handles = updateAudioControlsFromType(hObject, handles, stimString);
			guidata(hObject, handles);
		case '.WAV'
			optomsg(handles, '.WAV file stimulus selected');
			handles.H.audio.Signal = 'wav';
			guidata(hObject, handles);
			% disable Dur, Ramp;, Fmin, Fmax ctrls, update val
% 			disable_ui(handles.textAudioDur);
% 			disable_ui(handles.editAudioDur);
% 			disable_ui(handles.textAudioRamp);
% 			disable_ui(handles.editAudioRamp);
% 			disable_ui(handles.textAudioFmin);
% 			disable_ui(handles.editAudioFmin);
% 			disable_ui(handles.textAudioFmax);
% 			disable_ui(handles.editAudioFmax);
			handles = updateAudioControlsFromType(hObject, handles, stimString);
			guidata(hObject, handles);		
		case 'OFF'
			optomsg(handles, 'Audio stimulus OFF');
			handles.H.audio.Signal = 'off';
			guidata(hObject, handles);
% 			disable_ui(handles.textAudioFmin);
% 			disable_ui(handles.editAudioFmin);
% 			disable_ui(handles.textAudioFmax);
% 			disable_ui(handles.editAudioFmax);
			handles = updateAudioControlsFromType(hObject, handles, stimString);
			guidata(hObject, handles);
	end
	optomsg(handles, ['Stimulus type set to ' stimString]);
	guidata(hObject, handles);
%-------------------------------------------------------------------------	
function editAudioDelay_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, 0.6, handles.H.TDT.SweepPeriod)
		handles.H.audio.Delay = val;
		optomsg(handles, 'Audio delay set');
		guidata(hObject, handles);
	else
		optomsg(handles, 'invalid audio Delay');
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
		optomsg(handles, 'invalid audio Duration');
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
		optomsg(handles, 'invalid audio Level');
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
		optomsg(handles, 'invalid audio Ramp');
		update_ui_str(hObject, handles.H.audio.Ramp);
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editAudioFmin_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	switch upper(handles.H.audio.Signal)
		case 'NOISE'
			if between(val, 3500, handles.H.noise.Fmax)
				handles.H.noise.Fmin = val;
				guidata(hObject, handles);
				optomsg(handles, sprintf('Noise Fmin: %.0f', ...
													handles.H.noise.Fmin));
			else
				optomsg(handles, 'invalid audio noise Fmin');
				update_ui_str(hObject, handles.H.noise.Fmin);
			end
		case 'TONE'
			if between(val, 3500, handles.H.TDT.outdev.Fs / 2)
				handles.H.tone.Frequency = val;
				guidata(hObject, handles);
				optomsg(handles, sprintf('Tone Freq: %.0f', ...
													handles.H.tone.Frequency));
			else
				optomsg(handles, 'invalid audio tone Frequency');
				update_ui_str(hObject, handles.H.tone.Frequency);
			end
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editAudioFmax_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	if between(val, handles.H.noise.Fmin, ...
							handles.H.TDT.outdev.Fs / 2)
		handles.H.noise.Fmax = val;
		guidata(hObject, handles);
		optomsg(handles, sprintf('Noise Fmax: %.0f', ...
													handles.H.noise.Fmax));
	else
		optomsg(handles, 'invalid audio noise Fmax');
		update_ui_str(hObject, handles.H.noise.Fmax);
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editAudioWavFile_Callback(hObject, eventdata, handles)
%-------------------------------------------------------------------------
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
		optomsg(handles, 'invalid opto Delay');
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
		optomsg(handles, 'invalid opto Dur');
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
		optomsg(handles, 'invalid opto Amp');
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
		optomsg(handles, 'ISI must be positive');
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
		optomsg(handles, 'TDT Hardware OFF');
		
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
		optomsg(handles, 'TDT Hardware ON');
		guidata(hObject, handles)
	end
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editAcqDuration_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	optomsg(handles, sprintf('setting AcqDuration to %d ms', val));
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
	handles.H.TDT.SweepPeriod = val + 5;
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editCircuitGain_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	optomsg(handles, sprintf('setting CircuitGain to %d', val));
	% if TDT HW is enabled, set the tag in the circuit
	% note that since this is addressing the circuit directly, it will
	% take affect immediately and without need for action in running
	% scripts or searching
	if handles.H.TDT.Enable
		% Set the circuit gain
		RPsettag(handles.H.TDT.indev, 'Gain', val);
	end
	% store value
	handles.H.TDT.CircuitGain = val;
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editHPFreq_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	optomsg(handles, sprintf('setting HP filter freq to %d', val));
	% if TDT HW is enabled, set the tag in the circuit
	% note that since this is addressing the circuit directly, it will
	% take affect immediately and without need for action in running
	% scripts or searching
	if handles.H.TDT.Enable
		% set the high pass filter
		RPsettag(handles.H.TDT.indev, 'HPFreq', val);
	end
	% store value
	handles.H.TDT.HPFreq = val;
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editLPFreq_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	optomsg(handles, sprintf('setting LP filter freq to %d', val));
	% if TDT HW is enabled, set the tag in the circuit
	% note that since this is addressing the circuit directly, it will
	% take affect immediately and without need for action in running
	% scripts or searching
	if handles.H.TDT.Enable
		% set the low pass filter
		RPsettag(handles.H.TDT.indev, 'LPFreq', val);
	end
	% store value
	handles.H.TDT.LPFreq = val;
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function tableChannelSelect_CellEdit_Callback(hObject, eventdata, handles)
	cellD = get(hObject, 'Data');
	matD = cell2mat(cellD);
	handles.H.TDT.channels.RecordChannels = cellD;
	handles.H.TDT.channels.nRecordChannels = sum(matD);
	handles.H.TDT.channels.RecordChannelList = find(matD);
	set(hObject, 'Data', num2cell(matD))
	optomsg(handles, 'Changing Channels to Record...');
	guidata(hObject, handles);
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% Monitor
%-------------------------------------------------------------------------
function checkMonitorOnOff_Callback(hObject, eventdata, handles)
	val = read_ui_val(hObject);
	if val
		optomsg(handles, 'turning monitor ON');
	else
		optomsg(handles, 'turning monitor OFF');
	end
	% if TDT HW is enabled, send trigger to turn monitor on or off
	if handles.H.TDT.Enable
		if val == 1
			% turn on audio monitor for spikes using software trigger 1
			RPtrig(handles.H.TDT.indev, 1);
			% update channel and gain values in RP circuit just to be sure
			RPsettag(handles.H.TDT.indev, 'MonChan', ...
										handles.H.TDT.channels.MonitorChannel);
			RPsettag(handles.H.TDT.indev, 'MonOutChan', ...
										handles.H.TDT.channels.MonitorOutputChannel);
			RPsettag(handles.H.TDT.indev, ...
											'MonGain', handles.H.TDT.MonitorGain);
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
	optomsg(handles, sprintf('setting monitor channel to %d', val));
	% if TDT HW is enabled, set the tag in the circuit
	if handles.H.TDT.Enable
		RPsettag(handles.H.TDT.indev, 'MonChan', val);
	end
	% store value
	handles.H.TDT.channels.MonitorChannel = val;
	guidata(hObject, handles);
%-------------------------------------------------------------------------
function editMonGain_Callback(hObject, eventdata, handles)
	val = read_ui_str(hObject, 'n');
	optomsg(handles, sprintf('setting monitor gain to %d', val));
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
	% execute RunSearch script
	opto_RunSearch
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Test Script (for curves)
%-------------------------------------------------------------------------
function buttonRunTestScript_Callback(hObject, eventdata, handles)
	% make sure TDT is enabled
	if ~handles.H.TDT.Enable
		optomsg(handles, 'Please enable TDT hardware!');
		return
	end
	
	% perform some checks, load script information
	if isempty(handles.H.TestScript)
		optomsg(handles, 'Please load a Test Script')
		return
	elseif ~exist(handles.H.TestScript, 'file')
		optomsg(handles, ['Test Script file ' handles.H.TestScript ...
									' not found!']);
		return
	else
		% load test information from script (this will define the 
		% "test" struct
		run(handles.H.TestScript);
	end
	
	% update date and time in animal struct
	handles.H.animal.Date = TytoLogy_datetime('date_compact');
	handles.H.animal.Time = TytoLogy_datetime('time');
	guidata(hObject, handles);
	
	% create filename from animal info
	%	animal # _ date _ unit _ Penetration # _ Depth _ type .dat
	defaultfile = sprintf('%s_%s_%s_%s_%s_%s.dat', ...
									handles.H.animal.Animal, ...
									handles.H.animal.Date, ...
									handles.H.animal.Unit, ...
									handles.H.animal.Pen, ...
									handles.H.animal.Depth, ...
									test.Type); %#ok<*NODEF>
	if ~exist(handles.H.DefaultOutputDir, 'dir')
		mkdir(handles.H.DefaultOutputDir);
	end
	
	defaultfile = fullfile(handles.H.DefaultOutputDir, defaultfile);

	[fname, pname] = uiputfile('*.dat', 'Save Data', defaultfile);

	if fname == 0
		optomsg(handles, 'Run Test Script Cancelled');
		return
	else
		datafile = fullfile(pname, fname);
		optomsg(handles, ['Writing data to file: ' datafile]);
	end
	
	[stimcache, stimseq] = opto_buildStimCache(test, handles.H.TDT, ...
																handles.H.caldata);
	handles.H.stimcache = stimcache;
	handles.H.stimseq = stimseq;
	guidata(hObject, handles);
	save stims.mat stimcache stimseq
	% add stimseq to test struct (kludgey...)
	test.stimseq = stimseq;
	
	% Play stimuli in cache, record neural data
	testdata = opto_playCache(handles, datafile, stimcache, test); %#ok<NASGU>
	save('testdata.mat', 'testdata', '-MAT');
	
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function buttonEditTestScript_Callback(hObject, eventdata, handles)
	edit(handles.H.TestScript)
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function buttonLoadTestScript_Callback(hObject, eventdata, handles)
	[filename, pathname, findex] = uigetfile('*.m', ...
															'Select Test Script File');
	if findex
		handles.H.TestScript = fullfile(pathname, filename);
		update_ui_str(handles.textTestScript, handles.H.TestScript);
		optomsg(handles, ['test script:' handles.H.TestScript]);
		guidata(hObject, handles);
	else
		optomsg(handles, 'cancelled test script load');
	end
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% ANIMAL settings (stored in handles.H.animal struct)
%-------------------------------------------------------------------------
function editAnimal_Callback(hObject, eventdata, handles)
	% set animal #
	str = read_ui_str(hObject);
	if (length(str) > 4) || isempty(str)
		optomsg(handles, 'Animal Number must be 4 characters or fewer');
		update_ui_str(hObject, handles.H.animal.Animal)
	else
		optomsg(handles, ['Animal #: ' str]);
		handles.H.animal.Animal = str;
		guidata(hObject, handles);
	end
%-------------------------------------------------------------------------
function editUnit_Callback(hObject, eventdata, handles)
	% set Unit #
	str = read_ui_str(hObject);
	if (length(str) > 3) || isempty(str)
		optomsg(handles, 'Unit Number must be 3 characters or fewer');
		update_ui_str(hObject, handles.H.animal.Unit)
	else
		optomsg(handles, ['Unit #: ' str]);
		handles.H.animal.Unit = str;
		guidata(hObject, handles);
	end
%-------------------------------------------------------------------------
function editRec_Callback(hObject, eventdata, handles)
	% set Rec # (Recording Session #)
	str = read_ui_str(hObject);
	if (length(str) > 2) || isempty(str)
		optomsg(handles, 'Recording Session must be 2 characters or fewer');
		update_ui_str(hObject, handles.H.animal.Rec)
	else
		optomsg(handles, ['Rec #: ' str]);
		handles.H.animal.Rec = str;
		guidata(hObject, handles);
	end
%-------------------------------------------------------------------------
function editPen_Callback(hObject, eventdata, handles)
	% set Pen # (Penetration #)
	str = read_ui_str(hObject);
	if (length(str) > 2) || isempty(str)
		optomsg(handles, 'Penetration # must be 2 characters or fewer');
		update_ui_str(hObject, handles.H.animal.Pen)
	else
		optomsg(handles, ['Pen #: ' str]);
		handles.H.animal.Pen = str;
		guidata(hObject, handles);
	end
%-------------------------------------------------------------------------
function editAP_Callback(hObject, eventdata, handles)
	% set AP location (Anterior/Posterior recording location, mm)
	str = read_ui_str(hObject);
	if isempty(str)
		optomsg(handles, 'AP location cannot be empty!');
		update_ui_str(hObject, handles.H.animal.AP)
	else
		optomsg(handles, ['AP location: ' str ' mm']);
		handles.H.animal.AP = str;
		guidata(hObject, handles);
	end
%-------------------------------------------------------------------------
function editML_Callback(hObject, eventdata, handles)
	% set ML location (Medial/Lateral recording location, mm)
	str = read_ui_str(hObject);
	if isempty(str)
		optomsg(handles, 'ML location cannot be empty!');
		update_ui_str(hObject, handles.H.animal.ML)
	else
		optomsg(handles, ['ML location: ' str ' mm']);
		handles.H.animal.ML = str;
		guidata(hObject, handles);
	end
%-------------------------------------------------------------------------
function editDepth_Callback(hObject, eventdata, handles)
	% set Depth location (Recording depth, micrometers)
	str = read_ui_str(hObject);
	if isempty(str)
		optomsg(handles, 'Recording depth cannot be empty!');
		update_ui_str(hObject, handles.H.animal.Depth)
	else
		optomsg(handles, ['Depth: ' str ' um']);
		handles.H.animal.Depth = str;
		guidata(hObject, handles);
	end
%-------------------------------------------------------------------------
function editComments_Callback(hObject, eventdata, handles)
	% store comments
	handles.H.animal.comments = read_ui_str(hObject);
	guidata(hObject, handles);
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
function buttonLoadCal_Callback(hObject, eventdata, handles)
	% open a dialog box to get calibration data file name and path
% 	[filenm, pathnm] = uigetfile({'*_cal.mat'; '*.mat'}, ...
% 											'Load cal data...', ...
% 											[handles.caldatapath filesep]);
	[filenm, pathnm] = uigetfile({'*.mat'; '*.*'}, ...
											'Load cal data...', ...
											[pwd filesep]);
	
	% load the speaker calibration data if user doesn't hit cancel
	if filenm
		% try to load the calibration data
		try
			tmpcal = load_cal(fullfile(pathnm, filenm));
			optomsg(handles, ['Loaded cal from ' fullfile(pathnm, filenm)]);
		catch errMsg
			% on error, tmpcal is empty
			optomsg(handles, errMsg);
			return
		end

		% if tmpcal is a structure, load of calibration file was
		% hopefully successful, so save it in the handles info
		if isstruct(tmpcal)
			handles.H.caldata = tmpcal;
			% update UI control limits based on calibration data
			handles.H.Lim.F = [handles.H.caldata.Freqs(1) handles.H.caldata.Freqs(end)];
			
% 			% update slider parameters
% 			slider_limits(handles.F, handles.Lim.F);
% 			slider_update(handles.F, handles.Ftext);
% 			% update calibration data path and filename settings
% 			handles.caldatapath = pathnm;
% 			handles.caldatafile = filenm;
			
			update_ui_str(handles.textCalibration, filenm);
			% update settings
			guidata(hObject, handles);
		else
			errordlg(['Error loading calibration file ' filenm], ...
						'LoadCal error'); 
		end
	end
%--------------------------------------------------------------------------
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
% --- Executes on button press in buttonDebug.
%-------------------------------------------------------------------------
function buttonDebug_Callback(hObject, eventdata, handles)
	keyboard
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
%-------------------------------------------------------------------------
function editAcqDuration_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
%-------------------------------------------------------------------------
function editCircuitGain_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
%-------------------------------------------------------------------------
function editHPFreq_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
%-------------------------------------------------------------------------
function editLPFreq_CreateFcn(hObject, eventdata, handles)
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
function editAudioWavFile_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
		 set(hObject,'BackgroundColor','white');
	end
%-------------------------------------------------------------------------
function popupMonitorChannel_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
	    set(hObject,'BackgroundColor','white');
	end
%-------------------------------------------------------------------------
function editAnimal_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), ...
								get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function editUnit_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), ...
								get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function editRec_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), ...
								get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function editPen_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), ...
								get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function editAP_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), ...
								get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function editML_CreateFcn(hObject, eventdata, handles)
function editDepth_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), ...
								get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
function editComments_CreateFcn(hObject, eventdata, handles)
	if ispc && isequal(get(hObject,'BackgroundColor'), ...
								get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end
%-------------------------------------------------------------------------

 
	
		





