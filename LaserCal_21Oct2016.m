
% Light Source:
% Shanghai dream laser calibration
% laser: SDL-532-150MFL
% 532 nm, 1-10000 mW
% 
% Thor labs PM100 calibrator with S140C sensor
% 
% fiber is cleaved Thor CFML12U-20 cannula, placed at level equal to base
% on the S140C sensor

% data:
% 	column 1: "Power Set Dial" (dial on power supply)
% 	column 2: Electric Current (display on power supply)
% 	column 3: max power, in uW, measured by Thor labs PM100 calibrator with
% 	          S140C sensor
data = [	0	0.000	0.001; ...
			50	0.514	20.97; ...
			100	0.724	430.7; ...
			150	0.845	3958; ...
			200	0.938	5789; ...
			250	1.014	7620; ...
		];
	
% LINEAR SCALE
figure(1)
% plot dial setting vs. power
subplot(211)
plot(data(:, 1), data(:, 3), '*-');
title({'Laser SDL-532-150MFL', 'Output Power vs. Power Set'});
xlabel('Power Set (arbitrary units)')
ylabel('Output Power (uW)')
grid on
% plot current vs. power
subplot(212)
plot(data(:, 2), data(:, 3), '*-');
title({'Output Power vs. Electric Current'});
xlabel('Electric Current (A)')
ylabel('Output Power (uW)')
grid on

% SEMILOGY SCALE
figure(2)
% plot dial setting vs. power
subplot(211)
semilogy(data(:, 1), data(:, 3), '*-');
title({'Laser SDL-532-150MFL', 'Output Power vs. Power Set'});
xlabel('Power Set (arbitrary units)')
ylabel('Output Power (uW)')
grid on
% plot current vs. power
subplot(212)
semilogy(data(:, 2), data(:, 3), '*-');
title({'Output Power vs. Electric Current'});
xlabel('Electric Current (A)')
ylabel('Output Power (uW)')
grid on
