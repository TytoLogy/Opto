function wavInfo = getWavInfo(varargin)
%--------------------------------------------------------------------------
% wavInfo = getWavInfo(filename)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
% Loads wav stimulus file information from specified .mat file, returns
% data in wavInfo struct
%
% These data can then be used for playback by the opto program
%--------------------------------------------------------------------------
% Input Arguments:
%	filename		name of mat file with wavInfo struct
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
% See Also: getWavInfo, noise_opto, opto, opto_playCache
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Created:	31 March, 2017 (SJS)
%
% Revision History:
%	8 Feb 2018 (SJS): added comment
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Load info file?
%--------------------------------------------------------------------------
% check if infofile name was provided
if nargin
	% if so, load wavinfo
	infofile = varargin{1};
	if exist(infofile, 'file')
		load(infofile, '-MAT', 'wavInfo');
		return
	else
		error('%s: could not load file %s', mfilename, infofile);
	end
else
	% otherwise, get info file name
	[filenm, pathnm] = uigetfile({'*.mat'; '*.*'}, ...
											'Load wav info file...');
	if filenm
		load(fullfile(pathnm, filenm), '-MAT', 'wavInfo');
		return
	else
		fprintf('%s: load wavinfo cancelled\n', mfilename);
		wavInfo = [];
		return
	end
end


