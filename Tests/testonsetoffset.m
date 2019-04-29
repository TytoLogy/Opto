wavdir = '/Users/sshanbhag/Work/Code/Matlab/dev/TytoLogy/Experiments/Calls/MT';
wavfile = 'chevron_adj.wav';

wavinfo = audioinfo(fullfile(wavdir, wavfile));
wav = audioread(fullfile(wavdir, wavfile));

[a, b] = findWavOnsetOffset(wav, wavinfo.SampleRate, 'UserConfirm')
