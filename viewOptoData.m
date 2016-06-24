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

HPFreq = 125;
LPFreq = 8000;

%%
datapath = 'E:\Data\1058';
datafile = '1058_20160623_0_02_1500_FREQ.dat';

% read in data
[D, Dinf] = readOptoData(fullfile(datapath, datafile));

%%

channel = 1;
Fs = Dinf.indev.Fs;

							
% build filter
fband = [HPFreq LPFreq] ./ (0.5 * Fs);
[filtB, filtA] = butter(5, fband);

tmpD = D{1}.datatrace(:, channel);


plot(filtfilt(filtB, filtA,tmp));


