clear
close all
clc

colors = get(groot, 'DefaultAxesColorOrder');

%% Input
campaign = "Journal1GroundOnly";
rxPosFile = "NodePosition1.dat";
txPosFile = "NodePosition2.dat";

nAnts = ["1_1", "4_4", "64_16"];
lineStyle = ["-", "--", ":"];

scenarios = ["refl1_qd0_relTh-Inf_floorPec", "refl1_qd0_relTh-Inf_floorMetal"];
scenariosNames = ["PEC", "Lossy"];

% load positions
rxPos = csvread(fullfile(campaign, "Input", rxPosFile));
txPos = csvread(fullfile(campaign, "Input", txPosFile));
% remove last position as it is ignored by the RT
rxPos(end, :) = [];
txPos(end, :) = [];

dist2d = vecnorm(rxPos(:, 1:2) - txPos(:, 1:2), 2, 2);

%% plot
for nAntIdx = 1:length(nAnts)
    nAnt = nAnts(nAntIdx);
    nAntSplit = split(nAnt, '_');
    
    for scenarioIdx = 1:length(scenarios)
        scenario = scenarios(scenarioIdx);
        
        % load matlab sim results
        filename = sprintf("matlab_stats_%s_SVD.mat", nAnt);
        load(fullfile(campaign, filename))
        
        % find scenario
        scenarioMask = strcmp({rtNetResults.scenario}, scenario);
        results = rtNetResults(scenarioMask);
        
        % plot
        plotLabel = sprintf('TX: %s, RX: %s, %s',...
            nAntSplit{1}, nAntSplit{2}, scenariosNames{scenarioIdx});
        
        semilogx(dist2d, params.Ptx - results.Prx_dbm,...
            'DisplayName', plotLabel,...
            'LineStyle', lineStyle(nAntIdx),...
            'Color', colors(scenarioIdx, :)); hold on
    end
end

xlabel('2D Distance [m]')
ylabel('$P_{\rm TX} / P_{\rm RX}$ [dB]')
xlim([0, 20])
legend('show', 'Location', 'best')