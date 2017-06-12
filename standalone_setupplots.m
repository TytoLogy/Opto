%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Set up figure for plotting incoming data
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% generate figure, axes
if isempty(handles.H.fH) || ~ishandle(handles.H.fH)
	handles.H.fH = figure;
end
if isempty(handles.H.ax) || ~ishandle(handles.H.ax)
	handles.H.ax = axes;
end
% store local copy of figure handle for simplicity in calls
fH = handles.H.fH;
% create/switch focus to figure, generate axis
figure(fH);
ax = handles.H.ax;
% set up plot
% calculate # of points to acquire (in units of samples)
xv = linspace(0, test.AcqDuration, acqpts);
xlim([0, acqpts]);
yabsmax = 5;
tmpData = zeros(acqpts, channels.nInputChannels);
for n = 1:channels.nInputChannels
	tmpData(:, n) = n*(yabsmax) + 2*(2*rand(acqpts, 1)-1);
end
pH = plot(ax, xv, tmpData);
yticks_yvals = yabsmax*(1:channels.nInputChannels);
yticks_txt = cell(channels.nInputChannels, 1);
for n = 1:channels.nInputChannels
	yticks_txt{n} = num2str(n);
end
ylim(yabsmax*[0 channels.nInputChannels+1]);
set(ax, 'YTick', yticks_yvals);
set(ax, 'YTickLabel', yticks_txt);
set(ax, 'TickDir', 'out');
set(ax, 'Box', 'off');
set(fH, 'Position', [861 204 557 800]);		
xlabel('Time (ms)')
ylabel('Channel')
set(ax, 'Color', 0.75*[1 1 1]);
set(fH, 'Color', 0.75*[1 1 1]);
set(fH, 'ToolBar', 'none');
grid(ax, 'on');