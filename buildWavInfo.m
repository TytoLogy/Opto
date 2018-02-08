function [wavInfo, varargout] = buildWavInfo(varargin)
%--------------------------------------------------------------------------
% wavinfo = buildWavInfo(wavDir, wavInfoFile, RMSwin)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% creates wav stimulus file information data which can then be used for 
% wav stimulus playback by the opto program
%--------------------------------------------------------------------------
% Input Arguments:
% 		<no arguments>		buildWavInfo will ask for directory with .WAV
%						 		files, will write file wavInfo.mat in that
%						 		directory
%
% 		wavDir				path to directory with .WAV files
% 								if empty <''>, user will be prompted to provide
% 								directory
% 								
% 		wavInfoFile			path/name of wavInfoFile to create
% 								if empty <''> user will be prompted to provide
% 								filename
% 
% 		RMSwin				rms window size (milliseconds) for computing rms in
% 								PeakRMS. Default is 5 ms
% 								
% Output Arguments:
%		wavInfo				struct array with information about wavfiles
% 
%	Fields in struct wavInfo:
% 			Filename						name of file
% 			CompressionMethod			compressed?
% 			NumChannels					# of audio channels
% 			SampleRate					sampling rate
% 			TotalSamples				length of audio in samples
% 			Duration						duration of audio in seconds
% 			Title							metadata
% 			Comment						metadata
% 			Artist						metadata
% 			BitsPerSample				bit depth
% 			OnsetBin						sound onset sample
% 			OffsetBin					sound offset sample
% 			PeakRMS						max RMS value
% 			PeakRMSTime					max RMS value time
% 			PeakRMSWin					window size (ms) used to compute RMS
%--------------------------------------------------------------------------
% See Also: getWavInfo, opto
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Created:	4 April, 2017 (SJS)
%
% Revision History:
%	5 Apr 2017:	changed PeakRMSBin to PeakRMSTime, added PeakRMSWin to 
%					wavInfo struct
%	8 Feb 2018 (SJS): added comment
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

wavDir = ''; %#ok<NASGU>
wavInfoFile = '';
wavInfo = [];
rmswin = 5;
rmsThreshFactor = 0.02;

%--------------------------------------------------------------------------
% process inputs
%--------------------------------------------------------------------------
% Path, file given? check if path name was provided
if nargin
	% if so, use that directory
	wavDir = varargin{1};
	if ~isempty(wavDir)
		if ~exist(wavDir, 'dir')
			error('%s: could not find directory %s', mfilename, wavDir);
		end
	end
	if nargin >= 2
		wavInfoFile = varargin{2};
		if ~isempty(wavInfoFile)
			if exist(wavInfoFile, 'file')
				warning('%s: wav info file %s exists!', mfilename, wavInfoFile);
				butt = questdlg(	'Overwrite existing wav info file?', ...
										'Wav Info Exists!', ...
										'Yes', 'No', 'Cancel', ...
										struct('Default', 'No', 'Interpreter', 'none'));
				if strcmpi(butt, 'No')
					wavInfoFile = '';
				elseif strcmpi(butt, 'Cancel')
					return
				end
			end
		end
	end
	if nargin == 5
		rmswin = varargin{3};
	end
else
	% otherwise, get directory name
	wavDir = uigetdir('', 'Select directory with .WAV files...');
	if ~wavDir
		fprintf('%s: cancelled\n', mfilename);
		return
	end
end

% get wavInfoFile name if needed
if isempty(wavInfoFile)
	[filenm, pathnm] = uiputfile('*.mat', ...
											'Save wavInfo in file', ...
											fullfile(wavDir, 'wavinfo.mat'));
	if filenm
		wavInfoFile = fullfile(pathnm, filenm);
	else
		fprintf('%s: no output file specified\n', mfilename);
		wavInfoFile = '';
	end
end

% find wav files in wavDir directory
wavFiles = dir([wavDir filesep '*.wav']);
nFiles = length(wavFiles);
if isempty(wavFiles)
	error('%s: no .WAV files in %s!', mfilename, wavDir);
else
	fprintf('%s: found %d .WAV files in %s\n', mfilename, nFiles, wavDir);
end

%--------------------------------------------------------------------------
% process files
%--------------------------------------------------------------------------

% preallocate wavInfo
wavInfo = repmat(	struct(	'Filename',					'', ...
									'CompressionMethod',		'', ...
									'NumChannels',				[], ...
									'SampleRate',				[], ...
									'TotalSamples',			[], ...
									'Duration',					[], ...
									'Title',						[], ...
									'Comment',					[], ...
									'Artist',					[], ...
									'BitsPerSample',			[], ...
									'OnsetBin',					[], ...
									'OffsetBin',				[], ...
									'PeakRMS',					[], ...
									'PeakRMSTime',				[], ...
									'PeakRMSWin',				rmswin ...
								), nFiles, 1);
% loop through files
for f = 1:nFiles
	% get info about wav file
	wname = fullfile(wavDir, wavFiles(f).name);
	tmp = audioinfo(wname);
	fprintf('Processing file %s\n', wname);
	tmp.OnsetBin = 1;
	tmp.OffsetBin = tmp.TotalSamples;
	% read in wav data
	wav = audioread(wname);
	% compute rms of signal in blocks, then find max value and location bin
	wavrms = block_rms(wav, ms2bin(rmswin, tmp.SampleRate));
	[tmp.PeakRMS, PeakRMSBin] = max(wavrms);
	tmp.PeakRMSTime = PeakRMSBin * rmswin;
	tmp.PeakRMSWin = rmswin;
	onoff = findWavOnsetOffset(wav, tmp.SampleRate, ...
															'UserConfirm', ...
															'WAVName', wavFiles(f).name, ...
															'Threshold', rmsThreshFactor, ...
															'Method', 'rms');
	tmp.OnsetBin = onoff(1);
	tmp.OffsetBin = onoff(2);
	wavInfo(f) = tmp;
end

%--------------------------------------------------------------------------
% Save wavInfo to wavInfoFile
%--------------------------------------------------------------------------
if ~isempty(wavInfoFile)
	fprintf('Writing wavInfo struct to %s\n', wavInfoFile);
	save(wavInfoFile, 'wavInfo', '-MAT');
end

if nargout == 2
	varargout{1} = wavInfoFile;
end



