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


