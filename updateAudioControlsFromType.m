function handles = updateAudioControlsFromType(hObject, ...
																	handles, stimString)
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Opto program
%------------------------------------------------------------------------
% updates GUI elements relevant to stimuli
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Input Arguments:
%	hObject
%	handles
% 	stimString		'NOISE', 'TONE', 'WAV', 'SEARCH', 'OFF'
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
% Created: ? August, 2016 (SJS)
%------------------------------------------------------------------------
% Revisions
%	28 Sept 2016 (SJS):
% 		- added header comments/docs
% 		- mods for wav file
%------------------------------------------------------------------------
%------------------------------------------------------------------------

% convert stimString to uppercase
stimString = upper(stimString);

% different actions for each type
switch stimString
	case 'NOISE'
		% enable, make visible Fmax stuff, update Fmax val
		enable_ui(handles.textAudioDelay);
		enable_ui(handles.editAudioDelay);
		enable_ui(handles.textAudioDur);
		enable_ui(handles.editAudioDur);
		enable_ui(handles.textAudioLevel);
		enable_ui(handles.editAudioLevel);
		enable_ui(handles.textAudioRamp);
		enable_ui(handles.editAudioRamp);
		update_ui_str(handles.textAudioFmin, 'Fmin (Hz)');
		enable_ui(handles.textAudioFmin);
		enable_ui(handles.editAudioFmin);
		enable_ui(handles.textAudioFmax);
		enable_ui(handles.editAudioFmax);
		disable_ui(handles.buttonAudioWavFile);
		disable_ui(handles.textAudioWavFile);

	case 'TONE'
		% disable Fmax ctrls, change Fmin name to Freq, update val
		enable_ui(handles.textAudioDelay);
		enable_ui(handles.editAudioDelay);
		enable_ui(handles.textAudioDur);
		enable_ui(handles.editAudioDur);
		enable_ui(handles.textAudioLevel);
		enable_ui(handles.editAudioLevel);
		enable_ui(handles.textAudioRamp);
		enable_ui(handles.editAudioRamp);
		update_ui_str(handles.textAudioFmin, 'Freq. (Hz)');
		enable_ui(handles.textAudioFmin);
		enable_ui(handles.editAudioFmin);
		disable_ui(handles.textAudioFmax);
		disable_ui(handles.editAudioFmax);
		disable_ui(handles.buttonAudioWavFile);
		disable_ui(handles.textAudioWavFile);

	case '.WAV'
		% disable Dur, Ramp;, Fmin, Fmax ctrls, update val
		enable_ui(handles.textAudioDelay);
		enable_ui(handles.editAudioDelay);
		disable_ui(handles.textAudioDur);
		disable_ui(handles.editAudioDur);
		enable_ui(handles.textAudioLevel);
		enable_ui(handles.editAudioLevel);
		disable_ui(handles.textAudioRamp);
		disable_ui(handles.editAudioRamp);
		disable_ui(handles.textAudioFmin);
		disable_ui(handles.editAudioFmin);
		disable_ui(handles.textAudioFmax);
		disable_ui(handles.editAudioFmax);
		enable_ui(handles.buttonAudioWavFile);
		enable_ui(handles.textAudioWavFile);

	case 'SEARCH'
		% enable Fmax, Fmin, Dur, Ramp
		enable_ui(handles.textAudioDelay);
		enable_ui(handles.editAudioDelay);
		enable_ui(handles.textAudioDur);
		enable_ui(handles.editAudioDur);
		enable_ui(handles.textAudioLevel);
		enable_ui(handles.editAudioLevel);
		enable_ui(handles.textAudioRamp);
		enable_ui(handles.editAudioRamp);
		enable_ui(handles.textAudioFmin);
		enable_ui(handles.editAudioFmin);
		enable_ui(handles.textAudioFmax);
		enable_ui(handles.editAudioFmax);
		enable_ui(handles.buttonAudioWavFile);
		enable_ui(handles.textAudioWavFile);
			
	case 'OFF'
		disable_ui(handles.textAudioDelay);
		disable_ui(handles.editAudioDelay);
		disable_ui(handles.textAudioDur);
		disable_ui(handles.editAudioDur);
		disable_ui(handles.textAudioLevel);
		disable_ui(handles.editAudioLevel);
		disable_ui(handles.textAudioRamp);
		disable_ui(handles.editAudioRamp);
		disable_ui(handles.textAudioFmin);
		disable_ui(handles.editAudioFmin);
		disable_ui(handles.textAudioFmax);
		disable_ui(handles.editAudioFmax);
		disable_ui(handles.buttonAudioWavFile);
		disable_ui(handles.textAudioWavFile);

end

% store changes, done!
guidata(hObject, handles);
