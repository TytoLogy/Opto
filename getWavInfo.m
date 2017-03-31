function wavinfo = getWavInfo(varargin)
%--------------------------------------------------------------------------
% [curvedata, rawdata] = noise_opto(handles, datafile)
%--------------------------------------------------------------------------
% TytoLogy:Experiments:opto Application
%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
% Input Arguments:
% 
% Output Arguments:
%
%--------------------------------------------------------------------------
% See Also: noise_opto, opto, opto_playCache
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Created:	31 March, 2017 (SJS)
%
% Revision History:
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% if file name was given as input
%--------------------------------------------------------------------------
% check if infofile name was provided
if nargin
	% if so, load wavinfo
	infofile = varargin{1}
	if exist(infofile, 'file')
		load(infofile, '-MAT', 'wavinfo');
		return
	else
		error('%s: could not load file %s', mfilename, infofile);
	end
else
	% otherwise, get info file name
	[filenm, pathnm] = uigetfile({'*.mat'; '*.*'}, ...
											'Load wav info file...');
	if filenm
		load(fullfile(pathnm, filenm), '-MAT', 'wavinfo');
		return
	else
		fprintf('%s: load wavinfo cancelled\n', mfilename);
		wavinfo = [];
		return
	end
end

