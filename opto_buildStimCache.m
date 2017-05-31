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
%	31 May, 2017 (SJS): added block sequence stimulation capability
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
% save stimulus?
c.saveStim = test.saveStim;

% figure out number of different audio stimulus levels
if ~isempty(strfind(test.Type, 'LEVEL'))
	nLevels = length(audio.Level);
else
	nLevels = 0;
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
c.FREQ = cell(c.nstims, 1);
c.LEVEL= zeros(c.nstims, 1);
c.opto = cell(c.nstims, 1);
for n = 1:c.nstims
	c.opto{n} = opto;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings for Type of stimulus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% *** seeems like this section is superfluous....
switch c.curvetype		
	
	% LEVEL curves can use either noise or tones or opto
	case {'LEVEL', 'LEVEL_OPTO'}
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
				
			case 'wav'
				
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
	
	case 'OPTO-DUR'
		
		
		
	case {'OPTO', 'OPTO-DELAY', 'OPTO-AMP'}
	
	otherwise
		error([mfilename ': unsupported curvetype ' c.curvetype])
end		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Randomize trial presentations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if test.Randomize == 1
	c.trialRandomSequence = randomSequence(c.nreps, c.ntrials);
elseif isfield(test, 'Block')
	if test.Block == 1
		c.trialRandomSequence = blockSequence(c.nreps, c.ntrials);
	end
else
	% play each trial in sequence for nreps times
	c.trialRandomSequence = zeros(c.nreps, c.ntrials);
	for m = 1:c.nreps
		c.trialRandomSequence (m, :) = 1:c.ntrials;
	end
end
% assign to output variable
if nargout > 1
	stimseq = c.trialRandomSequence;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run through the dependent variable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp([mfilename ' is building stimuli for ' c.curvetype ' curve...'])
switch c.curvetype
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% OPTO optical only, no variation
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'OPTO'
		% Stimulus parameter to vary (varName) and the range (stimvar)
		c.vname = upper(c.curvetype);
		c.vrange = opto.Dur;
		
		% null sound stimulus
		Sn = syn_null(audio.Duration, outdev.Fs, 0);
		% max atten setting
		atten = 120;
				
		% init sindex counter
		sindex = 0;
		% now loop through the randomized trials
		for rep = 1:c.nreps
			for trial = 1:c.ntrials
				% increment sindex counter (index into stim cache struct)
				sindex = sindex + 1;
				% Store the parameters in the stimulus cache struct
				c.stimvar{sindex} = opto.Amp;
				c.Sn{sindex} = Sn;
				c.splval{sindex} = 0;
				c.rmsval{sindex} = 0;
				c.atten{sindex} = atten;
				c.opto{sindex}.Enable = 1;
				c.opto{sindex}.Delay = opto.Delay;
				c.opto{sindex}.Dur = opto.Dur;
				c.opto{sindex}.Amp = opto.Amp;
			end	%%% End of TRIAL LOOP
		end %%% End of REPS LOOP
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% OPTO-DELAY Opto stim Delay curve
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'OPTO-DELAY'
		% Stimulus parameter to vary (varName) and the range (stimvar)
		c.vname = upper(c.curvetype);
		c.vrange = opto.Delay;
		
		% null sound stimulus
		Sn = syn_null(audio.Duration, outdev.Fs, 0);
		% max atten setting
		atten = 120;
				
		% init sindex counter
		sindex = 0;
		% now loop through the randomized trials
		for rep = 1:c.nreps
			for trial = 1:c.ntrials
				% increment sindex counter (index into stim cache struct)
				sindex = sindex + 1;
				% Get the randomized stimulus variable value from c.stimvar 
				% indices stored in c.trialRandomSequence and 
				% store the parameters in the stimulus cache struct
				c.stimvar{sindex} = ...
										c.vrange(c.trialRandomSequence(rep, trial));
				% Store the parameters in the stimulus cache struct
				c.Sn{sindex} = Sn;
				c.splval{sindex} = 0;
				c.rmsval{sindex} = 0;
				c.atten{sindex} = atten;
				c.opto{sindex}.Enable = 1;
				c.opto{sindex}.Delay = c.stimvar{sindex};
				c.opto{sindex}.Dur = opto.Dur;
				c.opto{sindex}.Amp = opto.Amp;
			end	%%% End of TRIAL LOOP
		end %%% End of REPS LOOP
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% OPTO-DUR Opto stim Duration curve
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'OPTO-DUR'
		% Stimulus parameter to vary (varName) and the range (stimvar)
		c.vname = upper(c.curvetype);
		c.vrange = opto.Dur;
		
		% null sound stimulus
		Sn = syn_null(audio.Duration, outdev.Fs, 0);
		% max atten setting
		atten = 120;
				
		% init sindex counter
		sindex = 0;
		% now loop through the randomized trials
		for rep = 1:c.nreps
			for trial = 1:c.ntrials
				% increment sindex counter (index into stim cache struct)
				sindex = sindex + 1;
				% Get the randomized stimulus variable value from c.stimvar 
				% indices stored in c.trialRandomSequence and 
				% store the parameters in the stimulus cache struct
				c.stimvar{sindex} = ...
									c.vrange(c.trialRandomSequence(rep, trial));
				% Store stimulus Parameters
				c.Sn{sindex} = Sn;
				c.splval{sindex} = 0;
				c.rmsval{sindex} = 0;
				c.atten{sindex} = atten;
				c.opto{sindex}.Enable = 1;
				c.opto{sindex}.Delay = opto.Delay;
				c.opto{sindex}.Dur = c.stimvar{sindex};
				c.opto{sindex}.Amp = opto.Amp;
			end	%%% End of TRIAL LOOP
		end %%% End of REPS LOOP
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% OPTO-AMP Amplitude curve
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'OPTO-AMP'
		% Stimulus parameter to vary (varName) and the range (stimvar)
		c.vname = upper(c.curvetype);
		c.vrange = opto.Amp;
		
		% null sound stimulus
		Sn = syn_null(audio.Duration, outdev.Fs, 0);
		% max atten setting
		atten = 120;
				
		% init sindex counter
		sindex = 0;
		% now loop through the randomized trials
		for rep = 1:c.nreps
			for trial = 1:c.ntrials
				% increment sindex counter (index into stim cache struct)
				sindex = sindex + 1;
				% Get the randomized stimulus variable value from c.stimvar 
				% indices stored in c.trialRandomSequence and 
				% store the parameters in the stimulus cache struct
				c.stimvar{sindex} = ...
									c.vrange(c.trialRandomSequence(rep, trial));
				% Store the parameters in the stimulus cache struct
				c.Sn{sindex} = Sn;
				c.splval{sindex} = 0;
				c.rmsval{sindex} = 0;
				c.atten{sindex} = atten;
				c.opto{sindex}.Enable = 1;
				c.opto{sindex}.Delay = opto.Delay;
				c.opto{sindex}.Dur = opto.Dur;
				c.opto{sindex}.Amp = c.stimvar{sindex};
			end	%%% End of TRIAL LOOP
		end %%% End of REPS LOOP
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% FREQ Curve
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'FREQ'
		% Stimulus parameter to vary (varName) and the range (stimvar)
		c.vname = upper(c.curvetype);
		c.vrange = signal.Frequency;
		
		% for FREQ curves, these parameters are fixed:
		splval = audio.Level(1);
		% init sindex counter
		sindex = 0;
		% now loop through the randomized trials
		for rep = 1:c.nreps
			for trial = 1:c.ntrials
				% increment sindex counter (index into stim cache struct)
				sindex = sindex + 1;
				% Get the randomized stimulus variable value from c.stimvar 
				% indices stored in c.trialRandomSequence
				FREQ = c.vrange(c.trialRandomSequence(rep, trial));
				% Synthesize noise or tone, frozed or unfrozed and 
				% get rms values for setting attenuator
				Sn = synmonosine(audio.Duration, outdev.Fs,...
											FREQ, caldata.DAscale, caldata);
				rmsval = rms(Sn);
				% ramp the sound on and off (important!)
				Sn = sin2array(Sn, audio.Ramp, outdev.Fs);
				% get the attenuator settings for the desired SPL
				atten = figure_mono_atten(splval, rmsval, caldata);
				% Store the parameters in the stimulus cache struct
				c.stimvar{sindex} = FREQ;
				c.Sn{sindex} = Sn;
				c.splval{sindex} = splval;
				c.rmsval{sindex} = rmsval;
				c.atten{sindex} = atten;
				c.FREQ{sindex} = FREQ;
				c.LEVEL(sindex) = splval;
				c.opto{sindex}.Enable = 0;
			end	%%% End of TRIAL LOOP
		end %%% End of REPS LOOP
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% LEVEL Curve
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
												signal.Fmin, signal.Fmax, ...
												caldata.DAscale, caldata);
				case 'tone'
					% enforce rad_vary = 0
					[c.S0, c.Scale0] = synmonosine(audio.Duration, ...
																outdev.Fs, ...
																signal.Frequency, ...
																caldata.DAscale, caldata);
			end
		end
		
		% init sindex
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
							Sn = synmononoise_fft(audio.Duration, ...
															outdev.Fs, signal.Fmin, ...
															signal.Fmax, ...
															caldata.DAscale, caldata);
						case 'tone'
							Sn = synmonosine(audio.Duration, ...
															outdev.Fs, ...
															signal.Frequency, ...
															caldata.DAscale, caldata);
					end
				else	% stimulus is frozen
					switch c.stimtype
						case 'noise'
							Sn = synmononoise_fft(audio.Duration, ...
															outdev.Fs, signal.Fmin, ...
															signal.Fmax, ...
															caldata.DAscale, caldata, ...
															c.Smag0, c.Sphase0);
						case 'tone'
							% enforce rad_vary = 0
							Sn = synmonosine(audio.Duration, ...
															outdev.Fs, ...
															signal.Frequency, ...
															caldata.DAscale, caldata);
					end
				end
				
				% ramp the sound on and off (important!)
				Sn = sin2array(Sn, audio.Ramp, outdev.Fs);
				% compute RMS value
				rmsval = rms(Sn);
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
		warning('%s: Sorry, curve type <<%s>> is not fully implemented.', ...
						mfilename, c.curvetype);
		c = [];
		return
end
