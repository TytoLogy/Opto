function [wavInfo, varargout] = buildWavInfo(varargin)
%--------------------------------------------------------------------------
% wavinfo = buildWavInfo(wavDir, wavInfoFile)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
% Input Arguments:
% 		<no arguments>		buildWavInfo will ask for directory with .WAV
%						 		files, will write file wavInfo.mat in that
%						 		directory
%
% 		wavDir				path to directory with .WAV files
% 		wavInfoFile			path/name of wavInfoFile to create
%
% Output Arguments:
%		wavInfo				struct array with information about wavfiles		
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
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

wavDir = ''; %#ok<NASGU>
wavInfoFile = '';
wavInfo = [];

%--------------------------------------------------------------------------
% process inputs
%--------------------------------------------------------------------------
% Path, file given? check if path name was provided
if nargin
	% if so, use that directory
	wavDir = varargin{1};
	if ~exist(wavDir, 'dir')
		error('%s: could not find directory %s', mfilename, wavDir);
	end
	if nargin == 2
		wavInfoFile = varargin{2};
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
		fprintf('%s: cancelled\n', mfilename);
		return
	end
end


wavFiles = dir([wavDir filesep '*.wav']);
if isempty(wavFiles)
	error('%s: no .WAV files in %s!', mfilename, wavDir);
end

%--------------------------------------------------------------------------
% process files
%--------------------------------------------------------------------------
nFiles = length(wavFiles);
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
									'OffsetBin',				[] ...
								), nFiles, 1);
% loop through files
for f = 1:nFiles
	% get info about wav file
	wname = fullfile(wavDir, wavFiles(f).name);
	tmp = audioinfo(wname);
	fprintf('Processing file %s\n', wname);
	tmp.OnsetBin = 1;
	tmp.OffsetBin = tmp.TotalSamples;
	
	wav = audioread(wname);
	
	findWavOnsetOffset
	
	pause
	
	wavInfo(f) = tmp;
	
end


%--------------------------------------------------------------------------
% Save wavInfo to wavInfoFile
%--------------------------------------------------------------------------
fprintf('Writing wavInfo struct to %s\n', wavInfoFile);
save(wavInfoFile, 'wavInfo', '-MAT');

if nargout == 2
	varargout{1} = wavInfoFile;
end



