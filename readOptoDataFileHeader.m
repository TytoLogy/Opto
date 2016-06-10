function H = readOptoDataFileHeader(fp)
%--------------------------------------------------------------------------
% H = readOptoDataFileHeader(fp)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% read header from binary data file from headphone data
% 
% Uses BinaryFileToolbox
% 
%--------------------------------------------------------------------------
% Input Arguments:
% 
%	fp		file stream
%
% Output Arguments:
% 
%	H
%
%--------------------------------------------------------------------------
% See Also: writeDataFileHeader, fopen, fwrite;
%--------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 10 June, 2016 (SJS) 
%			- adapted from readHPDataFileHeader.m
% 
% Revision History
%--------------------------------------------------------------------------
% TO DO:
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some setup and initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% check to make sure we don't have a bogus fp
if fp == -1
	% error occurred, return error code 0
	H = 0;
	return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read the header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% read the filename 
H.filename = readString(fp);
% read a string that says 'HEADER_START'
H.startstring = readString(fp);
% now read the time (use datestr(timevalue) to get human readable form)
H.time_start = readVector(fp);
% now, read the test structure
H.test = readStruct(fp);
% now, read the audio structure
H.audio = readStruct(fp);
% now, read the opto structure
H.opto = readStruct(fp);
% now, read the channels structure
H.channels = readStruct(fp);
% read the calibration data struct (caldata)
H.caldata = readStruct(fp);
% read the indev structure
H.indev = readStruct(fp);
% read the outdev data struct (outdev)
H.outdev = readStruct(fp);
% read a string that says 'HEADER_END'
H.endstring = readString(fp);
