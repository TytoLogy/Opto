%------------------------------------------------------------------------
% [data, datainfo] = readOptoData(varargin)
%------------------------------------------------------------------------
% % TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% Reads binary data file created by the opto program
%
% If a datafile name is provided in varargin (e.g.,
% readOptoData('c:\mydir\mynicedata.dat'), the program will attempt to 
% read from that file.  
% 
% Otherwise it will open a dialog window for the user
% to select the data (.dat) file.
% 
%------------------------------------------------------------------------
% Output Arguments:
% 
% data			contains the read data in a cell structure array.
% datainfo		has the file header information.
% 
%------------------------------------------------------------------------
% See Also:
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 10 June, 2016 (SJS) 
%			- adapted from readHPData.m
% 
% Revisions:
%------------------------------------------------------------------------
% TO DO:
%	*Documentation!
%--------------------------------------------------------------------------

HPFreq = 200;
LPFreq = 8000;

%%
if ispc
	datapath = 'E:\Data\1058';
	datafile = '1058_20160623_0_02_1500_FREQ.dat';
else 
	datapath = '/Users/sshanbhag/Work/Data/Mouse/Opto/1058';
	datafile = '1058_20160623_0_02_1500_FREQ.dat';
end

% read in data
[D, Dinf] = readOptoData(fullfile(datapath, datafile));

%%

inchan = Dinf.channels.InputChannels;
nchan = length(inchan);

Fs = Dinf.indev.Fs;

% build filter
fband = [HPFreq LPFreq] ./ (0.5 * Fs);
[filtB, filtA] = butter(5, fband);

% filter, plot data
tmpD = zeros(size(D{1}.datatrace));
t = (1/Fs)*((1:length(tmpD(:, 1))) - 1);

%%
for c = 1:nchan
	tmpD(:, c) = filtfilt(filtB, filtA, D{4}.datatrace(:, c));
end
plot(1000*t, tmpD)

