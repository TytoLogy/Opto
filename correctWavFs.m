function wavout = correctWavFs(handles)
%------------------------------------------------------------------------
% wavout = correctWavFs(handles)
%------------------------------------------------------------------------
% Opto program
%------------------------------------------------------------------------
% 
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Input Arguments:
%
% Output Arguments:
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad Shanbhag 
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 4 October, 2016 (SJS)
%	pulled out from opto.m file
%------------------------------------------------------------------------
% Revisions
%------------------------------------------------------------------------

% function to match wav sample rate to output device sample rate by
% resampling wav data
	if ~handles.H.wav.isloaded
		optomsg(handles, 'cannot correct WavFs: no wav file loaded!')
		wavout = [];
		return;
	elseif isempty(handles.H.wav.info)
		optomsg(handles, 'cannot correct WavFs: empty info!')
		wavout = [];
		return;
	elseif isempty(handles.H.TDT.outdev.Fs)
		optomsg(handles, 'cannot correct WavFs: no outdev Fs info!')
		wavout = [];
		return;
	end
	% get original wav file samplerate
	fsorig = handles.H.wav.info.SampleRate;
	% get output device sample rate
	fsnew = handles.H.TDT.outdev.Fs;
	% check if resampling is necessary
	if fsorig == fsnew
		% if not, just return original data
		optomsg(handles, 'original Fs matches desired Fs');
		wavout = handles.H.wav;
		return;
	else
		wavout = handles.H.wav;
	end
	% build time base for orig data
	t_orig = (0:(length(wavout.data) - 1)) * (1/fsorig);
	% resample original data
	wavout.data = resample(wavout.data, t_orig, fsnew);
	wavout.info.SampleRate = fsnew;
	optomsg(handles, sprintf('New wav data Fs = %.4f', fsnew));
%-------------------------------------------------------------------------
