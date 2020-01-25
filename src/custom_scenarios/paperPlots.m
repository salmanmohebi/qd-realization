clear
close all
clc

rtNetMatFile = 'matlab_stats_64_16_SVD.mat';
qdRunTimeFile = 'runTimeTable.mat';

%% SNR(t)
campaign = "IwcmcLroom";
load(fullfile(campaign, rtNetMatFile))

ratio = 'SNR';
tFig = figure();

for i = length(rtNetResults):-1:1
    if ~contains(rtNetResults(i).scenario, 'relTh-Inf')
        continue
    end
    
    y = rtNetResults(i).([ratio, '_db']);
    t = (0:length(y)-1) * 5e-3;
    scenarioTab = getScenarioTab(rtNetResults(i).scenario);
    plotName = sprintf('Refl.: %d', scenarioTab.totalNumberOfReflections);
    
    figure(tFig)
    plot(t, y, 'DisplayName', plotName); hold on
    
end
figure(tFig)
xlabel('t [s]')
ylabel([ratio, ' [dB]'])
legend('show', 'Location', 'best')

%% CDF on refl for all scenarios

campaigns = ["IwcmcLroom", "IwcmcIndoor1", "IwcmcParkingLot"];
cdfFig = figure();

for campaign = campaigns
    load(fullfile(campaign, rtNetMatFile))
    set(gca, 'ColorOrderIndex', 1)
    
    if campaign == "IwcmcParkingLot"
        rtNetResults(9:end) = [];
    end
    
    ratio = 'SNR';
    
    
    
    for i = length(rtNetResults):-1:1
        if ~contains(rtNetResults(i).scenario, 'relTh-Inf')
            continue
        end
        
        scenarioTab = getScenarioTab(rtNetResults(i).scenario);
        plotName =  sprintf('%s, Refl.: %d', campaign, scenarioTab.totalNumberOfReflections);
        
        figure(cdfFig)
        [y, x] = ecdf(rtNetResults(i).([ratio, '_db']));
        plot(x, y, 'DisplayName', plotName); hold on
        
    end
    
end
xlabel(['x = ', ratio, ' [dB]'])
ylabel('F(x)')
legend('show', 'Location', 'best')


%% Time boxplot
campaign = "IwcmcLroom";

load(fullfile(campaign, rtNetMatFile))
load(fullfile(campaign, qdRunTimeFile))

% pre-processing
rtRunTimeTab = runTimeTable;
rtRunTimeTab.Properties.VariableNames{rtRunTimeTab.Properties.VariableNames == "runTime"} = 'rtRunTime';

matlabRtNetRunTimeTab = getMatlabNetRunTimeTab(rtNetResults);

% matlabRtNetRunTimeTab.floorMaterial{matlabRtNetRunTimeTab.floorMaterial == "Metal___check"} = 'Metal';
matlabRtNetRunTimeTab(matlabRtNetRunTimeTab.totalNumberOfReflections == 4,:) = [];
rtRunTimeTab(rtRunTimeTab.totalNumberOfReflections == 4, :) = [];

if campaign == "IwcmcParkingLot"
    rtNetResults(9:end) = [];
    matlabRtNetRunTimeTab(9:end,:) = [];
end

% Refl
figure
boxplot(rtRunTimeTab.rtRunTime / 60, rtRunTimeTab.totalNumberOfReflections,...
    'PlotStyle', 'compact', 'Positions', (1:3)-0.1, 'Colors', 'k')
ylabel('RT Simulation Time [min]')
ax = gca;
ax.YLim(1) = max(0, ax.YLim(1));

yyaxis right
boxplot(matlabRtNetRunTimeTab.matlabRtNetSimTime, matlabRtNetRunTimeTab.totalNumberOfReflections,...
    'PlotStyle', 'compact', 'Positions', (1:3)+0.1, 'Colors', 'r')
set(gca, 'YColor', 'r')

xlabel('Number of Reflections')
ylabel('MATLAB Net. Sim. Time [s]')

% RelTh
figure
boxplot(rtRunTimeTab.rtRunTime / 60, rtRunTimeTab.minRelativePathGainThreshold,...
    'PlotStyle', 'compact', 'Positions', (1:4)-0.1, 'Colors', 'k')
ylabel('RT Simulation Time [min]')
ax = gca;
ax.YLim(1) = max(0, ax.YLim(1));

yyaxis right
boxplot(matlabRtNetRunTimeTab.matlabRtNetSimTime, matlabRtNetRunTimeTab.minRelativePathGainThreshold,...
    'PlotStyle', 'compact', 'Positions', (1:4)+0.1, 'Colors', 'r')
set(gca, 'YColor', 'r')

xlabel('Relative Threshold [dB]')
ylabel('MATLAB Net. Sim. Time [s]')

%% Correlation plots
numRuns = 1000;

campaigns = ["IwcmcParkingLot", "IwcmcLroom"];
for campaign = campaigns
    load(fullfile(campaign, rtNetMatFile))
    load(fullfile(campaign, qdRunTimeFile))
    
    rtRunTimeTab = runTimeTable;
    
    ratio = 'SNR';
    switch(campaign)
        case "IwcmcParkingLot"
            baselineScenario = "refl2_qd0_relTh-Inf_floorMetal";
        case {"IwcmcLroom", "IwcmcIndoor1"}
            baselineScenario = "refl4_qd0_relTh-Inf_floorMetal";
        otherwise
            error()
    end
    baselineScenarioIdx = find({rtNetResults.scenario} == baselineScenario);
    
    if campaign == "IwcmcParkingLot"
        rtNetResults(9:end) = [];
    end
    
    for i = length(rtNetResults):-1:1
        scenarioTab = getScenarioTab(rtNetResults(i).scenario);
        scenarioIdx = find(all(rtRunTimeTab{:,1:4} == scenarioTab{:,:}, 2));
        
        rtNetResults(i).rtRunTime = rtRunTimeTab.runTime(scenarioIdx);
        rtNetResults(i).exampleCampaignRunTime = rtRunTimeTab.runTime(scenarioIdx) + numRuns*rtNetResults(i).fullSimTime;
    end
    
    % MATLAB RT-Net
    figure
    for i = length(rtNetResults):-1:1
        plotName = strrep(rtNetResults(i).scenario, '_', '\_');
        
        % rmse
        err = db2pow(rtNetResults(i).([ratio, '_db'])) - db2pow(rtNetResults(baselineScenarioIdx).([ratio, '_db']));
        rmse = sqrt(mean((err).^2, 'omitnan')) / std(db2pow(rtNetResults(baselineScenarioIdx).([ratio, '_db'])));
        
        % plot
        [marker, color] = getMarker(rtNetResults(i).scenario);
        speedup = 1 / (rtNetResults(i).exampleCampaignRunTime / max([rtNetResults.exampleCampaignRunTime]));
        if isempty(speedup)
            speedup = nan;
        end
        
        scatter(rmse, speedup,...
            'Marker', marker, 'MarkerFaceColor', color, 'MarkerEdgeColor', color,...
            'DisplayName', plotName); hold on
        
    end
    xlabel(sprintf('%s NRMSE', ratio))
    ylabel('Speedup')
    title(sprintf('%s (%d runs)', campaign, numRuns))
    
    % legend
    p = [];
    leg = [];
    for refl = 1:4
        [~,color] = getMarker(sprintf('refl%d_qd0_relTh-Inf_floorMetal', refl));
        s = scatter(nan, nan, 'MarkerEdgeColor', color, 'MarkerFaceColor', color);
        
        p = [p, s];
        leg = [leg, sprintf("Refl.: %d", refl)];
    end
    for relTh = [-Inf, -40, -25, -15]
        marker = getMarker(sprintf('refl1_qd0_relTh%.0f_floorMetal', relTh));
        s = scatter(nan, nan, 'k', 'Marker', marker);
        
        p = [p, s];
        leg = [leg, sprintf("Rel. Thresh.: %.0f", relTh)];
    end
    legend(p, leg, 'Location', 'best', 'NumColumns', 2)
end

% Utils
function [marker, color] = getMarker(scenario)

tab = getScenarioTab(scenario);
c = get(groot, 'DefaultAxesColorOrder');

color = c(tab.totalNumberOfReflections, :);

switch(tab.minRelativePathGainThreshold)
    case -Inf
        marker = 'o';
    case -40
        marker = 's';
    case -25
        marker = 'v';
    case -15
        marker = 'd';
    otherwise
        error('Treshold ''%.1f'' not supported', tab.minRelativePathGainThreshold)
end

end