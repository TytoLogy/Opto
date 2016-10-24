function varargout = stackplot(x, Y, varargin)


% set up plot
if isempty(varargin)
	hF = figure;
	hAx = axes;
	hL = [];
	mode = 'NEW';
	colormode = 'DEFAULT';
	yabsshift = 0;
	
else
	hF = [];
	hAx = [];
	hL = [];
	mode = 'NEW';
	colormode = 'DEFAULT';
	yabsshift = 0;
	
	j = 1;
	while j <= length(varargin)
		switch upper(varargin{j})
			case 'FIGURE'
				hF = varargin{j+1};
				j = j + 2;
			case 'AXES'
				hAx = varargin{j+1};
				j = j + 2;
			case 'LINES'
				hL = varargin{j+1};
				j = j + 2;
			case 'MODE'
				mode = upper(varargin{j+1});
				j = j + 2;
			case 'COLORMODE'
				colormode = upper(varargin{j+1});
				if strcmpi(colormode, 'CUSTOM')
					lcolors = varargin{j+2};
					j = j + 3;
				else
					j = j + 2;
				end
			case 'YABSSHIFT'
				yabsshift = varargin{j+1};
				j = j + 2;
			otherwise
				error('%s: unknown setting %s', mfilename, varargin{j});
		end
	end
	
	if isempty(hF)
		hF = figure;
	end
	if isempty(hAx)
		hAx = axes;
	end
end

% scale Y data
[npts, nchan] = size(Y);
yabsmax = max(max(abs(Y)));
yabsmax = yabsmax + yabsmax*yabsshift;

if strcmpi(mode, 'NEW')
	figure(hF);
	tmpData = zeros(npts, nchan);
	for c = 1:nchan
		tmpData(:, c) = Y(:, c) + c*yabsmax;
	end
	hL = plot(hAx, x, tmpData);
	
elseif strcmpi(mode, 'UPDATE')
	for c = 1:nchan
		set(hL(c), 'YData', Y(:, c) + c*yabsmax);
	end
end

% y axis ticks
yticks_yvals = yabsmax*(1:nchan);
yticks_txt = cell(nchan, 1);
for n = 1:nchan
	yticks_txt{n} = num2str(n);
end

ylim(yabsmax*[0 nchan+1]);

set(hAx, 'YTick', yticks_yvals);
set(hAx, 'YTickLabel', yticks_txt);
set(hAx, 'TickDir', 'out');
set(hAx, 'Box', 'off');

% set(hAx, 'Color', 0.75*[1 1 1]);
% set(h, 'Color', 0.75*[1 1 1]);
% set(h, 'ToolBar', 'none');

switch upper(colormode)
	case 'BLACK'
		for c = 1:nchan
			set(hL(c), 'Color', 0 * [1 1 1]);
		end
	case 'CUSTOM'
		for c = 1:nchan
			set(hL(c), 'Color', lcolors(c));
		end
end


if nargout > 0
	varargout{1} = hL;
end
if nargout > 1
	varargout{2} = hF;
end
if nargout > 2
	varargout = hAx;
end
