function varargout = getFilteredOptoData(varargin)
%------------------------------------------------------------------------
% [data, datainfo, tracesByStim] = viewOptoData(varargin)
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
% data          contains the read data in a cell structure array.
% datainfo      has the file header information.
%
%------------------------------------------------------------------------
% See Also:
%------------------------------------------------------------------------
%------------------------------------------------------------------------
%  Sharad Shanbhag
%   sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 10 June, 2016 (SJS)
%           - adapted from readHPData.m
%
% Revisions:
%	10 Jul 2017 (SJS): some minor tweaks
%	10 Oct 2017 (SJS): for some reason, this was in OptoAnalysis dir; 
%							 relocated to opto program dir
%------------------------------------------------------------------------
% TO DO:
%   *Documentation!
%--------------------------------------------------------------------------
%% settings for processing data
HPFreq = 100;
LPFreq = 10000;

%% Read Data
% set paths
datapath = '';
datafile = '';
if ispc
	defaultpath = 'E:\Data\SJS';
	defaultfile = '';
else
	defaultpath = '/Users/sshanbhag/Work/Data/Mouse/Opto';
	defaultfile = '';
end
if nargin
	[datapath, datafile, dataext] = fileparts(varargin{1});
	datafile = [datafile dataext];
	if nargin == 2
		HPFreq = varargin{2}(1);
		LPFreq = varargin{2}(2);
	end
end
if isempty(datafile)
	% get data file from user
	[datafile, datapath] = uigetfile('*.dat', 'Select opto data file', ...
														 fullfile(defaultpath, defaultfile));
	if datafile == 0
		varargout{1} = [];
		varargout{2} = [];
		varargout{3} = [];
		return
	end
end
% read in raw data
[D, Dinf] = readOptoData(fullfile(datapath, datafile));
% read in test data (if it exists)
[~, fbase, ~] = fileparts(datafile);
testfile = [fbase '_testdata.mat'];
if exist(fullfile(datapath, testfile), 'file')
	load(fullfile(datapath, testfile), 'testdata');
else
	testdata = [];
end
%%
% read in wav info (if it exists)
wavinfofile = [fbase '_wavinfo.mat'];
if exist(fullfile(datapath, wavinfofile), 'file')
	load(fullfile(datapath, wavinfofile));
end
%% define filter for data
% sampling rate
Fs = Dinf.indev.Fs;
% build bandpass filter, store coefficients in filtB, filtA
fband = [HPFreq LPFreq] ./ (0.5 * Fs);
[filtB, filtA] = butter(5, fband);
%% Get test info
Dinf = correctTestType(Dinf);
fprintf('Test type: %s\n', Dinf.test.Type);

%%
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
   
% for WavFile, need to find indices with same filename.
	case 'WAVFILE'
		% get list of stimuli (wav file names)
		nwavs = length(Dinf.stimList);
		wavlist = cell(nwavs, 1);
		stimindex = cell(nwavs, 1);
		for w = 1:nwavs
			stype = Dinf.stimList(w).audio.signal.Type;
			if strcmpi(stype, 'null')
				wavlist{w} = 'null';
			elseif strcmpi(stype, 'noise')
				wavlist{w} = 'BBN';
			elseif strcmpi(stype, 'wav')
				[~, wavlist{w}] = fileparts(Dinf.stimList(w).audio.signal.WavFile);
			else
				error('%s: unknown type %s', mfilename, stype);
			end
			stimindex{w} = find(Dinf.test.stimIndices == w);
		end
		Dinf.test.wavlist = wavlist;
	otherwise
		error('%s: unsupported test type %s', mfilename, Dinf.test.Type);
end
 
%% Pull out trials, apply filter, store in matrix
if isfield(Dinf.channels, 'nRecordChannels')
	nchan = Dinf.channels.nRecordChannels; %#ok<NASGU>
	channelList = Dinf.channels.RecordChannelList;
else
	nchan = Dinf.channels.nInputChannels; %#ok<NASGU>
	channelList = Dinf.channels.InputChannels;
end
 
%% find channel data
channelNumber = 8;
channelIndex = find(channelList == channelNumber);
if isempty(channelIndex)
	error('%s: Channel %d not recorded', mfilename, channelNumber);
end
%% build tracesByStim; process will vary depending on stimulus type
if strcmpi(Dinf.test.Type, 'FREQ')
	tracesByStim = cell(nfreqs, 1);
	for f = 1:nfreqs
		dlist = stimindex{f};
		ntrials = length(dlist);
		tracesByStim{f} = zeros(length(D{1}.datatrace(:, 1)), ntrials);
		for n = 1:ntrials
			tracesByStim{f}(:, n) = filtfilt(filtB, filtA, ...
												D{dlist(n)}.datatrace(:, channelIndex));
		end
	end
end
if strcmpi(Dinf.test.Type, 'LEVEL')
	tracesByStim = cell(nlevels, 1);
	for l = 1:nlevels
		dlist = stimindex{l};
		ntrials = length(dlist);
		tracesByStim{l} = zeros(length(D{1}.datatrace(:, 1)), ntrials);
		for n = 1:ntrials
			tracesByStim{l}(:, n) = filtfilt(filtB, filtA, ...
													D{dlist(n)}.datatrace(:, channelIndex));
		end
	end
end
if strcmpi(Dinf.test.Type, 'WavFile')
	tracesByStim = cell(nwavs, 1);
	for w = 1:nwavs
		% create temporary array to hold data
		tracesByStim{w} = zeros(length(D{1}.datatrace(:, 1)), Dinf.test.Reps);
		for n = 1:Dinf.test.Reps
			dIndx = stimindex{w}(n);
			tracesByStim{w}(:, n) = filtfilt(filtB, filtA, ...
														D{dIndx}.datatrace(:, channelIndex));
		end
	end
end

%% assign outputs
varargout{1} = D;
varargout{2} = Dinf;
varargout{3} = tracesByStim;

%% work from testdata
% if no testdata, get outta here
if isempty(testdata)
	return
elseif ~isfield(testdata, 'SpikeTimes')
	return
else
	varargout{4} = testdata;
end


 