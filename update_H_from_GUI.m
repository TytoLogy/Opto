function H = update_H_from_GUI(handles)
H = handles.H;

% get stimulus type and set H.audio.Signal to appropriate string
stimTypes = read_ui_str(handles.popupAudioSignal);
H.audio.Signal = lower(stimTypes{read_ui_val(handles.popupAudioSignal)});
% stimulus delay
H.audio.Delay = read_ui_str(handles.editAudioDelay, 'n');
% stimulus Duration
H.audio.Duration = read_ui_str(handles.editAudioDur, 'n');
% stimulus level (dB SPL)
H.audio.Level = read_ui_str(handles.editAudioLevel, 'n');
% ramp on.off
H.audio.Ramp = read_ui_str(handles.editAudioRamp, 'n');
% frequency (for tone), freq range (for noise)
switch upper(H.audio.Signal)
	case 'NOISE'
		H.noise.Fmin = read_ui_str(handles.editAudioFmin, 'n');
		H.noise.Fmax = read_ui_str(handles.editAudioFmax, 'n');
	case 'TONE'
		H.tone.Frequency = read_ui_str(handles.editAudioFmin, 'n');
end

% opto stimulus settings
% opto on/off
H.opto.Enable = read_ui_val(handles.checkOptoOnOff);
% opto delay
H.opto.Delay = read_ui_str(handles.editOptoDelay, 'n');
% opto duration
H.opto.Dur = read_ui_str(handles.editOptoDur, 'n');
% opto amplitude
H.opto.Amp = read_ui_str(handles.editOptoAmp, 'n');

% ISI
H.audio.ISI = read_ui_str(handles.editISI, 'n');



