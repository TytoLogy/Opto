%------------------------------------------------------------------------
% MTwav_procscript.m
%------------------------------------------------------------------------
% TytoLogy:Experiments:Opto:Tests
%--------------------------------------------------------------------------
% Script to develop processing of vocalization response data collected using 
% the opto program and MTwav.m + MTwav_standalone.m scripts/functions
%
% mostly pulls in bits from optoproc, but here the plotting/analysis for
% the combination of opto, wav stim and wav stim at multiple levels is
% taken into account. Eventually, this should find its way back to the
% optoproc function.
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%   sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 29 April 2019 (SJS)
%
% Revisions:
%--------------------------------------------------------------------------

%---------------------------------------------------------------------
% path and name of data file
%---------------------------------------------------------------------
datapath = '/Users/sshanbhag/Work/Data/Mouse/Opto/TestData/MT_wavtesting/20190425';
datafile = '000_20190425_0_0_0_WAV.dat';

viewOptoData(fullfile(datapath, datafile));


%---------------------------------------------------------------------
% settings for processing data (passed to optoproc function)
%---------------------------------------------------------------------
% filter
HPFreq = 350;
LPFreq = 4000;
% RMS spike threshold
% Threshold = 4.5;
Threshold = 3;
% Channel Number (use 8 for single channel data)
channelNumber = 8;
% binSize for PSTH (milliseconds)
binSize = 5;

%---------------------------------------------------------------------
% Read Data (same as optoproc)
%---------------------------------------------------------------------
[D, Dinf, tracesByStim] = getFilteredOptoData( ...
											fullfile(datapath, datafile), ...
											'Filter', [HPFreq LPFreq], ...
											'Channel', channelNumber);
if isempty(D)
	warning('%s: D is empty???!!!??!!', mfilename);
	return
end

%---------------------------------------------------------------------
% get info from filename - this makes some assumptions about file
% name structure!
% <animal id #>_<date>_<penetration #>_<unit #>_<other info>.dat
%---------------------------------------------------------------------
% break up file name into <fname>.<ext> (~ means don't save ext info)
[~, fname] = fileparts(datafile);
% locate underscores in fname
usc = find(fname == '_');
% location of start and end underscore indices
%    abcde_edcba
%        ^ ^
%        | |
%        | ---- endusc index
%        ---startusc index
endusc = usc - 1;
startusc = usc + 1;
animal = fname(1:endusc(1));
datecode = fname(startusc(1):endusc(2));
penetration = fname(startusc(2):endusc(3)); %#ok<NASGU>
unit = fname(startusc(3):endusc(4)); %#ok<NASGU>
other = fname(startusc(end):end); %#ok<NASGU>

if isempty(plotFileName)
	plotFileName = fname;
end
