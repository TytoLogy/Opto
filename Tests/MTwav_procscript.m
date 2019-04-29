%------------------------------------------------------------------------
% MTwav_procscript.m
%------------------------------------------------------------------------
% TytoLogy:Experiments:Opto:Tests
%--------------------------------------------------------------------------
% Script to develop processing of vocalization response data collected using 
% the opto program and MTwav.m + MTwav_standalone.m scripts/functions
%
% mostly pulls in bits from optoproc, but here the plotting/analysis for
% the combination of opto, wav stim and wav stim at multiple levels is
% taken into account. Eventually, this should find its way back to the
% optoproc function.
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%   sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 29 April 2019 (SJS)
%
% Revisions:
%--------------------------------------------------------------------------

%---------------------------------------------------------------------
% path and name of data file
%---------------------------------------------------------------------
datapath = '/Users/sshanbhag/Work/Data/Mouse/Opto/TestData/MT_wavtesting/20190425';
datafile = '000_20190425_0_0_0_WAV.dat';

%---------------------------------------------------------------------
% settings for processing data (passed to optoproc function)
%---------------------------------------------------------------------
% filter
HPFreq = 350;
LPFreq = 4000;
% RMS spike threshold
% Threshold = 4.5;
Threshold = 3;
% Channel Number (use 8 for single channel data)
channelNumber = 8;
% binSize for PSTH (milliseconds)
binSize = 5;

%---------------------------------------------------------------------
% Read Data (same as optoproc)
%---------------------------------------------------------------------
[D, Dinf, tracesByStim] = getFilteredOptoData( ...
											fullfile(datapath, datafile), ...
											'Filter', [HPFreq LPFreq], ...
											'Channel', channelNumber);
if isempty(D)
	warning('%s: D is empty???!!!??!!', mfilename);
	return
end
% local copy of sample rate
Fs = Dinf.indev.Fs;

%---------------------------------------------------------------------
% get info from filename - this makes some assumptions about file
% name structure!
% <animal id #>_<date>_<penetration #>_<unit #>_<other info>.dat
%---------------------------------------------------------------------
[fname, animal, datecode, penetration, unit, other] = opto_name_deconstruct(datafile);

%---------------------------------------------------------------------
% determine global RMS and max - used for thresholding
%---------------------------------------------------------------------
% first, get  # of stimuli (called ntrials by opto) as well as # of reps
nstim = Dinf.test.nCombinations;
nreps = Dinf.test.Reps;

% allocate matrices
netrmsvals = zeros(nstim, nreps);
maxvals = zeros(nstim, nreps);
% find rms, max vals for each stim
for s = 1:nstim
	netrmsvals(s, :) = rms(tracesByStim{s});
	maxvals(s, :) = max(abs(tracesByStim{s}));
end
% compute overall mean rms for threshold
fprintf('Calculating mean and max RMS for data...\n');
mean_rms = mean(reshape(netrmsvals, numel(netrmsvals), 1));
fprintf('\tMean rms: %.4f\n', mean_rms);
% find global max value (will be used for plotting)
global_max = max(max(maxvals));
fprintf('\tGlobal max abs value: %.4f\n', global_max);

%---------------------------------------------------------------------
% Some test-specific things... (removed unneeded types from original 
% code in optoproc
%---------------------------------------------------------------------
switch upper(Dinf.test.Type)
	case 'WAVFILE'
		% get list of stimuli (wav file names)
		varlist = Dinf.test.wavlist;
		nvars = length(varlist);
		titleString = cell(nvars, 1);
		for v = 1:nvars
			if v == 1 
				titleString{v} = {fname, sprintf('wav name: %s', varlist{v})};
			else
				titleString{v} = sprintf('wav name: %s', varlist{v});
			end
		end
	otherwise
		error('%s: unsupported test type %s', mfilename, Dinf.test.Type);
end

%---------------------------------------------------------------------
%% find spikes!
%---------------------------------------------------------------------
% local copy of sample rate
Fs = Dinf.indev.Fs;

% different approaches to storage depending on test type
switch upper(Dinf.test.Type)
	case 'FREQ+LEVEL'
		% for FRA data, nvars has values [nfreqs nlevels];
		spiketimes = cell(nvars(2), nvars(1));
		for v1 = 1:nvars(1)
			for v2 = 1:nvars(2)
				% use rms threshold to find spikes
				spiketimes{v2, v1} = ...
						spikeschmitt2(tracesByStim{v2, v1}', Threshold*mean_rms, ...
																			1, Fs, 'ms');
			end
		end
	otherwise
		% if test is not FREQ+LEVEL (FRA), nvars will be a single number
		spiketimes = cell(nvars, 1);
		for v = 1:nvars
			% use rms threshold to find spikes
			spiketimes{v} = spikeschmitt2(tracesByStim{v}', Threshold*mean_rms, ...
																				1, Fs, 'ms');
		end
end
