%-------------------------------------------------------------------------
% Standalone script
%-------------------------------------------------------------------------
% indicate that this is a standalone script
test.Type = 'STANDALONE';
test.Function = @OptoInhib;

%------------------------------------
% OPTICAL settings
%	Enable	0 -> optical stim OFF, 1 -> optical stim ON
%	Delay		onset of optical stim from start of sweep (ms)
% 	Dur		duration (ms) of optical stimulus
% 	Amp		amplitude (mV) of optical stim
% 					*** IMPORTANT NOTE ***
% 					This method of amplitude control will only work with the 
% 					Thor Labs fiber-coupled LED driver.
% 					For the Shanghai Dream Laser, output level can only be 
% 					controlled using the rotary potentiometer on the Laser power
% 					supply. If using the Shanghai Dream Laser for stimulation,
% 					set Amp to 5000 millivolts (5 V)
% 
% 	To test a range of values (for Delay, Dur, Amp), use a vector of values
% 	instead of a single number (e.g., [20 40 60] or 20:20:60)
%------------------------------------
% test.opto.Enable = 1;
% test.opto.Delay = 100;
% test.opto.Dur = 200;
% test.opto.Amp = 2000;
test.opto.Enable = 0;
test.opto.Delay = 300;
test.opto.Dur = 100;
test.opto.Amp = 2000;
% set test Name based on opto Enable setting
if test.opto.Enable == 1
	test.Name = 'OptoInhibON';
else
	test.Name = 'OptoInhibOFF';
end

test.OlfStim = 0;
if test.OlfStim
	test.OlfSTimType = 'CatFur';
else
	test.OlfStimType = '';
end
