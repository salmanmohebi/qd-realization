clear
close all
clc

%%
campaign = "IwcmcLroom";
rtNetMatFile = 'matlab_stats_64_16_SVD.mat';
load(fullfile(campaign, rtNetMatFile))

ratio = 'SINR';
baselineScenario = "refl4_qd0_relTh-Inf_floorMetal";
baselineScenarioIdx = find({rtNetResults.scenario} == baselineScenario);

%% MATLAB RT-Net
figure

for i = length(rtNetResults):-1:1
    plotName = strrep(rtNetResults(i).scenario, '_', '\_');
    
    err = db2pow(rtNetResults(i).([ratio, '_db'])) - db2pow(rtNetResults(baselineScenarioIdx).([ratio, '_db']));
    rmse = sqrt(mean((err).^2, 'omitnan')) / mean(db2pow(rtNetResults(baselineScenarioIdx).([ratio, '_db'])));
    
    [marker, color] = getMarker(rtNetResults(i).scenario);
    
    scatter(rmse, rtNetResults(i).fullSimTime,...
        'Marker', marker, 'MarkerFaceColor', color, 'MarkerEdgeColor', color,...
        'DisplayName', plotName); hold on

end
xlabel(sprintf('%s NRMSE', ratio))
ylabel('MATLAB Net. Sim. Time [s]')

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
legend(p, leg, 'NumColumns', 2)
    
%% Utils
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