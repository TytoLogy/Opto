%--------------------------------------------------------
%--------------------------------------------------------
% clean up
%--------------------------------------------------------
%--------------------------------------------------------
% close curve panel
close(PanelHandle)
% turn off monitor using software trigger 2 sent to indev
RPtrig(indev, 2);

%--------------------------------------------------------
%--------------------------------------------------------
% setup output data structure
%--------------------------------------------------------
%--------------------------------------------------------
if ~cancelFlag
% 	curvedata.depvars = depvars;
% 	curvedata.depvars_sort = depvars_sort;
% 	if stimcache.saveStim
% 		[pathstr, fbase] = fileparts(datafile);
% 		curvedata.stimfile = fullfile(pathstr, [fbase '_stim.mat']);
% 	end
end
% save cancel flag status in curvedata
curvedata.cancelFlag = cancelFlag;
curvedata.PSTH = PSTH;
curvedata.SpikeTimes = SpikeTimes;

outdata{1} = curvedata;
outdata{2} = resp;
outdata{3} = handles;