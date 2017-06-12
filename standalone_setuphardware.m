%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%  setup hardware
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%--------------------------------------------------------
% STIMULUS and Acquisition (timing)
%--------------------------------------------------------
% query the sample rate from the circuit - do this instead of using the
% stored Fs within indev and outdev in order to ensure accuracy!
inFs = RPsamplefreq(indev);
outFs = RPsamplefreq(outdev);
% Set the Stimulus Delay (might be adjusted for each wav file in loop)
RPsettag(outdev, 'StimDelay', ms2bin(audio.Delay, outFs));
% Set the Stimulus Duration
RPsettag(outdev, 'StimDur', ms2bin(audio.Duration, outFs));
% Set the length of time to acquire data
RPsettag(indev, 'AcqDur', ms2bin(test.AcqDuration, inFs));
% Set the total sweep period time - input
RPsettag(indev, 'SwPeriod', ms2bin(test.SweepPeriod, inFs));
% Set the total sweep period time - output
RPsettag(outdev, 'SwPeriod', ms2bin(test.SweepPeriod, outFs));
% Set the sweep count to 1
RPsettag(indev, 'SwCount', 1);
RPsettag(outdev, 'SwCount', 1);
%--------------------------------------------------------
% Input Filtering
%--------------------------------------------------------
% set the high pass filter
RPsettag(indev, 'HPFreq', handles.H.TDT.HPFreq);
% set the low pass filter
RPsettag(indev, 'LPFreq', handles.H.TDT.LPFreq);
%--------------------------------------------------------
% Gain Settings
%--------------------------------------------------------
% set the overall gain for input
RPsettag(indev, 'Gain', handles.H.TDT.CircuitGain);
%--------------------------------------------------------
% Audio monitor
%--------------------------------------------------------
% set electrode channel to monitor via audio output
RPsettag(indev, 'MonChan', channels.MonitorChannel);
% set monitor gain
RPsettag(indev, 'MonGain', handles.H.TDT.MonitorGain);
% set output channel for audio monitor (channel 9 on RZ5D 
% is dedicated to the built-in audio speaker/monitor)
RPsettag(indev, 'MonOutChan', channels.MonitorOutputChannel);
% turn on audio monitor for spikes using software trigger 1
RPtrig(indev, 1);
%--------------------------------------------------------
% attenuation - set to MAX_ATTEN, un-mute
%--------------------------------------------------------
RPsettag(outdev, 'AttenL', MAX_ATTEN);
RPsettag(outdev, 'AttenR', MAX_ATTEN);
RPsettag(outdev, 'Mute', 0);