function varargout = stackplot(x, Y, varargin)
%------------------------------------------------------------------------
% [hL, hF, hAx] = stackplot(x, Y, varargin)
%------------------------------------------------------------------------
% 
%-------------------------------------------------------------------------
% for a given vector of x-axis values (x) and matrix of y-axis values (Y),
% plot all y-axis traces (each "channel" in a different column) stacked
% from the first column of Y at the bottom of the plot and the last column
% of Y at the top
% 
%------------------------------------------------------------------------
% Output Arguments:
% 
%	hL		handles to lineseries objects (from plot() function)
%	hF		handles to figure(s)
%	hAx	handle(s) to axes
% 
%------------------------------------------------------------------------
% See Also:
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%  Sharad Shanbhag
%	sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 10 June, 2016 (SJS) 
%			- adapted from readHPData.m
% 
% Revisions:
%------------------------------------------------------------------------
% TO DO:
%	*Documentation!
%--------------------------------------------------------------------------


%------------------------------------------------------------------------
% set up plot information
%------------------------------------------------------------------------
if isempty(varargin)
	%---------------------------------------------------------------------
	% no input options given, so use default settings
	%---------------------------------------------------------------------
	hF = [];
	hAx = [];
	hL = [];
	mode = 'NEW';
	colormode = 'DEFAULT';
	yabsshift = 0;
	yabsmax = [];
	
else
	%---------------------------------------------------------------------
	% parse input options
	%---------------------------------------------------------------------
	% initialize
	hF = [];
	hAx = [];
	hL = [];
	mode = 'NEW';
	colormode = 'DEFAULT';
	yabsshift = 0;
	yabsmax = [];
	% loop through args
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
			case 'YMAX'
				if ~isnumeric(varargin{j+1})
					warning('%s: Ymax value must be a number', mfilename);
					yabsmax = [];
				elseif varargin{j+1} <= 0
					warning('%s: Ymax value must be greater than 0', mfilename);
					yabsmax = [];
				else
					yabsmax = varargin{j+1};
				end
				j = j + 2;
			otherwise
				error('%s: unknown setting %s', mfilename, varargin{j});
		end
	end	
end

%------------------------------------------------------------------------
% create figure and axes if empty
%------------------------------------------------------------------------
if isempty(hF)
	hF = figure;
end
if isempty(hAx)
	hAx = axes;
end

%------------------------------------------------------------------------
% get size of Y matrix
%------------------------------------------------------------------------
[npts, nchan] = size(Y);

%------------------------------------------------------------------------
% if YMAX wasn't specified, scale Y data based on peak across entire matrix
%------------------------------------------------------------------------
if isempty(yabsmax)
	yabsmax = max(max(abs(Y)));
	yabsmax = yabsmax + yabsmax*yabsshift;
end

%------------------------------------------------------------------------
% check if new plot, or just an update of existing plot
%------------------------------------------------------------------------
if strcmpi(mode, 'NEW')
	% new plot, plot all channel data
	figure(hF);
	tmpData = zeros(npts, nchan);
	for c = 1:nchan
		tmpData(:, c) = Y(:, c) + c*yabsmax;
	end
	hL = plot(hAx, x, tmpData);
	
elseif strcmpi(mode, 'UPDATE')
	% updating plot, just renew YData in plot
	for c = 1:nchan
		set(hL(c), 'YData', Y(:, c) + c*yabsmax);
	end
end

%------------------------------------------------------------------------
% y axis ticks
%------------------------------------------------------------------------
yticks_yvals = yabsmax*(1:nchan);
yticks_txt = cell(nchan, 1);
for n = 1:nchan
	yticks_txt{n} = num2str(n);
end

%------------------------------------------------------------------------
% set yaxis limits
%------------------------------------------------------------------------
ylim(yabsmax*[0 nchan+1]);

%------------------------------------------------------------------------
% ticks, box options
%------------------------------------------------------------------------
set(hAx, 'YTick', yticks_yvals);
set(hAx, 'YTickLabel', yticks_txt);
set(hAx, 'TickDir', 'out');
set(hAx, 'Box', 'off');

% set(hAx, 'Color', 0.75*[1 1 1]);
% set(h, 'Color', 0.75*[1 1 1]);
% set(h, 'ToolBar', 'none');

%------------------------------------------------------------------------
% colors?
%------------------------------------------------------------------------
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

%------------------------------------------------------------------------
% assign outputs
%------------------------------------------------------------------------
if nargout > 0
	varargout{1} = hL;
end
if nargout > 1
	varargout{2} = hF;
end
if nargout > 2
	varargout{3} = hAx;
end
