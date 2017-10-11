function spikebins = getSpikebinsFromSpikes(spikes, sniplen)

if isempty(spikes)
	spikebins = [];
else
	spikebins = spikes(1 + (0:sniplen:(length(spikes)-1)));
end