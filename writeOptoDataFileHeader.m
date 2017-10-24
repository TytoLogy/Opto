function out = writeOptoDataFileHeader(datafile, test, audio, opto, ...
												channels, caldata, indev, outdev)
%--------------------------------------------------------------------------
% out = writeDataFileHeader((datafile, test, audio, opto, ...
% 												channels, caldata, indev, outdev)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% Writes header for binary data file
% 
% Uses BinaryFileToolbox
% 
%--------------------------------------------------------------------------
% Input Arguments:
% 
%	datafile			data file name
% 	test				test data structure
% 	audio				audio data structure
% 	opto				opto data structure
% 	channels			channels structure
% 	caldata			calibration data
% 	indev				input device structure
% 	outdev			output TDT device structure
%
% Output Arguments:
%	out				status
%--------------------------------------------------------------------------
% See Also: writeData, fopen, fwrite, BinaryFileToolbox
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Revision History
%	7 June 2016 (SJS): file created from writeDataFileHeader of 
%							 HPSearch Experiment
%	24 Oct 2017 (SJS): added animal struct output after the test struct
%--------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% some setup and initialization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% get the start time
time_start = now;
% open the file for writing - create the file anew 
% (subsequent fopen() calls should use 'a' to append to file, 
%  unless you wish to destroy the data...)
fp = fopen(datafile, 'w');
% check to make sure this worked
if fp == -1
	% error occurred, return error code -1
	out = -1;
	return
else
	out = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write the header
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% write the filename (may be useful in future if filename is
% changed????)
writeString(fp, datafile);
% write a string that says 'HEADER_START'
writeString(fp, 'HEADER_START');
% now write the time (use datestr(timevalue) to get human readable form)
writeVector(fp, time_start, 'double');
% now, write the test structure
% ***embed the name of this and all structs***
writeStruct(fp, test, 'test');
% write the animal structure
writeStruct(fp, animal, 'animal');
% write the audio structure
writeStruct(fp, audio, 'audio');
% write the opto structure
writeStruct(fp, opto, 'opto');
% write the channels structure
writeStruct(fp, channels, 'channels');
% write the calibration data struct (caldata)
writeStruct(fp, caldata, 'caldata');
% write the indev data struct (indev)
writeStruct(fp, extractRPDevInfo(indev), 'indev');
% write the outdev data struct (outdev)
writeStruct(fp, extractRPDevInfo(outdev), 'outdev');
% write the end of the header string
writeString(fp, 'HEADER_END');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write the beginning of the data string
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
writeString(fp, 'DATA_START');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% close the file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
fclose(fp);


