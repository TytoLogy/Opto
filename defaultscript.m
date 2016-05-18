test.Type = 'RATE_LEVEL';

test.Animal = '000';
test.Unit = '0';
test.Rec = '0';
test.Date = TytoLogy_datetime('date');
test.Time = TytoLogy_datetime('time');
test.Pen = '0';
test.AP = '0';
test.ML = '0';
test.Depth = '0';
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

% timing
test.audio.Delay = 100;
test.audio.Duration = 200;
test.audio.Level = 0:10:60;
test.audio.Ramp = 1
test.audio.Frozen = 0
test.audio.ISI = 100

% TDT
test.TDT.AcqDuration = 1000;
test.TDT.AcqDuration.SweepPeriod = 1000;

