function [D, numRead, varargout] = readOptoTrialData(fp, netTrials)
%--------------------------------------------------------------------------
% [D, numRead, varargout]  = readOptoTrialData(fp, netTrials)
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
% 	netTrials	# of trials that should be in file (compute from 
% 				header information
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

errflag = 0;
trial = 1;

try
	while ~feof(fp) && trial <= netTrials
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% read the trial header
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% read the dataID
		D{trial}.dataID = readVector(fp);
		% read the trial Number
		D{trial}.trialNumber = readVector(fp);
		% read the rep number
		D{trial}.repNumber = readVector(fp);
		
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		% read the trial data
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		D{trial}.datatrace = readVector(fp);
		trial = trial + 1;
	end
catch
	lasterror
	errflag = 1;
end

if trial ~= netTrials
    numRead = trial - 1;
	varargout{1} = 'incomplete';
else
	numRead = trial;
end


