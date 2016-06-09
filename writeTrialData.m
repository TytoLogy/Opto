function out = writeTrialData(datafile, datatrace, dataID, ...
												trialNumber, repNumber)
%--------------------------------------------------------------------------
% out = writeTrialData(datafile, datatrace, dataID, trialNumber, repNumber)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% Writes trial data for binary data file
% 
% Uses BinaryFileToolbox
% 
%--------------------------------------------------------------------------
% Input Arguments:
% 
%	datafile
% 	datatrace
% 	dataID
% 	trialNumber
% 	repNumber
%
% Output Arguments:
%
% 	out
% 	
%--------------------------------------------------------------------------
% See Also: readTrialData, writeDataHeader fopen, fwrite;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Revision History
%	7 June 2016 (SJS): file created
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some setup and initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% open the file for appending
fp = fopen(datafile, 'a');
% check to make sure this worked
if fp == -1
	% error occurred, return error code -1
	out = -1;
	return
else
	out = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write the trial header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% write the dataID
writeVector(fp, dataID, 'double');
% write the trial Number
writeVector(fp, trialNumber, 'int32');
% write the rep number
writeVector(fp, repNumber, 'int32');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write the data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% write the datatrace (multiplexed if multichannel!)
writeVector(fp, datatrace, 'double');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% close the file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
fclose(fp);


