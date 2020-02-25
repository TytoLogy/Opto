rawPath = '~/Work/Data/TestData/MT';

% 
%%
% S object file
Sfile = '~/Work/Data/TestData/MT/1382_20191212_02_02_3200_Sobj.mat';

% load data
load(Sfile)



%% create stimcache uaing FRA
% get Dinf struct

freqD = S.Info.FileData(1).Dinf;
bbnD = S.Info.FileData(2).Dinf;
fraD = S.Info.FileData(3).Dinf;

%% FRA: assign to test and tdt structs
test = fraD.test;
test.audio = fraD.audio;
test.opto = fraD.opto;
tdt.outdev = fraD.outdev;
test.audio.signal.Type = char(fraD.audio.signal.Type);

[stimcache, stimseq] = opto_buildStimCache(test, tdt, fraD.caldata);