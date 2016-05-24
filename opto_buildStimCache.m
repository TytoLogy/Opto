function [c, stimseq] = opto_buildStimCache(test, tdt, caldata)
%--------------------------------------------------------------------------
% [c, stimseq] = opto_buildStimCache(test, stim, tdt, caldata)
%--------------------------------------------------------------------------
% opto program
%--------------------------------------------------------------------------
% 
% Generates stimulus cache 
% 
%--------------------------------------------------------------------------
% Input Arguments:
% 	test				test specification structure
%  tdt				tdt structure
% 	caldata			calibration data
%
% Output Arguments:
%	c					stimulus cache
%	stimseq			stimulus sequence in block format
%--------------------------------------------------------------------------
% See Also: writeStimData, fopen, fwrite, BinaryFileToolbox, opto
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Revision History
%	24 May, 2016 (SJS): file created from HPSearch program's
%								HPCurve_buildStimCache function and adapted
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some setup and initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull out individual elements of test struct for the sake of clarity
audio = test.audio;
opto = test.opto;
signal = test.audio.signal;
outdev = tdt.outdev;

% get string for type of auditory stimulus
c.stimtype = lower(signal.Type);
% get string for type of test
c.curvetype = upper(test.Type);
% frozen stimulus setting
c.freezeStim = audio.Frozen;
% # of reps (reps per stim)
c.nreps = test.Reps;

% figure out number of different audio stimulus levels
if ~isempty(strfind(test.Type, 'LEVEL'))
	nLevels = length(audio.Level);
else
	nLevels = 1;
end
% # of frequencies for FREQ type
if ~isempty(strfind(test.Type, 'FREQ'))
	nFreqs = length(signal.Frequency);
elseif strcmp(signal.Type, 'tone')
	nFreqs = 1;
else
	nFreqs = 0;
end
% check for OPTO tag
if ~isempty(strfind(test.Type, 'OPTO'))
	nOptoAmp = length(opto.Amp);
else
	nOptoAmp = 0;
end
% # of trials == # of stim values (ITDs, ILDs, etc.)
c.ntrials = nLevels + nOptoAmp + nFreqs;

% allocate some arrays for storage
c.nstims = c.nreps * c.ntrials;
c.repnum = zeros(c.nstims, 1);
c.trialnum = zeros(c.nstims, 1);
sindex = 0;
for rep = 1:c.nreps
	for trial = 1:c.ntrials
		sindex = sindex + 1;
		c.repnum(sindex) = rep;
		c.trialnum(sindex) = trial;
	end
end

c.Sn = cell(c.nstims, 1);
c.splval = cell(c.nstims, 1);
c.rmsval = cell(c.nstims, 1);
c.atten = cell(c.nstims, 1);

c.ITD = zeros(c.nstims, 1);
c.ILD = zeros(c.nstims, 1);
c.BC = zeros(c.nstims, 1);
c.FREQ = cell(c.nstims, 1);
c.LEVEL= zeros(c.nstims, 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings for Type of stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch c.curvetype
	
	% LEVEL curves can use either noise or tones
	case {'LEVEL'}
		switch c.stimtype
			case 'noise'
				% low freq for bandwidth of noise (Hz)
				FREQ(1) = signal.Fmin;
				% high freq. for BB noise (Hz)
				FREQ(2) = signal.Fmax;
			case 'tone'
				FREQ = signal.Frequency;	% freq. for tone (Hz)'
				% vary phase randomly from stim to stim 1 = yes, 0 = no
				% (consistent phase each time)
				c.radvary = signal.RadVary;	
			otherwise
				warning([mfilename ': unsupported stimtype ' c.stimtype ' for curvetype ' c.curvetype])
				c = [];
				return
		end
		
	% freq tuning is tones-only
	case {'FREQ'}
		switch c.stimtype
			case 'tone'
				% freq. for tone (Hz) (will be a vector)
				FREQ = signal.Frequency;
				% vary phase randomly from stim to stim 1 = yes, 0 = no
				% (consistent phase each time)
				c.radvary = signal.RadVary;	
			otherwise
				warning([mfilename ': unsupported stimtype ' c.stimtype ' for curvetype ' c.curvetype])
				c = [];
				return
		end
	
	otherwise
		warning([mfilename ': unsupported curvetype ' c.curvetype])
		c = [];
		return
end		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Randomize trial presentations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stimseq = randomSequence(c.nreps, c.ntrials);
c.trialRandomSequence = stimseq;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run through the dependent variable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp([mfilename ' is building stimuli for ' c.curvetype ' curve...'])
switch c.curvetype
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% FREQ Curve
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'FREQ'
		% Stimulus parameter to vary (varName) and the range (stimvar)
		c.vname = upper(c.curvetype);
		c.vrange = signal.Frequency;
		
		% for FREQ curves, these parameters are fixed:
		splval = audio.Level(1);

		sindex = 0;
		% now loop through the randomized trials
		for rep = 1:c.nreps
			for trial = 1:c.ntrials
				sindex = sindex + 1;

				% Get the randomized stimulus variable value from c.stimvar 
				% indices stored in c.trialRandomSequence
				FREQ = c.vrange(c.trialRandomSequence(rep, trial));

				% Synthesize noise or tone, frozed or unfrozed and 
				% get rms values for setting attenuator
				if ~test.freezeStim % stimulus is unfrozen
					[Sn, rmsval] = synmonosine(audio.Duration, outdev.Fs, FREQ, c.radvary, caldata);
				else	% stimulus is frozen
					% enforce rad_vary = 0, this fixes the starting phase at 0
					[Sn, rmsval] = synmonosine(audio.Duration, outdev.Fs, FREQ, 0, caldata);
				end

				% ramp the sound on and off (important!)
				Sn = sin2array(Sn, audio.Ramp, outdev.Fs);

				% get the attenuator settings for the desired SPL
				atten = figure_atten(splval, rmsval, caldata);

				% Store the parameters in the stimulus cache struct
				c.stimvar{sindex} = FREQ;
				c.Sn{sindex} = Sn;
				c.splval{sindex} = spl_val;
				c.rmsval{sindex} = rmsval;
				c.atten{sindex} = atten;
				c.FREQ{sindex} = FREQ;
				c.LEVEL(sindex) = ABI;
				
			end	%%% End of TRIAL LOOP
		end %%% End of REPS LOOP
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% LEVEL Curve
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'LEVEL'
		% Stimulus parameter to vary (varName) and the range (stimvar)
		c.vname = upper(c.curvetype);
		c.vrange = audio.Level;

		% If noise is frozen, generate zero ITD spectrum or tone
		if audio.Frozen
			switch c.stimtype
				case 'noise'
					% get ITD = 0 Smag and Sphase
					[c.S0, c.Smag0, c.Sphase0] = ...
						synmononoise_fft(audio.Duration, outdev.Fs, ...
												signal.Fmin, signal.Fmax, 1, caldata);
				case 'tone'
					% enforce rad_vary = 0
					[c.S0, c.Scale0] = synmonotone(audio.Duration, ...
																outdev.Fs, ...
																signal.Frequency, ...
																1, 0, caldata);
			end
		end

		sindex = 0;
		% now loop through the randomized trials
		for rep = 1:c.nreps
			for trial = 1:c.ntrials
				sindex = sindex + 1;

				% Get the randomized stimulus variable value from c.stimvar 
				% indices stored in c.trialRandomSequence
				LEVEL = c.vrange(c.trialRandomSequence(rep, trial));

				% Synthesize noise or tone, frozed or unfrozed and 
				% get rms values for setting attenuator
				if ~audio.Frozen % stimulus is unfrozen
					switch c.stimtype
						case 'noise'
							[Sn, rmsval] = synmononoise_fft(audio.Duration, ...
															outdev.Fs, signal.Fmin, ...
															signal.Fmax, 1, caldata);
						case 'tone'
							[Sn, rmsval] = synmonotone(audio.Duration, ...
															outdev.Fs, ...
															signal.Frequency, 1, ...
															c.radvary, caldata);
					end
				else	% stimulus is frozen
					switch c.stimtype
						case 'noise'
							[Sn, rmsval] = synmononoise_fft(audio.Duration, ...
															outdev.Fs, signal.Fmin, ...
															signal.Fmax, 1, caldata, ...
															c.Smag0, c.Sphase0);
						case 'tone'
							% enforce rad_vary = 0
							[Sn, rmsval] = synmonotone(audio.Duration, ...
															outdev.Fs, ...
															signal.Frequency, 1, ...
															0, caldata);
					end
				end

				% ramp the sound on and off (important!)
				Sn = sin2array(Sn, audio.Ramp, outdev.Fs);

				% get the attenuator settings for the desired SPL
				atten = figure_mono_atten(LEVEL, rmsval, caldata);

				% Store the parameters in the stimulus cache struct
				c.stimvar{sindex} = LEVEL;
				c.Sn{sindex} = Sn;
				c.splval{sindex} = LEVEL;
				c.rmsval{sindex} = rmsval;
				c.atten{sindex} = atten;
				c.FREQ{sindex} = FREQ;
				c.LEVEL(sindex) = LEVEL;
			end	%%% End of TRIAL LOOP
		end %%% End of REPS LOOP
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Unsupported
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	otherwise
		warning([mfilename ': that type of curve is not fully implemented... sorry.']);
		c = [];
		return
end
