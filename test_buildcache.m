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

%% freq tuning: assign to test and tdt structs
test = freqD.test;
test.audio = freqD.audio;
test.opto = freqD.opto;
tdt.outdev = freqD.outdev;
test.audio.signal.Type = char(freqD.audio.signal.Type);
% old function
[freqD.stimcache_orig, freqD.stimseq_orig] = opto_buildStimCache_orig(test, tdt, freqD.caldata);
fprintf('OLD: FREQ\n');
freqD.stimcache_orig
% new
[freqD.stimcache, freqD.stimseq] = opto_buildStimCache(test, tdt, freqD.caldata);
fprintf('NEW: FREQ\n');
freqD.stimcache

%% noise level tuning: assign to test and tdt structs
test = bbnD.test;
test.audio = bbnD.audio;
test.opto = bbnD.opto;
tdt.outdev = bbnD.outdev;
test.audio.signal.Type = char(bbnD.audio.signal.Type);
% old function
[bbnD.stimcache_orig, bbnD.stimseq_orig] = opto_buildStimCache_orig(test, tdt, bbnD.caldata);
fprintf('OLD: BBN\n');
bbnD.stimcache_orig
% new
[bbnD.stimcache, bbnD.stimseq] = opto_buildStimCache(test, tdt, bbnD.caldata);
fprintf('NEW: BBN\n');
bbnD.stimcache


%% FRA: assign to test and tdt structs
test = fraD.test;
test.audio = fraD.audio;
test.opto = fraD.opto;
tdt.outdev = fraD.outdev;
test.audio.signal.Type = char(fraD.audio.signal.Type);
% old function
[fraD.stimcache_orig, fraD.stimcache_orig] = opto_buildStimCache_orig(test, tdt, fraD.caldata);
fprintf('OLD: FRA\n');
fraD.stimcache_orig
% new
[fraD.stimcache, fraD.stimseq] = opto_buildStimCache(test, tdt, fraD.caldata);
fprintf('NEW: FRA\n');
fraD.stimcache


