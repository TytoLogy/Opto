function [resp, mcIndex] = opto_readbuf(indev, indxname, bufname)
%------------------------------------------------------------------------
% [resp, mcIndex] = opto_readbuf(indev, indxname, bufname)
%------------------------------------------------------------------------
%
% reads data from input buffer on indev. 
%
%------------------------------------------------------------------------
% designed to use with RPVD circuits on these devices:
% 	indev: RZ5D
% 		RZ5D_50k_16In_1Out_zBus.rcx
%------------------------------------------------------------------------
% Input Arguments:
%   indev		TDT device struct
%   indxname	tag corresponding to # points in buffer
%   bufname		name of buffer in RPvD circuit
% 
% Output Arguments:
%   resp			response matrix (16, inpts)
%   mcIndex		# of samples read
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%  sshanbhag@neomed.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% 24 August, 2016:
%   adapted from opto_io.m
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% get the current location in the buffer
%------------------------------------------------------------------------
mcIndex = RPgettag(indev, indxname);

%------------------------------------------------------------------------
% read from the buffer
%------------------------------------------------------------------------
resp = RPreadV(indev, bufname, mcIndex)';


