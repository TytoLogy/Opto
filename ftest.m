Fs = 4.8828e+04;

s = synmononoise_fft(500, Fs, 200, 10000, 1, 0);


% build bandstop1 filter, store coefficients in filtB, filtA
% f1.band = [90 1000] ./ (0.5 * Fs);
% fband = [1500 3000] ./ (0.5 * Fs);
% [f1.B, f1.A] = butter(1, f1.band, 'stop');
bsFilt = designfilt('bandstopiir', 'FilterOrder',10, ...
         'HalfPowerFrequency1',400,'HalfPowerFrequency2',440, ...
         'SampleRate',Fs);

sfilt = filter(bsFilt, s);

fftplot(sfilt, Fs);