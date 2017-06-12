function optomsg(handles, msgStr, varargin)
%--------------------------------------------------------------------------
% optomsg(handles, msgStr, 'echo', <on/off>)
%--------------------------------------------------------------------------
% opto program
%--------------------------------------------------------------------------
% 
% utility function used by opto programs to display info to user via GUI
% 
%--------------------------------------------------------------------------
% Input Arguments:
%		handles		handles struct from opto
%		msgStr		text to display
%		
%	Optional:
%		'echo'	<on|off>		toggles echoing of msgStr to command line
% 									By default, msgStr will be shown 
% 									on the command line
% 									To turn off, provide 'echo' with the option 
% 									'off'
%--------------------------------------------------------------------------
% See Also: writeStimData, fopen, fwrite, BinaryFileToolbox, opto
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%--------------------------------------------------------------------------
% Revision History
%	5 May 2017 (SJS): file created
%	17 May 2017 (SJS): added 'echo' option, added documentation
%--------------------------------------------------------------------------

ECHO_FLAG = true;

update_ui_str(handles.textMsg, msgStr);

if nargin == 4
	ECHO_FLAG = ~(strcmpi(varargin{1}, 'echo') && ...
							strcmpi(varargin{2}, 'off'));
end

if ECHO_FLAG
	fprintf('%s\n', msgStr);
end
	