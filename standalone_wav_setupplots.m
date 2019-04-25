% standalone_setupplots
%
% Initializes plots for sweep display, PSTHs, Raster plots
%
% 28 Mar 2019 (SJS): Updated for MTwav()

disp 'setting up plots'

% color for detected spikes
hashColor = 'c';
% binsize (ms)
binSize = 10;

% figure name base
[fpath, fname] = fileparts(datafile);

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Set up figure for plotting incoming data
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% generate figure, axes
fH = figure;
aX = axes;
% switch focus to figure
figure(fH);
% set figure name
set(fH, 'Name', [fname ' Traces']);
% set up plot
% calculate # of points to acquire (in units of samples)
xv = linspace(0, test.AcqDuration, acqpts);
xlim(aX, [0 acqpts]);
yabsmax = 5;
tmpData = zeros(acqpts, channels.nInputChannels);
for n = 1:channels.nInputChannels
	tmpData(:, n) = n*(yabsmax) + 2*(2*rand(acqpts, 1)-1);
end
pH = plot(aX, xv, tmpData);
yticks_yvals = yabsmax*(1:channels.nInputChannels);
yticks_txt = cell(channels.nInputChannels, 1);
for n = 1:channels.nInputChannels
	yticks_txt{n} = num2str(n);
end
ylim(yabsmax*[0 channels.nInputChannels+1]);
set(aX, 'YTick', yticks_yvals);
set(aX, 'YTickLabel', yticks_txt);
set(aX, 'TickDir', 'out');
set(aX, 'Box', 'off');
set(fH, 'Position', [792 225 557 800]);		
xlabel('Time (ms)')
ylabel('Channel')
set(aX, 'Color', 0.75*[1 1 1]);
set(fH, 'Color', 0.75*[1 1 1]);
set(fH, 'ToolBar', 'none');
%-------------------------------------------------------------------------
% spike hashes
%-------------------------------------------------------------------------
hold(aX, 'on')
tH = scatter(aX, [], [], '.', hashColor);
hold(aX, 'off')
grid(aX, 'on');

%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
% Set up figure for plotting psths
%-------------------------------------------------------------------------
%-------------------------------------------------------------------------
%--------------------------------
% generate figure, axes if needed
%--------------------------------
pstHandle = figure;
% create/switch focus to figure
figure(pstHandle);
% set position
set(pstHandle, 'Position', [1357 225 560 773]);
% set figure name
set(pstHandle, 'Name', [fname ' PSTH']);
% set figure filename
set(pstHandle, 'Filename', [fname '_PSTH.fig']);
%--------------------------------
% set up plots
%	revising 24 Apr 2019 to account for multiple stim levels per stimulus
%	type in stimList!!!
%--------------------------------
nPSTH = test.NullStim + test.NoiseStim + length(wavInfo);
% allocate axes
pstAxes = zeros(nPSTH, 1);
% subplots for wav files first
for p = 1:length(wavInfo)
	pstAxes(p) = subplot(PLOT_ROWS, PLOT_COLS, p);
	% write titles for plots
	[~, wname] = fileparts(wavInfo(p).Filename);
	title(	pstAxes(p), ...
				wname, ...
				'Interpreter', 'none', ...
				'FontSize', 8, ...
				'FontWeight', 'normal');
end
% then for null stim
if test.NullStim
	p = p + 1;
	pstAxes(p) = subplot(PLOT_ROWS, PLOT_COLS, p);
	% write titles for plots
	title(	pstAxes(p), ...
					nullstim.signal.Type, ...
					'FontSize', 9, ...
					'FontWeight', 'normal');
end
% and then for noise stim
if test.NoiseStim
	p = p + 1;
	pstAxes(p) = subplot(PLOT_ROWS, PLOT_COLS, p);
	% write titles for plots
	title(	pstAxes(p), ...
					noise.signal.Type, ...
					'FontSize', 9, ...
					'FontWeight', 'normal');
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
% current rep will store the count of reps for each stimulus. 
% it can be indexed using stimIndex (since it of length(stimList)
% to handle the randomization of stimuli
currentRep = ones(nPSTH, 1);
% create PSTH data struct to hold bins (same for all plots!) and
% histogram values (hvals)
PSTH = struct('bins', [], 'hvals', []);
PSTH.hvals = cell(nPSTH, 1);
% now create "dummy" data for the psthdata
for p = 1:nPSTH
	if p == 1
		% create null psthdata and store bins
% 		[PSTH.hvals{p}, PSTH.bins] = ...
% 									psth(	{}, binSize, ...
% 											[0 handles.H.TDT.AcqDuration]);
		[PSTH.hvals{p}, PSTH.bins] = ...
									psth(	{}, binSize, ...
											[0 test.AcqDuration]);
	else
		% just store hvals
% 		PSTH.hvals{p} = psth({}, binSize, [0 handles.H.TDT.AcqDuration]);
		PSTH.hvals{p} = psth({}, binSize, [0 test.AcqDuration]);
	end
end
% offset psth bins by binSize/2 to get things to line up properly when
% plotted using bar() function - the default is to center bars at 
% binsize/2
PSTH.bins = PSTH.bins + (binSize/2);
%--------------------------------
% and plot dummy psth to initialize
%--------------------------------
pstBar = zeros(nPSTH, 1);
for p = 1:nPSTH
	pstBar(p) = bar(pstAxes(p), PSTH.bins, PSTH.hvals{p}, 1);
	% set xlimits
% 	xlim(pstAxes(p), [-0.5*binSize ...
% 										(handles.H.TDT.AcqDuration+0.5*binSize)]);
	xlim(pstAxes(p), [-0.5*binSize ...
										(test.AcqDuration+0.5*binSize)]);
	% set xtick properties
% 	set(pstAxes(p), 'XTick', 0:200:handles.H.TDT.AcqDuration);
	set(pstAxes(p), 'XTick', test.AcqDuration);
	set(pstAxes(p), 'TickDir', 'out');
	set(pstAxes(p), 'XMinorTick', 'on');
	set(pstAxes(p), 'TickLen', 3*get(pstAxes(p), 'TickLen'));
	% turn off outer box
	set(pstAxes(p), 'Box', 'off');
end
%--------------------------------
% set automatic scaling for y axis only on all plots
%--------------------------------
axis(pstAxes, 'auto y');
%--------------------------------
% draw line for stimulus onset
%	revising 24 Apr 2019 to account for multiple stim levels per stimulus
%	type in stimList!!!
%--------------------------------
pstAudLine = zeros(nPSTH, 2);
% stimulus lines depend on stimulus type
for p = 1:length(wavInfo)
	axes(pstAxes(p)); %#ok<LAXES>
	% adjust the onset "tick" to account for the delayed
	% onset within the wav file (calculated in buildWavInfo() function)
	onset = audio.Delay + bin2ms(wavInfo(p).OnsetBin, ...
															wavInfo(p).SampleRate);
	offset = onset + 1000*wavInfo(p).Duration;
	if ~isempty(onset)
		pstAudLine(p, 1) = text(onset, 0, ':', ...
											'Color', 'b', ...
											'FontSize', 11);
		pstAudLine(p, 2) = text(offset, 0, '|', ...
											'Color', 'b', ...
											'FontSize', 11);
	end
end
if test.NullStim
	p = p+1;
	axes(pstAxes(p)); 
end
if test.NoiseStim
	p = p+1;
	axes(pstAxes(p)); 
	onset = noise.Delay;
	offset = onset + noise.Duration;
	pstAudLine(p, 1) = text(onset, 0, ':', ...
										'Color', 'b', ...
										'FontSize', 11);
	pstAudLine(p, 2) = text(offset, 0, '|', ...
										'Color', 'b', ...
										'FontSize', 11);
end
%--------------------------------
% draw line for opto stim
%--------------------------------
if opto.Enable
	pstOptoLine = zeros(nPSTH, 2);
	onset = opto.Delay;
	offset = onset + opto.Dur;
	for p = 1:nPSTH
		axes(pstAxes(p)); %#ok<LAXES>
		pstOptoLine(p, 1) =  text(onset, 0, ':', ...
												'Color', 'g', ...
												'FontSize', 11, ...
												'FontWeight', 'bold');
		pstOptoLine(p, 2) =  text(offset, 0, '|',  ...
												'Color', 'g', ...
												'FontSize', 11, ...
												'FontWeight', 'demi');
	end
end
