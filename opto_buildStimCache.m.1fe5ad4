function [c, stimseq] = opto_buildStimCache(test, tdt, caldata)
%--------------------------------------------------------------------------
% [c, stimseq] = opto_buildStimCache(test, stim, tdt, caldata)
%--------------------------------------------------------------------------
% opto program
%--------------------------------------------------------------------------
% 
% Generates stimulus cache 
% 
% note that no implementation for wav tests exists....
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
%	8 Jun, 2017 (SJS): fixed issue with incorrect rep, trial in block 
%								sequence mode
%	8 Jan 2017 (SJS): working on FRA
%	25 Feb 2020 (SJS): FRA cache not working properly! only using lowest
%	frequency!!!
%  19 Aug 2020 (SJS): dealing with opto-amp test
%  26 Oct 2020 (SJS): adding click stimuli
%--------------------------------------------------------------------------

%{
test.audio.signal.Type values:
	'tone'
	'noise'
   'click'
	'wav'

test.Type values:
	'FREQ'
	'LEVEL'
	'FREQ+LEVEL'
	'WAVFILE'
   'OPTO-AMP'

test.Name values:
	'FREQ_TUNING'
	'BBN'
   'CLICK'
	'FRA'
	'WAV'
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some setup and initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pull out individual elements of test struct for the sake of clarity
%
% information about signal: duration, delay, level, etc.
audio = test.audio;
% optogenetic stimulation parameters
opto = test.opto;
% signal specific settings (e.g., for tone: frequency and RadVary, for BBN,
% [Fmin Fmax]
signal = test.audio.signal;
% output device - needed for sampling rate!
outdev = tdt.outdev;

% stimcache settings
% get string for type of auditory stimulus (tone, noise, wav)
c.stimtype = lower(signal.Type);
% get string for type of test
c.curvetype = upper(test.Type);
% frozen stimulus setting
c.freezeStim = audio.Frozen;
% # of reps (reps per stim)
c.nreps = test.Reps;
% save stimulus?
c.saveStim = test.saveStim;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure out number of different audio stimulus levels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(strfind(test.Type, 'LEVEL'))
	nLevels = length(audio.Level);
else
	nLevels = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% # of frequencies for FREQ type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(strfind(test.Type, 'FREQ'))
	nFreqs = length(signal.Frequency);
elseif strcmp(signal.Type, 'tone')
	nFreqs = 1;
else
	nFreqs = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check for OPTO tag
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(strfind(test.Type, 'OPTO'))
	% if specified, get # of opto levels
	nOptoAmp = length(opto.Amp);
else
	nOptoAmp = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute total number of trials = total number of different
% stimuli/stimulus combinations to play
% # of trials == total # of stim values (ITDs, ILDs, # freqs, etc.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%if ~isempty(strfind(test.Type, 'LEVEL')) && strcmpi(signal.Type, 'tone')

% Level curve (either BBN or FREQ or CLICK)?
if strcmpi(test.Type, 'LEVEL')
	
	% alter behaviour depending on signal type (tone, noise, wav)
	if strcmpi(signal.Type, 'tone')
		% test is tone + level, so ntrials will be 
		% # of levels plus # opto amps
		c.ntrials = nLevels + nOptoAmp;
		fprintf('tone + level curve\n');

	elseif strcmpi(signal.Type, 'noise')
		% test is noise + level, so ntrials will be 
		% # of levels plus # opto amps
		c.ntrials = nLevels + nOptoAmp;
		fprintf('noise + level curve\n');

	elseif strcmpi(signal.Type, 'click')
		% test is click + level, so ntrials will be 
		% # of levels plus # opto amps
		c.ntrials = nLevels + nOptoAmp;
		fprintf('noise + level curve\n');
		
	elseif strcmpi(signal.Type, 'wav')
		% test is wav (single) + level, so ntrials will be 
		% # of levels plus # opto amps
		c.ntrials = nLevels + nOptoAmp;
		fprintf('wav + level curve\n');

	else
		error('%s: Unsupported signal type %s', mfilename, signal.Type);

	end
	fprintf('\t %d levels\n', nLevels); 
	fprintf('\t %d OptoAmp values\n', nOptoAmp);

% FREQ (freq tuning) curve
elseif strcmpi(test.Type, 'FREQ')
	if strcmpi(signal.Type, 'tone')
		% test is frequency tuning curve
		% for simple (non-FRA, freq level) tests, ntrials will be 
		% sum of different levels
		c.ntrials = nLevels + nOptoAmp + nFreqs;
		fprintf('frequency tuning curve\n');
	else
		error('%s: Unsupported signal %s for test.TYPE = FREQ', ...
											mfilename, signal.Type)
	end
	fprintf('\t %d levels\n', nLevels); 
	fprintf('\t %d OptoAmp values\n', nOptoAmp);
	fprintf('\t %d Freqs values\n', nFreqs);

% FREQ+LEVEL = FRA test
elseif strcmpi(test.Type, 'FREQ+LEVEL')
	if strcmpi(signal.Type, 'tone')
		% test is FRA (vary both frequency and level)
		c.ntrials = nLevels * nFreqs;
		fprintf('FRA (FREQ+LEVEL) test\n');
	else
		error('%s: unsupported signal %s for FRA', mfilename. signal.Type);
	end
	fprintf('\t %d levels\n', nLevels); 
	fprintf('\t %d OptoAmp values\n', nOptoAmp);
	fprintf('\t %d Freqs values\n', nFreqs);

% wavfile unsupported
elseif strcmpi(test.Type, 'WAVFILE')
	error('%s: unsupported test type %s', mfilename, test.Type);

% OPTO-AMP: vary optogenetic output level (for use with ThorLabs LED
% controller)
elseif strcmpi(test.Type, 'OPTO-AMP')
    c.ntrials = nOptoAmp;
    fprintf('OPTO-AMP test\n');

% Unknown test type
else
	error('%s: setting ntrials, unknown test Type %s', ...
													mfilename, test.Type);
end
fprintf('\t %d trials\n', c.ntrials);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% # total stimuli will be # of reps (per stimulus) * total # of trials
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c.nstims = c.nreps * c.ntrials;
% assign rep and trial numbers (trial corresponds to 
% stimulus type or parameter)
c.repnum = zeros(c.nstims, 1);
c.trialnum = zeros(c.nstims, 1);
% first check is there is a "Block" field in the test struct
if isfield(test, 'Block')
	% if so, see if it is set to 1
	if test.Block == 1
		% assign rep and trial in blocked fashion - i.e., run through
		% nreps of each trial before moving to next trial type
		sindex = 0;
		for trial = 1:c.ntrials
			for rep = 1:c.nreps
				sindex = sindex + 1;
				c.repnum(sindex) = rep;
				c.trialnum(sindex) = trial;
			end
		end		
	else
		% default mode = run through sequence of trials nreps times
		sindex = 0;
		for rep = 1:c.nreps
			for trial = 1:c.ntrials
				sindex = sindex + 1;
				c.repnum(sindex) = rep;
				c.trialnum(sindex) = trial;
			end
		end
	end
else
	% default mode = run through sequence of trials nreps times
	sindex = 0;
	for rep = 1:c.nreps
		for trial = 1:c.ntrials
			sindex = sindex + 1;
			c.repnum(sindex) = rep;
			c.trialnum(sindex) = trial;
		end
	end
end

% allocate some arrays for storage
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
	
	% LEVEL curves can use either noise or tones or click or opto
	case {'LEVEL', 'LEVEL_OPTO', 'FREQ+LEVEL'}
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
			
			case 'click'
				% do things for click
				
			case 'wav'
				% NOT YET IMPLEMENTED
				error('%s: unsupported stimulus %s', mfilename, c.stimtype);
				
			otherwise
				warning([mfilename ': unsupported stimtype ' c.stimtype ...
													' for curvetype ' c.curvetype])
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
				warning([mfilename ': unsupported stimtype ' c.stimtype ...
														' for curvetype ' c.curvetype])
				c = [];
				return
        end
  		
	case {'OPTO', 'OPTO-DELAY', 'OPTO-DUR', 'OPTO-AMP'}
		fprintf('%s: curvetype is %s\n', mfilename, c.curvetype);
		
	otherwise
		error([mfilename ': unkown curvetype ' c.curvetype])
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
	c.trialRandomSequence = sequentialSequence(c.nreps, c.ntrials);
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
											FREQ, caldata.DAscale, caldata, c.radvary);
				rmsval = rms(Sn);
				% ramp the sound on and off (important!)
				Sn = sin2array(Sn, audio.Ramp, outdev.Fs);
				% get the attenuator settings for the desired SPL
				atten = figure_mono_atten_tone(splval, rmsval, caldata);
				% Store the parameters in the stimulus cache struct
				c.stimvar{sindex} = FREQ;
				c.Sn{sindex} = Sn;
				c.splval{sindex} = splval;
				c.rmsval{sindex} = rmsval;
				c.atten{sindex} = atten;
				c.FREQ{sindex} = FREQ;
				c.LEVEL(sindex) = splval;
% 				c.opto{sindex}.Enable = 0; % not sure why...
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
																caldata.DAscale, ...
																caldata, ...
																0);
				case 'click'
					% get click
					% use audio.Duration for overall length of stimulus, 
					% signal.Delay and signal.ClickDur for click delay and
					% duration. use calibration data scaling for click amplitude
					c.S0 = synmonoclick(audio.Duration, outdev.Fs, ...
						                   signal.Delay, signal.ClickDur, ...
												 calData.DAscale);
					% next issue is how to set levels. for now, use 1
					c.Scale0 = 1;
					
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
															caldata.DAscale, ...
															caldata, ...
															signal.RadVary);

						case 'click'
							% get click
							Sn = c.S0;

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
															caldata.DAscale, ...
															caldata, 0);

						case 'click'
							% get click
							Sn = c.S0;
					
					end
				end
				
				% ramp the sound on and off if not a click (important!)
				if ~strcmpi(c.stimtype, 'click')
					Sn = sin2array(Sn, audio.Ramp, outdev.Fs);
				end
				% compute RMS value
				rmsval = rms(Sn);
				% get the attenuator settings for the desired SPL
				switch c.stimtype
					case 'noise'
						atten = figure_mono_atten_noise(LEVEL, rmsval, caldata);
					case 'tone'
						atten = figure_mono_atten_tone(LEVEL, rmsval, caldata);
					case 'click'
						% signal needs to have information about level and 
						% corresponding SPL level
						atten = figure_mono_atten_click(LEVEL, signal);
				end
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

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% FREQ+LEVEL (FRA) Curve
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	case 'FREQ+LEVEL'	
		% Stimulus parameter to vary (varName) and the range (stimvar)
		c.vname = upper(c.curvetype);
		% create list of possible values for test stimuli
		c.vrange = zeros(2, c.ntrials);
		indx = 0;
		for f = 1:nFreqs
			for l = 1:nLevels
				indx = indx + 1;
				c.vrange(1, indx) = signal.Frequency(f);
				c.vrange(2, indx) = audio.Level(l);
			end
		end

		% init sindex counter
		sindex = 0;
		% now loop through the randomized trials
		for rep = 1:c.nreps
			for trial = 1:c.ntrials
				% increment sindex counter (index into stim cache struct)
				sindex = sindex + 1;
				% Get the randomized stimulus variable value from c.stimvar 
				% indices stored in c.trialRandomSequence
				FREQ = c.vrange(1, c.trialRandomSequence(rep, trial));
				LEVEL = c.vrange(2, c.trialRandomSequence(rep, trial));
				% Synthesize noise or tone, frozed or unfrozed and 
				% get rms values for setting attenuator
				Sn = synmonosine(audio.Duration, outdev.Fs,...
											FREQ, caldata.DAscale, c.radvary, caldata);
				rmsval = rms(Sn);
				% ramp the sound on and off (important!)
				Sn = sin2array(Sn, audio.Ramp, outdev.Fs);
				% get the attenuator settings for the desired SPL
				atten = figure_mono_atten_tone(LEVEL, rmsval, caldata);
				% Store the parameters in the stimulus cache struct
				c.stimvar{sindex} = FREQ;
				c.Sn{sindex} = Sn;
				c.splval{sindex} = LEVEL;
				c.rmsval{sindex} = rmsval;
				c.atten{sindex} = atten;
				c.FREQ{sindex} = FREQ;
				c.LEVEL(sindex) = LEVEL;
% 				c.opto{sindex}.Enable = 0; % not sure why...
			end	%%% End of TRIAL LOOP
		end %%% End of REPS LOOP
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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


