clear
close all
clc

%%
campaign = "NistCallJanuaryInterference";
load(fullfile(campaign, 'sinr.mat'))
scenarios = getScenarios(dimension_labels{1}.scenario);

for i = 1:length(scenarios)
    % reduce unused dimensions
    sinr{i} = vertcat(results{1,i,1,1,1,1,1,:});
end

%% ns-3
for i = 1:length(scenarios)
    figure
    plotName = strrep(scenarios{i}, '_', '\_');
    
    plot(sinr{i}(1,:), sinr{i}(2,:), 'DisplayName', plotName); hold on

    xlabel('t [s]')
    ylabel('SINR [dB]')
    legend('show', 'Location', 'best')
end

%% MATLAB vs ns-3
scenario = "refl2_qd0_relTh-Inf_floorMetal";
ns3Idx = find(scenarios == scenario);

load(fullfile(campaign, scenario, 'NetworkResults/bfMode_SVD/SNR.mat'))

ns3_t = sinr{ns3Idx}(1,:);

figure
plot(ns3_t, sinr{ns3Idx}(2,:), 'DisplayName', 'ns-3 SINR'); hold on
plot(linspace(0, max(ns3_t), length(SNR)), SNR, 'DisplayName', 'MATLAB SNR')
legend('show','Location','best')



%% Utils
function scenarios = getScenarios(scenarioStr)
scenarioStr = scenarioStr(2:end-1);
scenarioStr = strrep(scenarioStr,'''',''); % remove '
scenarios = split(scenarioStr, ', ');
end