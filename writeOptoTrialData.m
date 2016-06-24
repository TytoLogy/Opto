function out = writeOptoTrialData(datafile, datatrace, dataID, ...
												trialNumber, repNumber)
%--------------------------------------------------------------------------
% out = writeOptoTrialData(datafile, datatrace, dataID, trialNumber, repNumber)
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
% See Also: readOptoTrialData, writeOptoDataHeader fopen, fwrite;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Revision History
%	7 June 2016 (SJS): file created from HPSearch writeTrialData
%	10 Jun 2016 (SJS): renamed writeOptoTrialData
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


