clear
close all
clc

%%
load('sinr.mat')
scenarios = "refl2_qd0_relTh-Inf_floorMetal";% getScenarios(dimension_labels{1}.scenario);

for i = 1:length(scenarios)
    % reduce unused dimensions
    sinr{i} = shiftdim(results(1,1,1,1,1,1,1,:,:));
end

%% ns-3
folders = dir();
folders(~[folders.isdir]) = [];
folders({folders.name} == "Input") = [];
folders({folders.name} == ".") = [];
folders({folders.name} == "..") = [];
scenariosToPlot = "refl2_qd0_relTh-Inf_floorMetal";%string({folders.name});


for i = 1:length(scenariosToPlot)
    figure
    idx = find(scenarios == scenariosToPlot(i));
    plotName = strrep(scenariosToPlot(i), '_', '\_');
    
    plot(sinr{idx}(1,:), sinr{idx}(2,:), 'DisplayName', plotName); hold on
end
xlabel('t [s]')
ylabel('SINR [dB]')
legend('show', 'Location', 'best')

%% MATLAB vs ns-3
scenario = "refl2_qd0_relTh-Inf_floorMetal";
ns3Idx = find(scenarios == scenariosToPlot(i));

load(fullfile(scenario, 'NetworkResults/bfMode_SVD/SNR.mat'))

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