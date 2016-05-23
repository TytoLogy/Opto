test.Type = 'RATE-LEVEL';

test.Animal = '000';
test.Unit = '01';
test.Rec = '01';
test.Date = TytoLogy_datetime('date_compact');
test.Time = TytoLogy_datetime('time');
test.Pen = '01';
test.AP = '0';
test.ML = '0';
test.Depth = '0000';
test.comments = '';

test.Reps = 10;

% optical settings
test.opto.Enable = 0;
test.opto.Delay = 0;
test.opto.Dur = 100;
test.opto.Amp = 50;
test.opto.Channel = 10;

% Stimulus settings

% signal
test.audio.signal.Type = 'noise';
test.audio.signal.Fmin = 4000;
test.audio.signal.Fmax = 80000;
test.audio.Delay = 100;
test.audio.Duration = 200;
test.audio.Level = 0:10:60;
test.audio.Ramp = 1;
test.audio.Frozen = 0;
test.audio.ISI = 100;

test.audio.RandomOrder = 0;

% TDT
test.TDT.AcqDuration = 1000;
test.TDT.AcqDuration.SweepPeriod = 1001;

% create filename from animal info
%	animal # _ date _ unit _ Penetration # _ Depth _ type .dat
defaultfile = sprintf('%s_%s_%s_%s_%s_%s.dat', ...
								test.Animal, ...
								test.Date, ...
								test.Unit, ...
								test.Pen, ...
								test.Depth, ...
								test.Type);

[datafile, datapath] = uiputfile('*.dat', 'Save Data', defaultfile);

if datafile == 0
	return
end


if test.audio.RandomOrder = 1
	


