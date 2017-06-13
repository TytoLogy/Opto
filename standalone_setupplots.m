% standalone_setupplots
%
% Initializes plots for sweep display, PSTHs, Raster plots
%

hashColor = 'c';
% binsize (ms)
binSize = 10;

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
% create/switch focus to figure, generate axis
figure(handles.H.fH);
% set up plot
% calculate # of points to acquire (in units of samples)
xv = linspace(0, test.AcqDuration, acqpts);
xlim(handles.H.ax, [0 acqpts]);
yabsmax = 5;
tmpData = zeros(acqpts, channels.nInputChannels);
for n = 1:channels.nInputChannels
	tmpData(:, n) = n*(yabsmax) + 2*(2*rand(acqpts, 1)-1);
end
pH = plot(handles.H.ax, xv, tmpData);
yticks_yvals = yabsmax*(1:channels.nInputChannels);
yticks_txt = cell(channels.nInputChannels, 1);
for n = 1:channels.nInputChannels
	yticks_txt{n} = num2str(n);
end
ylim(yabsmax*[0 channels.nInputChannels+1]);
set(handles.H.ax, 'YTick', yticks_yvals);
set(handles.H.ax, 'YTickLabel', yticks_txt);
set(handles.H.ax, 'TickDir', 'out');
set(handles.H.ax, 'Box', 'off');
set(handles.H.fH, 'Position', [792 225 557 800]);		
xlabel('Time (ms)')
ylabel('Channel')
set(handles.H.ax, 'Color', 0.75*[1 1 1]);
set(handles.H.fH, 'Color', 0.75*[1 1 1]);
set(handles.H.fH, 'ToolBar', 'none');
%-------------------------------------------------------------------------
% spike hashes
%-------------------------------------------------------------------------
% tH = text(	[], [], '|', 'Color', hashColor, 'Parent', ax);
hold(handles.H.ax, 'on')
tH = scatter(handles.H.ax, [], [], '.', hashColor);
hold(handles.H.ax, 'off')
grid(handles.H.ax, 'on');


%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Set up figure for plotting psths
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%--------------------------------
% generate figure, axes if needed
%--------------------------------
if isempty(handles.H.pstH) || ~ishandle(handles.H.pstH)
	handles.H.pstH = figure;
end
% create/switch focus to figure
figure(handles.H.pstH);
% set position
set(handles.H.pstH, 'Position', [1358 418 560 578]);
%--------------------------------
% set up plots
%--------------------------------
nPSTH = length(stimList);
% subplots
for p = 1:nPSTH
	handles.H.pstX(p) = subplot(3, 2, p);
	if any(strcmpi(stimList(p).audio.signal.Type, {'null', 'noise'}))
		title(	handles.H.pstX(p), ...
					stimList(p).audio.signal.Type, ...
					'FontSize', 10);
	elseif strcmpi(stimList(p).audio.signal.Type, 'wav')
		[~, wname] = fileparts(stimList(p).audio.signal.WavFile);
		title(	handles.H.pstX(p), ...
					wname, ...
					'Interpreter', 'none', ...
					'FontSize', 10);
	else
		error('WTF?')
	end
end
%--------------------------------
% set up psth data storage
%--------------------------------
% SpikeTimes cell array will store spike time data
SpikeTimes = cell(nPSTH, 1);
% initialize data - each elemend of SpikeTimes is a cell array
% with length of # of Reps per stimulus
for p = 1:nPSTH
	SpikeTimes{p} = cell(test.Reps, 1);
end
% create PSTH data struct to hold bins (same for all plots!) and
% histogram values (hvals)
PSTH = struct('bins', [], 'hvals', []);
PSTH.hvals = cell(nPSTH, 1);
% current rep will store the count of reps for each stimulus. 
% it can be indexed using stimIndex (since it of length(stimList)
% to handle the randomization of stimuli
currentRep = ones(nPSTH, 1);
% now create "dummy" data for the psthdata
for p = 1:nPSTH
	if p == 1
		% create null psthdata and store bins
		[PSTH.hvals{p}, PSTH.bins] = ...
									psth(	{}, binSize, ...
											[0 handles.H.TDT.AcqDuration]);
	else
		% just store hvals
		PSTH.hvals{p} = psth({}, binSize, [0 handles.H.TDT.AcqDuration]);
	end
end
%--------------------------------
% and plot the psth
%--------------------------------
for p = 1:nPSTH
	bar(handles.H.pstX(p), PSTH.bins, PSTH.hvals{p}, 1);
	xlim(handles.H.pstX(p), [0 handles.H.TDT.AcqDuration]);
end
axis(handles.H.pstX, 'auto y');

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Set up figure for plotting rasters
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%--------------------------------
% generate figure, axes if needed
%--------------------------------
if isempty(handles.H.rstH) || ~ishandle(handles.H.rstH)
	handles.H.rstH = figure;
end
% create/switch focus to figure
figure(handles.H.rstH);
% set position
set(handles.H.rstH, 'Position', [36 96 560 420]);
%--------------------------------
% set up plots
%--------------------------------
% subplots
for p = 1:nPSTH
	handles.H.rstX(p) = subplot(3, 2, p);
	if any(strcmpi(stimList(p).audio.signal.Type, {'null', 'noise'}))
		title(	handles.H.rstX(p), ...
					stimList(p).audio.signal.Type, ...
					'FontSize', 10);
	elseif strcmpi(stimList(p).audio.signal.Type, 'wav')
		[~, wname] = fileparts(stimList(p).audio.signal.WavFile);
		title(	handles.H.rstX(p), ...
					wname, ...
					'Interpreter', 'none', ...
					'FontSize', 10);
	else
		error('WTF?')
	end
end
%--------------------------------
% and plot the rasters
%--------------------------------
for p = 1:nPSTH
	rasterplot(		SpikeTimes{p}, ...
						[0 handles.H.TDT.AcqDuration], ...
						'|', ...
						12, ...
						'k', ...
						handles.H.rstX(p)	);
	xlim(handles.H.rstX(p), [0 handles.H.TDT.AcqDuration]);
end


