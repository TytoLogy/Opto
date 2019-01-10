Fs = 2e5;

caldata = fake_caldata('Fs', Fs, 'freqs', 1000:1000:Fs);

c.curvetype = 'FREQ+LEVEL';
signal.Frequency = 1000*[5 10 15];
signal.Type = 'tone';
test.Type = c.curvetype;
audio.Level = [20 30];
c.nreps = 5;

test.Randomize = 1;
test.Block = 1;


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

% # of trials == # of stim values (ITDs, ILDs, # freqs, etc.)
if isempty(strfind(test.Type, 'FREQ+LEVEL'))
	% for simple (non-FRA) tests, ntrials will be sum of different levels
	c.ntrials = nLevels + nOptoAmp + nFreqs;
elseif strfind(test.Type, 'FREQ+LEVEL')
	c.ntrials = nLevels * nFreqs;
else
	error('%s: setting ntrials, unknown test Type %s', ...
													mfilename, test.Type);
end


% # total stimuli will be # of reps (per stimulus) * total # of trials
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


%%



c.vrange = zeros(2, c.ntrials);


% init sindex counter
sindex = 0;
% now loop through the randomized trials
for rep = 1:c.nreps
	for trial = 1:c.ntrials
		% increment sindex counter (index into stim cache struct)
		sindex = sindex + 1;
		% Get the randomized stimulus variable value from c.stimvar 
		% indices stored in c.trialRandomSequence
		FREQ = c.vrange{1}(c.trialRandomSequence(rep, trial));
		LEVEL = c.vrange{2}(c.trialRandomSequence(rep, trial));
		% Synthesize noise or tone, frozed or unfrozed and 
		% get rms values for setting attenuator
		Sn = synmonosine(audio.Duration, outdev.Fs,...
									FREQ, caldata.DAscale, caldata);
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

