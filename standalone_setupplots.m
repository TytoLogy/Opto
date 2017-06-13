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

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Set up figure for plotting psths
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% generate figure, axes
if isempty(handles.H.pstH) || ~ishandle(handles.H.pstH)
	handles.H.pstH = figure;
end
% store local copy of figure handle for simplicity in calls
pstH = handles.H.pstH;
% create/switch focus to figure
figure(pstH);

% set up plots
nPSTH = length(stimList);
% subplots
for p = 1:nPSTH
	handles.H.pstX(p) = subplot(3, 2, p);
	if any(strcmpi(stimList(p).audio.signal.Type, {'null', 'noise'}))
		title(handles.H.pstX(p), stimList(p).audio.signal.Type)
	elseif strcmpi(stimList(p).audio.signal.Type, 'wav')
		[~, wname] = fileparts(stimList(p).audio.signal.WavFile);
		title(handles.H.pstX(p), wname, 'Interpreter', 'none');
	else
		error('WTF?')
	end
end

binSize = 10;

% set up psth vectors
SpikeTimes = cell(nPSTH, 1);
for p = 1:nPSTH
	SpikeTimes{p} = cell(test.Reps, 1);
end
PSTH = cell(nPSTH, 1);
currentRep = ones(nPSTH, 1);





