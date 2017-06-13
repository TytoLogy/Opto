f = figure(20)

a(1) = subplot(211)
a(2) = subplot(212)

tbase = 0:20:900;
stimes{1} = {tbase, tbase+2, tbase+5};
stimes{2} = {tbase+20, tbase+25, tbase + 40, tbase + 60, tbase - 100};

[hvals{1}, bins] = psth(stimes{1}, 10, [0 1000]);
hvals{2} = psth(stimes{2}, 10, [0 1000]);

for n = 1:2
	bar(a(n), bins, hvals{n});
	xlim(a(n), [0 1000]);
	axis(a(n), 'auto y');
end