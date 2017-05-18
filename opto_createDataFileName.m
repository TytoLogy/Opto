function [datapath, datafile] = opto_createDataFileName(handles, test)
%--------------------------------------------------------------------------
% datafile =  opto_createDataFileName(handles)
%--------------------------------------------------------------------------
% opto program
%--------------------------------------------------------------------------
% 
% Generates output dat afilename
% 
%--------------------------------------------------------------------------
% Input Arguments:
%
% Output Arguments:
%--------------------------------------------------------------------------
% See Also: writeStimData, fopen, fwrite, BinaryFileToolbox, opto
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Revision History
%	5 May 2017 (SJS): file created
%	17 May 2017 (SJS):
%	 -	added directory YYYYMMDD to output path
%	 - modified generation of filename to account for standalone types
%--------------------------------------------------------------------------

% Check on test type and name - if name exists in type, use that
if isfield(test, 'Name')
	testtype = test.Name;
else
	testtype = test.Type;
end

% Now, create filename from animal info
%	animal # _ date _ unit _ Penetration # _ Depth _ type .dat
defaultfile = sprintf('%s_%s_%s_%s_%s_%s.dat', ...
								handles.H.animal.Animal, ...
								handles.H.animal.Date, ...
								handles.H.animal.Unit, ...
								handles.H.animal.Pen, ...
								handles.H.animal.Depth, ...
								testtype);
% check if default output directory exists
if ~exist(handles.H.DefaultOutputDir, 'dir')
	% if not, create it
	mkdir(handles.H.DefaultOutputDir);
end
defaultdir = [handles.H.DefaultOutputDir filesep ...
					sprintf('%s', handles.H.animal.Animal) filesep ...
					datestr(now, 'yyyymmdd')];
% check if animal directory exists
if ~exist(defaultdir, 'dir')
	mkdir(defaultdir);
end
% default output file
defaultfile = fullfile(defaultdir, defaultfile);
% check with user
[datafile, datapath] = uiputfile('*.dat', 'Save Data', defaultfile);