clear
close all
clc

%%
load('sinr.mat')
scenarios = getScenarios(dimension_labels{1}.scenario);

for i = 1:length(scenarios)
    % reduce unused dimensions
    sinr{i} = vertcat(results{1,i,1,1,1,1,1,:});
end

%% ns-3
scenariosToPlot = ["refl1_qd0_relTh-15_floorMetal", "refl2_qd0_relTh-15_floorMetal"];

figure
for i = 1:length(scenariosToPlot)
    idx = find(scenarios == scenariosToPlot(i));
    plotName = strrep(scenariosToPlot(i), '_', '\_');
    
    plot(sinr{idx}(1,:), sinr{idx}(2,:), 'DisplayName', plotName); hold on
end
xlabel('t [s]')
ylabel('SINR [dB]')
legend('show', 'Location', 'best')

%% MATLAB vs ns-3
scenario = "refl1_qd0_relTh-15_floorMetal";
ns3Idx = find(scenarios == scenariosToPlot(i));

load(fullfile(scenario, 'NetworkResults/bfMode_SVD/SNR.mat'))

ns3_t = sinr{ns3Idx}(1,:);

figure
plot(ns3_t, sinr{ns3Idx}(2,:), 'DisplayName', 'ns-3 SINR'); hold on
plot(linspace(0, max(ns3_t), length(SNR)), SNR, 'DisplayName', 'MATLAB SNR')




%% Utils
function scenarios = getScenarios(scenarioStr)
scenarioStr = scenarioStr(2:end-1);
scenarioStr = strrep(scenarioStr,'''',''); % remove '
scenarios = split(scenarioStr, ', ');
end