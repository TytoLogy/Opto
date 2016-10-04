function [stim, tstr] = opto_getSearchStim(H, outdev)
%------------------------------------------------------------------------
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
%------------------------------------------------------------------------
% Revisions
%------------------------------------------------------------------------

% different options depending on Signal
switch upper(H.audio.Signal)
	case 'TONE'
		% if tone, create sinusoid
		stim = synmonosine(	H.audio.Duration, ...
									outdev.Fs, ...
									H.tone.Frequency, ...
									H.caldata.DAscale, ...
									H.caldata);
		tstr = sprintf('Tone %d Hz', H.tone.Frequency);

	case 'NOISE'
		% if noise, synthesize white noise
		stim = synmononoise_fft(	H.audio.Duration, ...
											outdev.Fs, ...
											H.noise.Fmin, ...
											H.noise.Fmax, ...
											H.caldata.DAscale, ...
											H.caldata);
		tstr = sprintf('Noise [%d:%d] kHz', 0.001*H.noise.Fmin);

	case '.WAV';
		if H.wav.isloaded
			stim = H.wav.scalef * H.wav.data;
		else
			stim = syn_null(H.audio.Duration, outdev.Fs, 0);
			optomsg(handles, '!!! wav not loaded !!!');
		end
		tstr = sprintf('%s', H.wav.filenm);

	case 'SEARCH'
		stimid = randi(3, 1);
		switch(stimid)
			case 1
				H.audio.Signal = 'TONE';
			case 2
				H.audio.Signal = 'NOISE';
			case 3
				H.audio.Signal = '.WAV';
		end
		[stim, tstr] = opto_getSearchStim(H, outdev);

	case 'OFF';
		stim = syn_null(H.audio.Duration, outdev.Fs, 0);
		tstr = 'Off';

end

% ramp onset/offset
stim = sin2array(stim, H.audio.Ramp, outdev.Fs);
