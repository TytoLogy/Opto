% channels struct
% 
% OutputChannelL				audio output channel on RZ6
% OutputChannelR				audio output channel on RZ6
% nInputChannels				total number of neural recording channels on RZ5D
% InputChannels				list of input neural channels on RZ5D
% OpticalChannel				D/A output channel on RZ5d for opto trigger
% MonitorChannel				neural channel to monitor from RZ5D
% MonitorOutputChannel		D/A output channel on RZ5D for monitored neural data

channels.OutputChannelL = 1;
channels.OutputChannelR = 2;
channels.nInputChannels = 16;
channels.InputChannels = 1:channels.nInputChannels;
channels.OpticalChannel = 10;
channels.MonitorChannel = 8;
channels.MonitorOutputChannel = 9;
% This is for all channels are "on"
% channels.RecordChannels = num2cell(true(channels.nInputChannels, 1));
% This is for all channels "off"
channels.RecordChannels = num2cell(false(channels.nInputChannels, 1));
% This sets monitored channel to be recorded
channels.RecordChannels{channels.MonitorChannel} = true;
channels.nRecordChannels = sum(cell2mat(channels.RecordChannels));
channels.RecordChannelList = find(cell2mat(channels.RecordChannels));