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
% save cancel flag status in curvedata
curvedata.cancelFlag = cancelFlag;
curvedata.PSTH = PSTH;
curvedata.SpikeTimes = SpikeTimes;

% save figure
figfilename = fullfile(fpath, get(pstHandle, 'Filename'));
savefig(pstHandle, figfilename);


outdata{1} = curvedata;
outdata{2} = resp;
outdata{3} = handles;