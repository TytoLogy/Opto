function [spikes, nspikes, spikerms] = opto_getspikes(indev)
%------------------------------------------------------------------------
% [spikes, nspikes] = opto_getspikes(indev)
%------------------------------------------------------------------------
%
% gets spikes from input device (RZ5D)
%
%------------------------------------------------------------------------
% designed to use with RPVD circuits on these devices:
% 	indev: RZ5D
% 		RZ5D_50k_16In_1Out_FindSpike_zBus.rcx
%------------------------------------------------------------------------
%   indev   TDT device interface structure for input
% 
% Output Arguments:
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad Shanbhag
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Created 12 June, 2017
%------------------------------------------------------------------------

spikes = [];
spikesamples = 0; %#ok<NASGU>
nspikes = 0; %#ok<NASGU>

%------------------------------------------------------------------------
% Read spike data from the buffer
%------------------------------------------------------------------------
% get the current location in the spike buffer
spikesamples = RPgettag(indev, 'SpikeSamples');
% read data from the buffer
if spikesamples > 0
	spikes = RPreadV(indev, 'SpikeData', spikesamples);
end
% get spike rms value
spikerms = RPgettag(indev, 'SpikeRMS');
% get nspikes
nspikes = RPgettag(indev, 'SpikeCount');

