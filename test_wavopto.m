handles.H = opto_InitH;

try
	[outhandles, ~] = opto_TDTopen(	handles.H.TDT.config, ...
												handles.H.TDT.indev, ...
												handles.H.TDT.outdev);
catch ME
	disp(ME.identifier)
	disp(ME.message)
	error('Cannot open TDT hardware');
end
handles.H.TDT.indev = outhandles.indev;
handles.H.TDT.outdev = outhandles.outdev;
handles.H.TDT.zBUS = outhandles.zBUS;
handles.H.TDT.PA5L = outhandles.PA5L;
handles.H.TDT.PA5R = outhandles.PA5R;


Fs = opto_TDTsettings(	handles.H.TDT.indev, ...
								handles.H.TDT.outdev, ...
								handles.H.TDT, ...
								handles.H.audio, ...
								handles.H.TDT.channels, ...
								handles.H.opto);		

handles.H.TDT.indev.Fs = Fs(1);
handles.H.TDT.outdev.Fs = Fs(2);
handles.H.TDT.Enable = 1;

[cdata, rdata] = wav_opto(handles, 'tmpwavopto.dat');


% turn off audio monitor for spikes using software trigger 2
RPtrig(handles.H.TDT.indev, 2);
% stop TDT hardware
[outhandles, ~] = opto_TDTclose(	handles.H.TDT.config, ...
											handles.H.TDT.indev, ... 
											handles.H.TDT.outdev, ...
											handles.H.TDT.zBUS, ...
											handles.H.TDT.PA5L, ...
											handles.H.TDT.PA5R);
handles.H.TDT.indev = outhandles.indev;
handles.H.TDT.outdev = outhandles.outdev;
handles.H.TDT.zBUS = outhandles.zBUS;
handles.H.TDT.PA5L = outhandles.PA5L;
handles.H.TDT.PA5R = outhandles.PA5R;
handles.H.TDT.Enable = 0;
