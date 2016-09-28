function H = opto_InitH
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Opto program
%------------------------------------------------------------------------
% 
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Input Arguments:
%
% Output Arguments:
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad Shanbhag 
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Revisions
%------------------------------------------------------------------------

opto = struct(	'Enable', 0, ...
					'Delay', 0, ...
					'Dur', 100, ...
					'Amp', 50, ...
					'Channel', 10);

noise = struct(	'Type', 'noise', ...
						'Fmin', 4000, ...
						'Fmax', 80000, ...
						'PeakAmplitude', 1);
					
tone = struct(	'Type', 'tone', ...
					'Frequency', 5000, ...
					'RadVary', 1, ...
					'PeakAmplitude', 1);

wav = struct(	'Type', 'wav', ...
					'filenm', 'P100_11.wav', ...
					'pathnm', 'C:\TytoLogy\Experiments\Opto', ...
					'isloaded', 0, ...
					'data', [], ...
					'info', []);

audio = struct(	'Signal', 'noise', ...
						'Delay', 100, ...
						'Duration', 200, ...
						'Level', 50, ...
						'Ramp', 1, ...
						'Frozen', 0, ...
						'ISI', 100, ...
						'AttenL', 0, ...
						'AttenR', 120);
					
		
% fake calibration data initially			
caldata = fake_caldata('Freqs', 3000:1000:96000);

% input device
indev = struct(	'hardware', 'RZ5D', ...
						'C', [], ...
						'handle', [], ...
						'status', 0, ...
						'Fs', 50000, ...
						'Circuit_Path', 'C:\TytoLogy\Toolboxes\TDTToolbox\Circuits\RZ5D', ...
						'Circuit_Name', 'RZ5D_50k_16In_1Out_zBus.rcx', ...
						'Dnum', 1	);
% output device
outdev = struct(	'hardware', 'RZ6', ...
						'C', [], ...
						'handle', [], ...
						'status', 0, ...
						'Fs', 200000, ...
						'Circuit_Path', 'C:\TytoLogy\Toolboxes\TDTToolbox\Circuits\RZ6', ...
						'Circuit_Name', 'RZ6_2ChannelOutputAtten_zBus', ...
						'Dnum', 1	);
					
zBUS.C =[];
zBUS.handle = [];
zBUS.status = 0;

PA5L = [];
PA5R = [];

% -- TDT I/O channels ---- default TDT hardware = 'NO_TDT'
channels.OutputChannelL = 1;
channels.OutputChannelR = 2;
channels.nInputChannels = 16;
channels.InputChannels = 1:channels.nInputChannels;
channels.OpticalChannel = 10;
channels.MonitorChannel = 1;
channels.MonitorOutputChannel = 9; 
channels.RecordChannels = num2cell(true(channels.nInputChannels, 1));
channels.nRecordChannels = sum(cell2mat(channels.RecordChannels));
channels.RecordChannelList = find(cell2mat(channels.RecordChannels));

% configurationi
% lock file
config.TDTLOCKFILE = fullfile(pwd, 'tdtlockfile.mat');
config.CONFIGNAME = 'RZ6OUT200K_RZ5DIN';
% function handles
config.ioFunc = @opto_io;
config.TDTsetFunc = @opto_TDTsettings;
config.setattenFunc = @RZ6setatten;

TDT = struct(	'Enable', 0, ...
					'indev', indev, ...
					'outdev', outdev, ...
					'zBUS', zBUS, ...
					'PA5L', PA5L, ...
					'PA5R', PA5R, ...
					'config', config, ...
					'channels', channels, ...
					'AcqDuration', 1000, ...
					'SweepPeriod', 1005, ...
					'TTLPulseDur', 1, ...
					'CircuitGain', 1000, ...		% gain for TDT circuit
					'MonitorGain', 1000, ...
					'HPEnable', 1, ...				% enable high pass filter
					'HPFreq', 100, ...				% high pass frequency
					'LPEnable', 1, ...				% enable low pass filter
					'LPFreq', 10000, ...				% low pass frequency
					'MonEnable', 0	);

animal.Animal = '000';
animal.Unit = '0';
animal.Rec = '0';
animal.Date = TytoLogy_datetime('date');
animal.Time = TytoLogy_datetime('time');
animal.Pen = '0';
animal.AP = '0';
animal.ML = '0';
animal.Depth = '0';
animal.comments = '';

TestScript = fullfile(pwd, 'defaultscript.m');
DefaultOutputDir = 'E:\Data\SJS';

H = struct(	'opto', opto, ...
				'noise', noise, ...
				'tone', tone, ...
				'wav', wav, ...
				'audio', audio, ...
				'caldata', caldata, ...
				'TDT', TDT, ...
				'animal', animal, ...
				'TestScript', TestScript, ...
				'DefaultOutputDir', DefaultOutputDir, ...
				'fH', [], ...
				'ax', []);
