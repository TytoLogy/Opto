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

%% FRA: assign to test and tdt structs
test = fraD.test;
test.audio = fraD.audio;
test.opto = fraD.opto;
tdt.outdev = fraD.outdev;
test.audio.signal.Type = char(fraD.audio.signal.Type);

[stimcache, stimseq] = opto_buildStimCache(test, tdt, fraD.caldata);