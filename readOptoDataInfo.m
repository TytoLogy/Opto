function [datainfo] = readOptoDataInfo(varargin)
%------------------------------------------------------------------------
% [datainfo] = readOptoDataInfo(varargin)
%------------------------------------------------------------------------
% % TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% Reads binary data file header created by the opto program
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
% datainfo		has the file header information.
% 
%------------------------------------------------------------------------
% See Also: readOptoData
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 25 February, 2020 (SJS) 
%			- adapted from readOptoData.m
% 
% Revisions:
%------------------------------------------------------------------------
% TO DO:
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% define some things
%--------------------------------------------------------------------------
datafile = [];
datainfo = [];
wavinfo_matfile = []; %#ok<NASGU>

%--------------------------------------------------------------------------
% check inputs
%--------------------------------------------------------------------------
if nargin
	if exist(varargin{1}, 'file') == 2
		datafile = varargin{1};
	else
		error([mfilename ': datafile ' varargin{1} ' not found.']);
	end
end

%--------------------------------------------------------------------------
% have user select data file if one was not provided
%--------------------------------------------------------------------------
if isempty(datafile)
	[datafile, datapath] = uigetfile('*.dat','Select data file');
	if datafile == 0
		disp('user cancelled datafile load')
		return
	end
	datafile = fullfile(datapath, datafile);
end

%--------------------------------------------------------------------------
% read in data
%--------------------------------------------------------------------------
fprintf('Reading header from %s\n', datafile);
% open file
fp = fopen(datafile, 'r');

% read the header
try
	datainfo = readOptoDataFileHeader(fp);
catch errMsg
	errMsg.message
	fclose(fp);
	return;
end
% close file
fclose(fp);

% convert test.Name into characters
datainfo.test.Name = char(datainfo.test.Name);

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




