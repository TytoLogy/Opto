function [resp1, npts1, resp2, npts2, resp3, npts3, resp4, npts4, out_msg] = ...
    FOCHS_RZ6RZ5Dio(stim, inpts, indev, outdev, zBUS)
%------------------------------------------------------------------------
% [resp1, npts1, resp2, npts2, resp3, npts3, resp4, npts4] = ...
%    FOCHS_RZ6RZ5Dio(stim, inpts, indev, outdev, zBUS)
%------------------------------------------------------------------------
%
% Plays stim array through out channels A and B, 
% and records data from four input channels (A-D). 
%
%------------------------------------------------------------------------
% designed to use with RPVD circuits on these devices:
% 	indev: RZ5D
% 		RZ5D_50k_FourChannelInput_zBus.rcx
% 		RZ5D_50k_4In_1Out_zBus.rcx
% 	outdev: RZ6
% 		RZ6_2Processor_SpeakerOutput_zBus.rcx
%------------------------------------------------------------------------
% Input Arguments:
%   stim    [2xN] stereo output signal (row1 = left, row2 = right)
%   inpts   number of points to acquire
%   indev   TDT device interface structure for input
%   outdev  TDT device interface structure for output
%   zBUS    TDT device interface structure for zBUS
% 
% Output Arguments:
%   respX    [1xinpts] input data vector (X=1-4)
%   nptsX    number of data points read (X=1-4)
%	out_msg	output information
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Go Ashida & Sharad Shanbhag
%   ashida@umd.edu
%   sshanbhag@neomed.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Original Version (headphone_spikeio): 2009-2011 by SJS
% Upgraded Version (HPSearch2_spikeio): 2011-2012 by GA
% Four-channel Input Version (FOCHS_spikeio): 2012 by GA
% Optogen mods: 2016 by SJS
%------------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reset before playing sound
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% # of output points
outpts = length(stim);
% send RESET command (software trigger 3)
RPtrig(indev, 3);
RPtrig(outdev, 3);
% set the output buffer length
RPsettag(outdev, 'StimDur', outpts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Play sound
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load output buffer
out_msg = RPwriteV(outdev, 'data_outL', stim(1, :)); %#ok<NASGU>
out_msg = RPwriteV(outdev, 'data_outR', stim(2, :));
% send START command (zBUS A)
zBUStrigA_PULSE(zBUS, 0, 4);
% main Loop
sweep_end = RPfastgettag(indev, 'SwpEnd');
while(sweep_end==0)
    sweep_end = RPfastgettag(indev, 'SwpEnd');
end
RPfastgettag(indev, 'SwpN');
% send STOP command (zBUS B)
zBUStrigB_PULSE(zBUS, 0, 4);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read data from the buffers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inpts1 = inpts;
inpts2 = inpts;
inpts3 = inpts;
inpts4 = inpts;

% --- channel A = 1
% get the current location in the buffer
npts1 = RPgettag(indev, 'index_inA'); 
if npts1 < inpts1
    inpts1 = npts1;
end
% read data from the buffer
resp1 = RPreadV(indev, 'data_inA', inpts1);

% --- channel B = 2
% get the current location in the buffer
npts2 = RPgettag(indev, 'index_inB'); 
if npts2 < inpts2
    inpts2 = npts2;
end
% read data from the buffer
resp2 = RPreadV(indev, 'data_inB', inpts2);

% --- channel C = 3
% get the current location in the buffer
npts3 = RPgettag(indev, 'index_inC'); 
if npts3 < inpts3
    inpts3 = npts3;
end
% read data from the buffer
resp3 = RPreadV(indev, 'data_inC', inpts3);

% --- channel D = 4
% get the current location in the buffer
npts4 = RPgettag(indev, 'index_inD'); 
if npts4 < inpts4
    inpts4 = npts4;
end
% read data from the buffer
resp4 = RPreadV(indev, 'data_inD', inpts4);

