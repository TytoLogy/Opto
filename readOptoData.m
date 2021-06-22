function [data, varargout] = readOptoData(varargin)
%------------------------------------------------------------------------
% [data, datainfo] = readOptoData(varargin)
%------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
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
% See Also: optoproc, getFilteredOptoData
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 10 June, 2016 (SJS) 
%			- adapted from readHPData.m
% 
% Revisions:
% 24 June 2016 (SJS): added data position, status and # read
% 12 Jun 2020 (SJS): updated comments, docs
%------------------------------------------------------------------------
% TO DO:
%	*Documentation!
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% define some things
%--------------------------------------------------------------------------
data = [];
datafile = [];
datainfo = [];
wavinfo_matfile = [];
DEMUX = 0;

%--------------------------------------------------------------------------
% check inputs
%--------------------------------------------------------------------------
if nargin
	if exist(varargin{1}, 'file') == 2
		datafile = varargin{1};
	else
		error([mfilename ': datafile ' varargin{1} ' not found.']);
	end
	
	if nargin == 2
		DEMUX = 1;
	end
end

%--------------------------------------------------------------------------
% have user select data file if one was not provided
%--------------------------------------------------------------------------
if isempty(datafile)
	[datafile, datapath] = uigetfile('*.dat','Select data file');
	if datafile == 0
		disp('user cancelled datafile load')
		if nargout > 1
			varargout{1} = datainfo;
		end
		return
	end
	datafile = fullfile(datapath, datafile);
end

%--------------------------------------------------------------------------
% read in data
%--------------------------------------------------------------------------
fprintf('Reading data from %s\n', datafile);
% open file
fp = fopen(datafile, 'r');

% read the header
try
	datainfo = readOptoDataFileHeader(fp);
catch errMsg
	errMsg.message
	errflag = 1;
	fclose(fp);
	return;
end

% convert test.Name into characters
% need to see if Name is field in test structure - due to inconsistencies
% in the different tests, some (e.g., opto-amp) do not have Name and only
% have Type
datainfo.test
if isfield(datainfo.test, 'Name')
   datainfo.test.Name = char(datainfo.test.Name);
else
   fprintf('file %s: \n\tNo ''Name'' field in datainfo.test\n', datafile);
   fprintf('Checking for ''Type''\n');
   if isfield(datainfo.test, 'Type')
      datainfo.test.Type = char(datainfo.test.Type);
      datainfo.test.Name = datainfo.test.Type;
   else
      error('Cannot determine test type');
   end
end
   
% check if stimcache exists
if isfield(datainfo.test, 'stimcache')
	% if so, get # of reps and trials from size of trialRandomSequence
	[numreps, numtrials] = size(datainfo.test.stimcache.trialRandomSequence);
else
	% otherwise, compute from Reps and nCombinations
	numreps = datainfo.test.Reps;
	numtrials = datainfo.test.nCombinations;
end
nettrials = numreps*numtrials;	
disp([mfilename sprintf(': reading %d reps, %d trials', numreps, numtrials)]);

% read the data start string
try
	datastartstring = readString(fp); %#ok<*NASGU>
catch errMsg
	errMsg.message
	fclose(fp);
	return;
end

% read the data
try
	[data, nread, dpos, status] = readOptoTrialData(fp, nettrials);
catch errMsg
	errMsg.message
	fclose(fp);
	return;
end

% read the data end string
try
	dataendstring = readString(fp);
catch errMsg
	errMsg.message
	fclose(fp);
	return;
end

% read the data end time
try
	datainfo.time_end = readVector(fp);
catch errMsg
	errMsg.message
	fclose(fp);
	return;
end

% close file
fclose(fp);

% assign values to datainfo struct
datainfo.status = status;
datainfo.nread = nread;
datainfo.dpos = dpos;

%--------------------------------------------------------------------------
% now, demultiplex the data if there is more than 1 channel in the data
% traces
%--------------------------------------------------------------------------
if (datainfo.channels.nInputChannels > 1) 
	if DEMUX
		nTrials = length(data);
		for n = 1:nTrials
			data{n}.datatrace = mcFastDeMux(data{n}.datatrace, ...
											datainfo.channels.nInputChannels);
		end
	end
end

%--------------------------------------------------------------------------
% get stimulus information
%--------------------------------------------------------------------------
% build wavinfo_matfile name
[datapath, basename] = fileparts(datafile);
wavinfo_matfile = fullfile(datapath, [basename '_wavinfo.mat']);

% check if wavinfo exists
if exist(wavinfo_matfile, 'file')
	fprintf('Loading stimList from %s\n', wavinfo_matfile);
	load(wavinfo_matfile, 'stimList');
	datainfo.stimList = stimList;
else
	datainfo.stimList = [];
end

% assign to output
if nargout == 2
	varargout{1} = datainfo;
end


