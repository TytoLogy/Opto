function Fs = FOCHS_RZ6RZ5Dsettings(indev, outdev, ...
												tdt, stimulus, channels, optical)
%------------------------------------------------------------------------
% Fs = FOCHS_RZ6RZ5Dsettings(indev, outdev, tdt, stimulus, channels, optical)
%------------------------------------------------------------------------
% FOCHS program
%------------------------------------------------------------------------
% Sets up TDT settings for HPSearch using 
% 	RZ52 (via PZ2) for spike input 
% 			- and -
% 	RZ6 for stimulus output
% 
%------------------------------------------------------------------------
% designed to use with RPVD circuits: 
%		RZ5D_50k_FourChannelInput_zBus.rcx
% 		RZ6_2Processor_SpeakerOutput_zBus.rcx
%------------------------------------------------------------------------
% Input Arguments:
%   indev       TDT device interface structure
%   outdev      TDT device interface structure (not used)
%   tdt         TDT setting parameter structure
%   stimulus    stimulus parameters structure
%   channels    I/O channels parameters structure 
% Output Arguments:
%    Fs         [1X2] sampling rates for input (1) and output (2)
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Go Ashida & Sharad Shanbhag 
% ashida@umd.edu
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Original Version (HPSearch_RX8iosettings): 2009-2011 by SJS
% Upgraded Version (HPSearch2_RX8settings): 2011-2012 by GA
% Four-channel Input Version (FOCHS_RX8settings): 2012 by GA  
% Optogen Version (FOCHS_RZ6RZ5Dsettings): 2016 by SJS  
%------------------------------------------------------------------------
% Revisions
%	3 May 2016 (SJS):
% 	 - added "optical"| input structure
% 	 - modified code to set tags in RZ5D
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% query the sample rate from the circuit - do this instead of using the
% stored Fs within indev and outdev in order to ensure accuracy!
%------------------------------------------------------------------------
inFs = RPsamplefreq(indev);
outFs = RPsamplefreq(outdev); 
Fs = [inFs outFs];

%------------------------------------------------------------------------
% STIMULUS and Acquisition (timing)
%------------------------------------------------------------------------
% Set the Stimulus Delay
RPsettag(outdev, 'StimDelay', ms2bin(stimulus.Delay, outFs));
% Set the Stimulus Duration
RPsettag(outdev, 'StimDur', ms2bin(stimulus.Duration, outFs));
% Set the length of time to acquire data
RPsettag(indev, 'AcqDur', ms2bin(tdt.AcqDuration, inFs));
% Set the total sweep period time - input
RPsettag(indev, 'SwPeriod', ms2bin(tdt.SweepPeriod, inFs));
% Set the total sweep period time - output
RPsettag(outdev, 'SwPeriod', ms2bin(tdt.SweepPeriod, outFs));
% set the TTL pulse duration
RPsettag(indev, 'TTLPulseDur', ms2bin(tdt.TTLPulseDur, inFs));
% set the TTL pulse duration
RPsettag(outdev, 'TTLPulseDur', ms2bin(tdt.TTLPulseDur, outFs));
% Set the sweep count to 1
RPsettag(indev, 'SwCount', 1);
RPsettag(outdev, 'SwCount', 1);

%------------------------------------------------------------------------
% Input Filtering
%------------------------------------------------------------------------
% set the high pass filter
RPsettag(indev, 'HPFreq', tdt.HPFreq);
% set the low pass filter
RPsettag(indev, 'LPFreq', tdt.LPFreq);

%------------------------------------------------------------------------
% Input Channel and Gain Settings
%------------------------------------------------------------------------
% set input channels 
RPsettag(indev, 'inChannelA', channels.InputChannel1); 
RPsettag(indev, 'inChannelB', channels.InputChannel2); 
RPsettag(indev, 'inChannelC', channels.InputChannel3); 
RPsettag(indev, 'inChannelD', channels.InputChannel4);
% set the overall gain for input
RPsettag(indev, 'Gain', tdt.CircuitGain);

%------------------------------------------------------------------------
% Audio monitor
%------------------------------------------------------------------------
% set electrode channel to monitor via audio output
RPsettag(indev, 'MonChan', channels.MonitorChannel);
% set monitor gain
RPsettag(indev, 'MonGain', tdt.MonitorGain);
% set output channel for audio monitor (channel 9 on RZ5D 
% is dedicated to the built-in audio speaker/monitor)
RPsettag(indev, 'MonOutChan', channels.MonitorOutputChannel);

%------------------------------------------------------------------------
% OPTICAL settings
%	Important:
% 		Optical output is triggered using a DAC channel (default it 9) output
% 		on the RZ5D (thus, using the indev device!). This is due to the
% 		limitations of only 2 analog outputs on the RZ6 and because the Thor
% 		Labs LED stimulator controls the amplitude of LED output using an
% 		analog voltage. The Laser diode amplitude is controlled by a dial on
% 		the laser power supply box and is triggered using a TTL pulse.
% 		However, using an analog signal allows a simpler configuration (don't
% 		need to use digital outputs).
%------------------------------------------------------------------------
% enable/disable optical output
RPsettag(indev, 'OptoEnable', optical.Enable);
% set the optical amplitude (convert to volts)
RPsettag(indev, 'OptoAmp', 0.001*optical.Amp);
% set the optical duration (convert to samples)
RPsettag(indev, 'OptoDur', ms2bin(optical.Dur, inFs));
% set the optical delay (convert to samples)
RPsettag(indev, 'OptoDelay', ms2bin(optical.Delay, inFs));
% set the optical output channel
RPsettag(indev, 'OptoChan', optical.Channel);

%------------------------------------------------------------------------
% attenuation
%------------------------------------------------------------------------
RPsettag(outdev, 'AttenL', 90);
RPsettag(outdev, 'AttenR', 90);
RPsettag(outdev, 'Mute', 0);

