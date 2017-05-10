%------------------------------------------------------------------------
% viewdat
%------------------------------------------------------------------------
% analyze/display data for channel 10, mouse 1012
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 3 August, 2016 (SJS) 
%--------------------------------------------------------------------------

%% add path to opto
addpath('/Users/sshanbhag/Work/Code/Matlab/dev/TytoLogy/Experiments/Opto');

clear all 
close all

%% settings for processing data
HPFreq = 500;
LPFreq = 4000;
channelNumber = 10;
NtracesToPlot = 5;

%% set paths
datapath = '/Users/sshanbhag/Work/Data/Mouse/Opto/1012/20160727';
optofile = '1012_20160727_4_3_1_OPTO.dat';
levelfile = '1012_20160727_4_3_1_LEVEL.dat';	

%% optical stim

% read in data
datafile = optofile;
[D, Dinf] = readOptoData(fullfile(datapath, datafile));

% define filter for data
% sampling rate
Fs = Dinf.indev.Fs;
% build bandpass filter, store coefficients in filtB, filtA
fband = [HPFreq LPFreq] ./ (0.5 * Fs);
[filtB, filtA] = butter(5, fband);

% Get test info
% convert ascii characters from binary file 
Dinf.test.Type = char(Dinf.test.Type);
fprintf('Test type: %s\n', Dinf.test.Type);

	
% for LEVEL test, find indices of stimuli with same level (dB SPL)
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

% Pull out trials, apply filter, store in matrix
if isfield(Dinf.channels, 'nRecordChannels')
	nchan = Dinf.channels.nRecordChannels;
	channelList = Dinf.channels.RecordChannelList;
else
	nchan = Dinf.channels.nInputChannels;
	channelList = Dinf.channels.InputChannels;
end

% Plot data 
channelIndex = find(channelList == channelNumber);
if isempty(channelIndex)
	error('Channel not recorded')
end

% time vector for plotting
t = (1000/Fs)*((1:length(D{1}.datatrace(:, 1))) - 1);
% ntrials = Dinf.test.stimcache.nstims;
ntrials = NtracesToPlot;
tmpM = zeros(length(D{1}.datatrace(:, 1)), ntrials);
for n = 1:ntrials
		tmpM(:, n) = filtfilt(filtB, filtA, ...
											D{n}.datatrace(:, channelIndex));
end
stackplot(t, tmpM, 'colormode', 'black', 'yabsshift', 0.3);
title({	datafile, 'Opto Stim', ...
			sprintf('Channel %d', channelNumber)}, ...
			'Interpreter', 'none');
xlabel('ms')
ylabel('Trial')
% plot stim onset,offset lines
yminmax = ylim;
ton = Dinf.opto.Delay;
toff = ton + Dinf.opto.Dur;
line(ton*[1 1], yminmax, 'Color', 'g');
line(toff*[1 1], yminmax, 'Color', 'r');

%% BBN stim
% read in data
datafile = levelfile;
[D, Dinf] = readOptoData(fullfile(datapath, datafile));

% define filter for data
% sampling rate
Fs = Dinf.indev.Fs;
% build bandpass filter, store coefficients in filtB, filtA
fband = [HPFreq LPFreq] ./ (0.5 * Fs);
% fband = [1500 3000] ./ (0.5 * Fs);
[filtB, filtA] = butter(5, fband);

% Get test info
% convert ascii characters from binary file 
Dinf.test.Type = char(Dinf.test.Type);
fprintf('Test type: %s\n', Dinf.test.Type);

% for LEVEL test, find indices of stimuli with same level (dB SPL)
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

% Pull out trials, apply filter, store in matrix
if isfield(Dinf.channels, 'nRecordChannels')
	nchan = Dinf.channels.nRecordChannels;
	channelList = Dinf.channels.RecordChannelList;
else
	nchan = Dinf.channels.nInputChannels;
	channelList = Dinf.channels.InputChannels;
end

% Plot data 
channelIndex = find(channelList == channelNumber);
if isempty(channelIndex)
	error('Channel not recorded')
end

% time vector for plotting
t = (1000/Fs)*((1:length(D{1}.datatrace(:, 1))) - 1);
% 	for l = 1:nlevels
for l = 6
	dlist = stimindex{l};
% 	ntrials = length(dlist);
	ntrials = NtracesToPlot;
	tmpM = zeros(length(D{1}.datatrace(:, 1)), ntrials);
	for n = 1:ntrials
		tmpM(:, n) = filtfilt(filtB, filtA, ...
										D{dlist(n)}.datatrace(:, channelIndex));
	end
	stackplot(t, tmpM, 'colormode', 'black', 'yabsshift', 0.6);

	title({	datafile, 'BBN Stim', ...
				sprintf('Channel %d, Level %d', channelNumber, ...
								Dinf.test.stimcache.vrange(l))}, ...
			'Interpreter', 'none');
	xlabel('ms')
	ylabel('Trial')
	drawnow
	yminmax = ylim;
	ton = Dinf.audio.Delay;
	toff = ton + Dinf.audio.Duration;
	line(ton*[1 1], yminmax, 'Color', 'g');
	line(toff*[1 1], yminmax, 'Color', 'r');
end


%% test filtering
%{
% build bandpass filter, store coefficients in filtB, filtA
fband = [HPFreq LPFreq] ./ (0.5 * Fs);
% fband = [1500 3000] ./ (0.5 * Fs);
[filtB, filtA] = butter(5, fband);

% build bandstop1 filter, store coefficients in filtB, filtA
f1 = designfilt('bandstopiir', 'FilterOrder',10, ...
         'HalfPowerFrequency1',400,'HalfPowerFrequency2',440, ...
         'SampleRate',Fs);
f2 = designfilt('bandstopiir', 'FilterOrder',10, ...
         'HalfPowerFrequency1',650,'HalfPowerFrequency2',670, ...
         'SampleRate',Fs);
f3 = designfilt('bandstopiir', 'FilterOrder',20, ...
         'HalfPowerFrequency1',1370,'HalfPowerFrequency2',1390, ...
         'SampleRate',Fs);

% time vector for plotting
t = (1000/Fs)*((1:length(D{1}.datatrace(:, 1))) - 1);
% 	for l = 1:nlevels
for l = nlevels
	dlist = stimindex{l};
% 	ntrials = length(dlist);
	ntrials = NtracesToPlot;
	tmpM = zeros(length(D{1}.datatrace(:, 1)), ntrials);
	for n = 1:ntrials
		s = filtfilt(filtB, filtA, ...
										D{dlist(n)}.datatrace(:, channelIndex));
		s1 = filter(f1, s);
		s2 = filter(f2, s1);
		s3 = filter(f3, s2);
		tmpM(:, n) = s3;
	end
	stackplot(t, tmpM, 'colormode', 'black');

	title({	datafile, 'BBN Stim', ...
				sprintf('Channel %d, Level %d', channelNumber, ...
								Dinf.test.stimcache.vrange(l))}, ...
			'Interpreter', 'none');
	xlabel('ms')
	ylabel('Trial')
	drawnow
end
%}
