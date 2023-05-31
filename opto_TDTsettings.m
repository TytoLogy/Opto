function Fs = opto_TDTsettings(indev, outdev, ...
												tdt, stimulus, channels, optical)
%------------------------------------------------------------------------
% Fs = opto_TDTsettings(indev, outdev, tdt, stimulus, channels, optical)
%------------------------------------------------------------------------
% Opto program
%------------------------------------------------------------------------
% Sets up TDT settings for Opto using 
% 	RZ52 (via PZ2) for spike input 
% 			- and -
% 	RZ6 for stimulus output
% 
%------------------------------------------------------------------------
% designed to use with RPVD circuits: 
%		RZ5D_50k_16In_1Out_zBus.rcx
% 		RZ6_2Processor_SpeakerOutput_zBus.rcx
%------------------------------------------------------------------------
% Input Arguments:
% 	indev       TDT device interface structure
% 	outdev      TDT device interface structure (not used)
% 	tdt         TDT setting parameter structure
% 	stimulus    stimulus parameters structure
% 	channels    I/O channels parameters structure
%	optical		optical stimulus settings
%
% Output Arguments:
%	Fs         [1X2] sampling rates for input (1) and output (2)
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
%	12 Jun 2017 (SJS): added spike detection settings
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
% Gain Settings
%------------------------------------------------------------------------
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
% turn on monitor if enabled
if tdt.MonEnable
	% turn on audio monitor for spikes using software trigger 1
	RPtrig(indev, 1);
else
	% turn off audio monitor using software trigger 2
	RPtrig(indev, 2);
end

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

%------------------------------------------------------------------------
% Spike Detection
%------------------------------------------------------------------------
% low spike threshold in std. dev
RPsettag(indev, 'TLo', tdt.TLo);
% hi spike threshold in s.d.
RPsettag(indev, 'THi', tdt.THi);
