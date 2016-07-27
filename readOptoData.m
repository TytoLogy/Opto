function [data, datainfo] = readOptoData(varargin)
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
%	24 June 2016 (SJS): added data position, status and # read
%------------------------------------------------------------------------
% TO DO:
%	*Documentation!
%--------------------------------------------------------------------------

data = [];
datafile = [];
datainfo = [];
DEMUX = 0;

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
	[data, nread, dpos, status] = readOptoTrialData(fp, nettrials);
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


% now, demultiplex the data if there are more than 1 channel in the data
% traces
if (datainfo.channels.nInputChannels > 1) 
	if DEMUX
		nTrials = length(data);
		for n = 1:nTrials
			data{n}.datatrace = mcFastDeMux(data{n}.datatrace, ...
											datainfo.channels.nInputChannels);
		end
	end
end

	


