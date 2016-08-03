function [data, datainfo] = readOptoData_noDeMux(varargin)
%------------------------------------------------------------------------
% [data, datainfo] = readOptoData_noDeMux(varargin)
%------------------------------------------------------------------------
% % TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% Reads binary data file created by the opto program (newer versions
% with channel record option enabled)
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
% Created: 11 July, 2016 (SJS) 
%			- adapted from readOptoData.m
% 
%------------------------------------------------------------------------
% TO DO:
%	*Documentation!
%--------------------------------------------------------------------------

data = [];
datafile = [];
datainfo = [];

if nargin
	if exist(varargin{1}, 'file') == 2
		datafile = varargin{1};
	else
		error([mfilename ': datafile ' varargin{1} ' not found.']);
	end
end

if isempty(datafile)
	[datafile, datapath] = uigetfile('*.dat','Select data file');
	if datafile == 0
		disp('user cancelled datafile load')
		return
	end
	datafile = fullfile(datapath, datafile);
end


fp = fopen(datafile, 'r');

try
	% read the header
	datainfo = readOptoDataFileHeader(fp);
catch errMsg
	errMsg.message
	errflag = 1;
	fclose(fp);
	return;
end

[numreps, numtrials] = size(datainfo.test.stimcache.trialRandomSequence);
nettrials = numreps*numtrials;

disp([mfilename sprintf(': reading %d reps, %d trials', numreps, numtrials)]);

try
	% read the data start string
	datastartstring = readString(fp); %#ok<*NASGU>
catch errMsg
	errMsg.message
	fclose(fp);
	return;
end

try
	% read the data
	[data, nread, dpos, status] = readOptoTrialData_noDeMux(...
							fp, nettrials, datainfo.channels.nInputChannels );
catch errMsg
	errMsg.message
	fclose(fp);
	return;
end

try
	% read the data end string
	dataendstring = readString(fp);
catch errMsg
	errMsg.message
	fclose(fp);
	return;
end

try
	% read the data end time
	datainfo.time_end = readVector(fp);
catch errMsg
	errMsg.message
	fclose(fp);
	return;
end

fclose(fp);

datainfo.status = status;
datainfo.nread = nread;
datainfo.dpos = dpos;

function [D, numRead, varargout] = readOptoTrialData_noDeMux(...
																fp, netTrials, nchan)
%--------------------------------------------------------------------------
% [D, numRead, varargout]  = readOptoTrialData_noDeMux(fp, netTrials, nchan)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% read data from binary data file from HPSearch program
% 
% Uses BinaryFileToolbox
% 
%--------------------------------------------------------------------------
% Input Arguments:
%	fp			file stream
% 	netTrials	# of trials that should be in file (computed from 
%					header information)
%
% Output Arguments:
%	D
% 	numRead
% 	varargout
%
%--------------------------------------------------------------------------
% See Also: writeOptoTrialData, fopen, fwrite;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Revision History
% Revision History
%	7 June 2016 (SJS): file created from HPSearch readTrialData
%	23 June 2016 (SJS): added Dpos output
%	11 Jul 2016 (SJS): changed reading of data to readMatrix (from
%								readVector)
%--------------------------------------------------------------------------
% TO DO:
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some setup and initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% check to make sure we don't have a bogus fp
if fp == -1
	% error occurred, return error code 0
	D = 0;
	return
end

% allocate cell struct array
D = cell(netTrials, 1);
Dpos = zeros(netTrials, 1);

errflag = 0;
trial = 0;

try
	while ~feof(fp) && trial < netTrials
		trial = trial + 1;
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% read the trial header
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% get file position and store in Dpos
		Dpos(trial) = ftell(fp);
		% read the dataID
		D{trial}.dataID = readVector(fp);
		% read the trial Number
		D{trial}.trialNumber = readVector(fp);
		% read the rep number
		D{trial}.repNumber = readVector(fp);
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% read the trial data
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		D{trial}.datatrace = mcFastDeMux(readVector(fp), nchan);
		
	end
catch errMsg
	fprintf('%s\n', errMsg.message);
	errflag = 1;
end

if errflag
	warning('%s: error reading data', mfilename);
end

if trial ~= netTrials
	numRead = trial - 1;
	varargout{1} = Dpos(1:numRead);
	varargout{2} = 'incomplete';
else
	numRead = trial;
	varargout{1} = Dpos;
	varargout{2} = 'complete';	
end



