rawPath = '~/Work/Data/TestData/MT';

rawFiles = {	'1382_20191212_02_02_3200_FREQ_TUNING.dat', ...
					'1382_20191212_02_02_3200_BBN.dat', ...
					'1382_20191212_02_02_3200_FRA.dat', ...
					'1382_20191212_02_02_3200_WAV.dat'	};

% 
%% read in data info from files
freqD = readOptoDataInfo(fullfile(rawPath, rawFiles{1}));
bbnD = readOptoDataInfo(fullfile(rawPath, rawFiles{2}));
fraD = readOptoDataInfo(fullfile(rawPath, rawFiles{3}));
wavD = readOptoDataInfo(fullfile(rawPath, rawFiles{4}));


%% display info

printDinfTestInfo(freqD);
printDinfTestInfo(bbnD);
printDinfTestInfo(fraD);
printDinfTestInfo(wavD);

%% FRA: assign to test and tdt structs
test = freqD.test;
test.audio = freqD.audio;
test.opto = freqD.opto;
tdt.outdev = freqD.outdev;
test.audio.signal.Type = char(freqD.audio.signal.Type);

[sco, sqo] = opto_buildStimCache_orig(test, tdt, freqD.caldata);
fprintf('OLD: FREQ\n');
sco

%% new
[sc, sq] = opto_buildStimCache(test, tdt, freqD.caldata);
fprintf('NEW: FREQ\n');
sc

%% FRA: assign to test and tdt structs
test = fraD.test;
test.audio = fraD.audio;
test.opto = fraD.opto;
tdt.outdev = fraD.outdev;
test.audio.signal.Type = char(fraD.audio.signal.Type);

[sco, sqo] = opto_buildStimCache_orig(test, tdt, fraD.caldata);
fprintf('OLD: FRA\n');
sco
%% new
[sc, sq] = opto_buildStimCache(test, tdt, fraD.caldata);
fprintf('NEW: FRA\n');
sc