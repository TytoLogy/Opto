function varargout = closeOptoTrialData(datafile, varargin)
%--------------------------------------------------------------------------
% out = closeOptoTrialData(datafile, time_end)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% Closes trial data for binary data file
% 
% Uses BinaryFileToolbox
% 
%--------------------------------------------------------------------------
% Input Arguments:
% 
%	datafile			data file name to be closed
%	time_end			end of experiment time (optional)
%
% Output Arguments:
%
% 	out	time_end (optional)
% 	
% See Also: writeTrialData, fopen, fwrite;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Revision History
%	7 June 2016 (SJS): file created from HPSearch closeTrialData
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some setup and initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% get the finish time
if nargin == 1
	time_end = now;
else
	time_end = varargin{1};
end
if nargout
	varargout{1} = time_end;
end

% open the file for appending
fp = fopen(datafile, 'a');

% check to make sure this worked
if fp == -1
	% error occurred, return error code -1
	varargout{1} = -1;
	return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write the trial header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% write the END string
writeString(fp, 'DATA_END');

% write the time
writeVector(fp, time_end, 'double');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% close the file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
fclose(fp);


