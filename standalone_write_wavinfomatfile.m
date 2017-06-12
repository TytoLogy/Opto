%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Write wav information to mat file
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% create mat filename
[fpath, fname] = fileparts(datafile);
matfile = fullfile(fpath, [fname '_wavinfo.mat']);
save(matfile, 'audio', 'noise', 'null', ...
					'stimList', 'stimIndices', 'repList', 'wavInfo', ...
					'wavS0', '-MAT');