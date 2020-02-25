function printDinfTestInfo(Dinf)

DinfName = inputname(1);

fprintf('%s:\n', DinfName);
fprintf('\ttest.Type: %s\n', Dinf.test.Type);
fprintf('\ttest.Name: %s\n', Dinf.test.Name);
fprintf('\ttest.audio.signal.Type: %s\n', char(Dinf.audio.signal.Type));
if isfield(Dinf.test, 'stimcache')
	fprintf('\ttest.stimcache.stimtype: %s\n', char(Dinf.test.stimcache.stimtype));
	fprintf('\ttest.stimcache.curvetype: %s\n', char(Dinf.test.stimcache.curvetype));
	fprintf('\ttest.stimcache.vname: %s\n', char(Dinf.test.stimcache.vname));
end

% standalone script (e.g., 'WAV') things
if isfield(Dinf.test, 'ScriptType')
	fprintf('\ttest.ScriptType: %s\n', char(Dinf.test.ScriptType));
end
if isfield(Dinf.test, 'optovar_name')
	fprintf('\ttest.optovar_name: %s\n', char(Dinf.test.optovar_name));
end
if isfield(Dinf.test, 'audiovar_name')
	fprintf('\ttest.audiovar_name: %s\n', char(Dinf.test.audiovar_name));
end
if isfield(Dinf.test, 'curvetype')
	fprintf('\ttest.curvetype: %s\n', char(Dinf.test.curvetype));
end

fprintf('\n')

