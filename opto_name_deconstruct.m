function varargout = opto_name_deconstruct(datafile)
%------------------------------------------------------------------------
% optoproc
%------------------------------------------------------------------------
% TytoLogy:Experiments:OptoAnalysis
%---------------------------------------------------------------------
% get info from filename - this makes some assumptions about file
% name structure!
% <animal id #>_<date>_<penetration #>_<unit #>_<other info>.dat
%------------------------------------------------------------------------
%  Sharad Shanbhag
%   sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 29 April, 2019 (SJS), pulled code out of optoproc()
%
% Revisions:
%------------------------------------------------------------------------

% break up file name into <fname>.<ext> (~ means don't save ext info)
[~, fname] = fileparts(datafile);
% locate underscores in fname
usc = find(fname == '_');
% location of start and end underscore indices
%    abcde_edcba
%        ^ ^
%        | |
%        | ---- endusc index
%        ---startusc index
endusc = usc - 1;
startusc = usc + 1;
animal = fname(1:endusc(1));
datecode = fname(startusc(1):endusc(2));
penetration = fname(startusc(2):endusc(3)); 
unit = fname(startusc(3):endusc(4)); 
other = fname(startusc(end):end); 

outstruct = struct(	'fname', fname, ...
							'animal', animal, ...
							'datecode', datecode, ...
							'penetration', penetration, ...
							'unit', unit, ...
							'other', other	);
if nargout == 1
	varargout{1} = outstruct;
elseif nargout > length(fieldnames(outstruct))
	error('%s: requesting too many outputs', mfilename);
else
	outnames = fieldnames(outstruct);
	for n = 1:nargout
		varargout{n} = outstruct.(outnames{n}); %#ok<AGROW>
	end
end

