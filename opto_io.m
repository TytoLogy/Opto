function [resp, mcIndex] = opto_io(stim, inpts, indev, outdev, zBUS)
%------------------------------------------------------------------------
% [resp, mcIndex] = opto_io(stim, inpts, indev, outdev, zBUS)
%------------------------------------------------------------------------
%
% Plays stim array through out channels A and B, 
% and records data from 16 input channels. 
%
%------------------------------------------------------------------------
% designed to use with RPVD circuits on these devices:
% 	indev: RZ5D
% 		RZ5D_50k_16In_1Out_zBus.rcx
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
%   resp			response matrix (16, inpts)
%   mcIndex		# of samples read
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
% Opto script mods: 2016 by SJS
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Reset before playing sound
% send RESET command (software trigger 3)
%------------------------------------------------------------------------
RPtrig(indev, 3);
RPtrig(outdev, 3);

%------------------------------------------------------------------------
% Set output pts, input pts per stimulus length and inpts argument
%------------------------------------------------------------------------
% # of output points
outpts = length(stim);
% set the output buffer length
RPsettag(outdev, 'StimDur', outpts);
% set # of input pts
RPsettag(indev, 'AcqDur', inpts);

%------------------------------------------------------------------------
% Play sound, record data
%------------------------------------------------------------------------
% load output buffer
RPwriteV(outdev, 'data_outL', stim(1, :)); 
RPwriteV(outdev, 'data_outR', stim(2, :));
% send START command (zBUS A)
zBUStrigA_PULSE(zBUS, 0, 4);
% main Loop - loop until circuit sets SwpEnd tag to 1
sweep_end = RPfastgettag(indev, 'SwpEnd');
while(sweep_end==0)
    sweep_end = RPfastgettag(indev, 'SwpEnd');
end
RPfastgettag(indev, 'SwpN');
% send STOP command (zBUS B)
zBUStrigB_PULSE(zBUS, 0, 4);

%------------------------------------------------------------------------
% Read data from the buffer
%------------------------------------------------------------------------
% get the current location in the buffer
mcIndex = RPgettag(indev, 'mcIndex');
%reads from the buffer
resp = RPreadV(indev, 'mcData', mcIndex)';
% resp = resp';

