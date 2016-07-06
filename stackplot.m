function h = stackplot(t, X,  varargin)


% set up plot
h = figure;
ax = axes;

[npts, nchan] = size(X);
yabsmax = max(max(abs(X)));

tmpData = zeros(npts, nchan);
for n = 1:nchan
	tmpData(:, n) = n*(yabsmax) + 2*(2*rand(npts, 1)-1);
end
pH = plot(ax, t, tmpData);

yticks_yvals = yabsmax*(1:nchan);
yticks_txt = cell(nchan, 1);
for n = 1:nchan
	yticks_txt{n} = num2str(n);
end

ylim(yabsmax*[0 nchan+1]);

set(ax, 'YTick', yticks_yvals);
set(ax, 'YTickLabel', yticks_txt);
set(ax, 'TickDir', 'out');
set(ax, 'Box', 'off');

% set(ax, 'Color', 0.75*[1 1 1]);
% set(h, 'Color', 0.75*[1 1 1]);
set(h, 'ToolBar', 'none');

for c = 1:nchan
	tmpY = X(:, c) + c*yabsmax;
	set(pH(c), 'YData', tmpY, 'Color', 0 * [1 1 1]);
end