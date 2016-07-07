%------------------------------------------------------------------------
% [data, datainfo] = readOptoData(varargin)
%------------------------------------------------------------------------
% % TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% Reads binary data file created by the opto program
%
% If a datafile name is provided in varargin (e.g.,
% readOptoData('c:\mydir\mynicedata.dat'), the program will attempt to 
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
HPFreq = 200;
LPFreq = 8000;

%% Read Data

% set paths
if ispc
	datapath = 'E:\Data\1058';
	datafile = '1058_20160623_0_02_1500_FREQ.dat';
else 
	datapath = '/Users/sshanbhag/Work/Data/Mouse/Opto/1058';
	datafile = '1058_20160623_0_02_1500_FREQ.dat';
end

% read in data
[D, Dinf] = readOptoData(fullfile(datapath, datafile));

%% Get test info
Dinf.test.Type = char(Dinf.test.Type);

fprintf('Test type: %s\n', Dinf.test.Type);

% for FREQ test, find indices of stimuli with same frequency
if strcmpi(Dinf.test.Type, 'FREQ')
	freqlist = cell2mat(Dinf.test.stimcache.FREQ);
	nfreqs = length(Dinf.test.stimcache.vrange);
	stimindex = cell(nfreqs, 1);
	for f = 1:nfreqs
		stimindex{f} = find(Dinf.test.stimcache.vrange(f) == freqlist);
	end
else
	error('%s: unsupported test type %s', mfilename, Dinf.test.Type);
end

%% define filter for data
Fs = Dinf.indev.Fs;

HPFreq = 225;
LPFreq = 5000;

% build filter
fband = [HPFreq LPFreq] ./ (0.5 * Fs);
[filtB, filtA] = butter(5, fband);

% Pull out trials, apply filter, store in matrix
channel = 4;
nchan = length(Dinf.channels.InputChannels);

% time vector for plotting
t = (1000/Fs)*((1:length(D{1}.datatrace(:, 1))) - 1);

for f = 1:nfreqs
	dlist = stimindex{f};
	ntrials = length(dlist);
	tmpM = zeros(length(D{1}.datatrace(:, 1)), ntrials);
	for n = 1:ntrials
		tmpM(:, n) = filtfilt(filtB, filtA, D{dlist(n)}.datatrace(:, channel));
	end
	stackplot(t, tmpM);
	title(sprintf('Channel %d, Freq %d', channel, Dinf.test.stimcache.vrange(f)));
end

%%
% filter, plot data
tmpD = zeros(size(D{1}.datatrace));
t = (1/Fs)*((1:length(tmpD(:, 1))) - 1);

for c = 1:nchan
	tmpD(:, c) = filtfilt(filtB, filtA, D{4}.datatrace(:, c));
end
plot(1000*t, tmpD)

