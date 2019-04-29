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
[animal, datecode, penetration, unit, other] = opto_name_deconstruct(datafile);

