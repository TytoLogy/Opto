%------------------------------------------------------------------------
% [data, datainfo] = viewOptoData(varargin)
%------------------------------------------------------------------------
% % TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% Reads binary data file created by the opto program, plots traces
%
% If a datafile name is provided in varargin (e.g.,
% viewOptoData('c:\mydir\mynicedata.dat'), the program will attempt to 
% read from that file.  
% 
% Otherwise it will open a dialog window for the user
% to select the data (.dat) file.
% 
%------------------------------------------------------------------------
% Output Arguments:
% 
% data			contains the read data in a cell structure array.
% datainfo		has the file header information.
% 
%------------------------------------------------------------------------
% See Also:
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 10 June, 2016 (SJS) 
%			- adapted from readHPData.m
% 
% Revisions:
%------------------------------------------------------------------------
% TO DO:
%	*Documentation!
%--------------------------------------------------------------------------

%% settings for processing data
HPFreq = 500;
LPFreq = 6000;

%% Read Data

% set paths
if ispc
% 	datapath = 'E:\Data\SJS\1058';
% 	datafile = '1058_20160623_0_02_1500_FREQ.dat';
	datapath = 'E:\Data\SJS\1012\20160727';
	datafile = '1012_20160727_5_3_1_OPTO.dat';
else 
	datapath = '/Users/sshanbhag/Work/Data/Mouse/Opto/1012/20160727';
% 	datafile = '1012_20160727_5_3_1_OPTO.dat';
	datafile = '1012_20160727_4_3_1_LEVEL.dat';	
end

% read in data
[D, Dinf] = readOptoData(fullfile(datapath, datafile));

%% define filter for data
% sampling rate
Fs = Dinf.indev.Fs;
% build bandpass filter, store coefficients in filtB, filtA
fband = [HPFreq LPFreq] ./ (0.5 * Fs);
[filtB, filtA] = butter(5, fband);

%% Get test info
% convert ascii characters from binary file 
Dinf.test.Type = char(Dinf.test.Type);
fprintf('Test type: %s\n', Dinf.test.Type);

% Some test-specific things...

% for FREQ test, find indices of stimuli with same frequency
switch upper(Dinf.test.Type)
	case 'FREQ'
		% list of frequencies, and # of freqs tested
		freqlist = cell2mat(Dinf.test.stimcache.FREQ);
		nfreqs = length(Dinf.test.stimcache.vrange);
		% locate where trials for each frequency are located in the 
		% stimulus cache list - this will be used to pull out trials of
		% same frequency
		stimindex = cell(nfreqs, 1);
		for f = 1:nfreqs
			stimindex{f} = find(Dinf.test.stimcache.vrange(f) == freqlist);
		end
		
% for LEVEL test, find indices of stimuli with same level (dB SPL)
	case 'LEVEL'
		% list of legvels, and # of levels tested
		levellist = Dinf.test.stimcache.LEVEL;
		nlevels = length(Dinf.test.stimcache.vrange);
		% locate where trials for each frequency are located in the 
		% stimulus cache list - this will be used to pull out trials of
		% same frequency
		stimindex = cell(nlevels, 1);
		for l = 1:nlevels
			stimindex{l} = find(Dinf.test.stimcache.vrange(l) == levellist);
		end


% for OPTO test...
	case 'OPTO'
	
	otherwise
		error('%s: unsupported test type %s', mfilename, Dinf.test.Type);
end


%% Pull out trials, apply filter, store in matrix
if isfield(Dinf.channels, 'nRecordChannels')
	nchan = Dinf.channels.nRecordChannels;
	channelList = Dinf.channels.RecordChannelList;
else
	nchan = Dinf.channels.nInputChannels;
	channelList = Dinf.channels.InputChannels;
end


%% Plot data for one channel
channelNumber = 10;

channelIndex = find(channelList == channelNumber);
if isempty(channelIndex)
	error('Channel not recorded')
end

if strcmpi(Dinf.test.Type, 'FREQ')
	% time vector for plotting
	t = (1000/Fs)*((1:length(D{1}.datatrace(:, 1))) - 1);
	for f = 1:nfreqs
		dlist = stimindex{f};
		ntrials = length(dlist);
		tmpM = zeros(length(D{1}.datatrace(:, 1)), ntrials);
		for n = 1:ntrials
			tmpM(:, n) = filtfilt(filtB, filtA, ...
											D{dlist(n)}.datatrace(:, channelIndex));
		end
		stackplot(t, tmpM, 'colormode', 'black');
		title(sprintf('Channel %d, Freq %d', channelNumber, ...
									Dinf.test.stimcache.vrange(f)));
	end
end


if strcmpi(Dinf.test.Type, 'LEVEL')
	% time vector for plotting
	t = (1000/Fs)*((1:length(D{1}.datatrace(:, 1))) - 1);
% 	for l = 1:nlevels
	for l = nlevels
		dlist = stimindex{l};
		ntrials = length(dlist);
		tmpM = zeros(length(D{1}.datatrace(:, 1)), ntrials);
		for n = 1:ntrials
			tmpM(:, n) = filtfilt(filtB, filtA, ...
											D{dlist(n)}.datatrace(:, channelIndex));
		end
		stackplot(t, tmpM, 'colormode', 'black');
		title(sprintf('Channel %d, Level %d', channelNumber, ...
									Dinf.test.stimcache.vrange(l)));
	end
end

if strcmpi(Dinf.test.Type, 'OPTO')
	% time vector for plotting
	t = (1000/Fs)*((1:length(D{1}.datatrace(:, 1))) - 1);
	ntrials = Dinf.test.stimcache.nstims;
	tmpM = zeros(length(D{1}.datatrace(:, 1)), ntrials);
	for n = 1:ntrials
			tmpM(:, n) = filtfilt(filtB, filtA, D{n}.datatrace(:, channelIndex));
	end
	stackplot(t, tmpM, 'colormode', 'black');
	title({	datafile, 'Opto Stim', ...
				sprintf('Channel %d', channelNumber)}, ...
				'Interpreter', 'none');
	xlabel('ms')
	ylabel('Trial')
end



%% Plot data for all channels
for c = 1:nchan
	channelNumber = channelList(c);

	if strcmpi(Dinf.test.Type, 'FREQ')
		% time vector for plotting
		t = (1000/Fs)*((1:length(D{1}.datatrace(:, 1))) - 1);
		for f = 1:nfreqs
			dlist = stimindex{f};
			ntrials = length(dlist);
			tmpM = zeros(length(D{1}.datatrace(:, 1)), ntrials);
			for n = 1:ntrials
				tmpM(:, n) = filtfilt(filtB, filtA, ...
												D{dlist(n)}.datatrace(:, c));
			end
			stackplot(t, tmpM);
			title(sprintf('Channel %d, Freq %d', channelNumber, ...
										Dinf.test.stimcache.vrange(f)));
		end
	end

	if strcmpi(Dinf.test.Type, 'OPTO')
		% time vector for plotting
		t = (1000/Fs)*((1:length(D{1}.datatrace(:, 1))) - 1);
		ntrials = Dinf.test.stimcache.nstims;
		tmpM = zeros(length(D{1}.datatrace(:, 1)), ntrials);
		for n = 1:ntrials
				tmpM(:, n) = filtfilt(filtB, filtA, D{n}.datatrace(:, c));
		end
		stackplot(t, tmpM);
		title({	datafile, 'Opto Stim', ...
					sprintf('Channel %d', channelNumber)}, ...
					'Interpreter', 'none');
		xlabel('ms')
		ylabel('Trial')
	end
end

%%
% filter, plot data
% tmpD = zeros(size(D{1}.datatrace));
% t = (1/Fs)*((1:length(tmpD(:, 1))) - 1);
% 
% for c = 1:nchan
% 	tmpD(:, c) = filtfilt(filtB, filtA, D{4}.datatrace(:, c));
% end
% plot(1000*t, tmpD)
% 
