load('spikedat.mat')

[pdata, ~] = mcFastDeMux(monresp, incchannels);
ch8data = pdata(:, 8)';

figure(99)
subplot(211)
plot(ch8data);

subplot(212)
plot(spikes);

spikerms
nspikes
spikebins = spikes(1 + (0:sniplen:(length(spikes)-1)));
if length(spikebins) ~= nspikes
	warning('Spikebin mismatch!!!!')
end
subplot(211)
for s = 1:nspikes
	text(spikebins(s), ch8data(spikebins(s)), '*', 'Color', 'g');
end

snips = cell(nspikes, 1);
snips_orig = cell(nspikes, 1);
for s = 1:nspikes
	startbin = spikebins(s);
	endbin = startbin + (sniplen - 1);
	snips{s} = ch8data(startbin:endbin);
end

figure
plot(cell2mat(snips)')