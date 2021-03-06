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
%	H	with fields
% 		datafile			data file name
% 		test				test data structure
% 		animal			animal data structure
% 		audio				audio data structure
% 		opto				opto data structure
% 		channels			channels structure
% 		caldata			calibration data
% 		indev				input device structure
% 		outdev			output TDT device structure
%
%--------------------------------------------------------------------------
% See Also: writeOptoDataFileHeader, fopen, fwrite;
%--------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 10 June, 2016 (SJS) 
%			- adapted from readHPDataFileHeader.m
% 
% Revision History
%	24 Oct 2017 (SJS): updated code to deal with presence of "animal"
%							 struct after "test"
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
% need to handle situation where "animal" struct is present
[tmpstruct, tmpname] = readStruct(fp);
if strcmpi(tmpname, 'animal')
	% animal struct was read
	H.animal = tmpstruct;
	% now, read the audio structure
	H.audio = readStruct(fp);
elseif strcmpi(tmpname, 'audio')
	% otherwise, the audio struct was read and animal struct is empty
	H.audio = tmpstruct;
	H.animal = struct();
end
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

