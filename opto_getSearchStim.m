function [stim, tstr, block] = opto_getSearchStim(H, outdev)
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Opto program
%------------------------------------------------------------------------
% 
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Input Arguments:
%		H	H struct from opto handles struct
%		outdev	output device struct
%
% Output Arguments:
%		stim		[1 X N] stimulus vector
%		tstr		informational string about stimulus
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad Shanbhag 
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 4 October, 2016 (SJS)
%------------------------------------------------------------------------
% Revisions
%	5 May 17 (SJS): added search frequencies to vary tone during search
%	17 May 17 (SJS): working on block search - implemented!
%------------------------------------------------------------------------

SearchToneFreqs = 1000 * [8 12 16 25 40 60 80];
nSearchTones = length(SearchToneFreqs);
nSearchWavs = 1;	% for now...

block = H.block;

% different options depending on Signal
switch upper(H.audio.Signal)
	case 'TONE'
		% if tone, create sinusoid
		stim = synmonosine(	H.audio.Duration, ...
									outdev.Fs, ...
									H.tone.Frequency, ...
									H.caldata.DAscale, ...
									H.caldata);
		tstr = sprintf('Tone %d kHz', 0.001*H.tone.Frequency);

	case 'NOISE'
		% if noise, synthesize white noise
		stim = synmononoise_fft(	H.audio.Duration, ...
											outdev.Fs, ...
											H.noise.Fmin, ...
											H.noise.Fmax, ...
											H.caldata.DAscale, ...
											H.caldata);
		tstr = sprintf('Noise [%d:%d] kHz', 0.001*H.noise.Fmin,  ...
																0.001*H.noise.Fmax);

	case '.WAV';
		if H.wav.isloaded
			stim = H.wav.scalef * H.wav.data;
		else
			stim = syn_null(H.audio.Duration, outdev.Fs, 0);
			warning('!!! wav not loaded !!!');
		end
		tstr = sprintf('%s', H.wav.filenm);

	case 'SEARCH'
		stimid = randi(3, 1);
		switch(stimid)
			case 1
				H.audio.Signal = 'TONE';
				freqid = randi(nSearchTones, 1);
				H.tone.Frequency = SearchToneFreqs(freqid);
				
			case 2
				H.audio.Signal = 'NOISE';
			case 3
				H.audio.Signal = '.WAV';
		end
		[stim, tstr] = opto_getSearchStim(H, outdev);
		
	case 'BLOCKSEARCH'
		% increment CurrentRep
		block.CurrentRep = block.CurrentRep + 1;
		% if over Nreps, do some checks
		if block.CurrentRep > block.Nreps		
			% are we on WAVs?
			if block.CurrentStim == 3
				% increment WAV
				block.CurrentWav = block.CurrentWav + 1;
				% check if we're on the last WAV
				if block.CurrentWav > nSearchWavs
					% if so, reset counters
					block.CurrentStim = 1;
					block.CurrentTone = 1;
					block.CurrentWav = 1;
					block.CurrentRep = 1;
				end
			% are we on Noise
			elseif block.CurrentStim == 2
				% if so, reset Rep counter
				block.CurrentRep = 1;
				% and increment Current Stim
				block.CurrentStim = block.CurrentStim + 1;
			% are we on Tones
			elseif block.CurrentStim == 1
				% increment tone
				block.CurrentTone = block.CurrentTone + 1;
				% check if we're on the last tone
				if block.CurrentTone > nSearchTones
					% if so, reset Rep counter
					block.CurrentRep = 1;
					% and increment CurrentStim
					block.CurrentStim = block.CurrentStim + 1;
				else
					%otherwise just reset rep
					block.CurrentRep = 1;
				end
			end
		end
		% set stimid
		stimid = block.CurrentStim;
		switch(stimid)
			case 1
				H.audio.Signal = 'TONE';
				H.tone.Frequency = SearchToneFreqs(block.CurrentTone);
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
block
% ramp onset/offset
stim = sin2array(stim, H.audio.Ramp, outdev.Fs);
