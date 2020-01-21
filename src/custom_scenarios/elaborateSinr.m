clear
close all
clc

%%
campaign = "NistCallJanuaryInterference";
load(fullfile(campaign, 'sinr.mat'))
scenarios = getScenarios(dimension_labels{1}.scenario);

for i = 1:length(scenarios)
    % reduce unused dimensions
    sinr{i} = shiftdim(results(1,i,1,1,1,1,1,:,:));
end

%% ns-3
figure
for i = 1:length(scenarios)
    plotName = strrep(scenarios{i}, '_', '\_');
    
    plot(sinr{i}(1,:), sinr{i}(2,:), 'DisplayName', plotName); hold on

end
xlabel('t [s]')
ylabel('SINR [dB]')
legend('show', 'Location', 'best')

%% MATLAB vs ns-3
scenario = "refl1_qd0_relTh-Inf_floorMetal";
paraCfg = parameterCfg(fullfile(campaign, scenario));
duration = paraCfg.totalTimeDuration;

% ns-3
ns3Idx = find(scenarios == scenario);
ns3Out = sinr{ns3Idx}(1,:);

% matlab
load(fullfile(campaign, sprintf('%s_matlab_stats', scenario)))
matlab_t = linspace(0, duration, length(out.SINR_db) + 2);
matlab_t = matlab_t(1:end-2);

figure
plot(ns3Out, sinr{ns3Idx}(2,:), 'DisplayName', 'ns-3 SINR'); hold on
stairs(matlab_t, out.SNR_db, 'DisplayName', 'MATLAB SNR')
stairs(matlab_t, out.SINR_db, 'DisplayName', 'MATLAB SINR')

title(strrep(scenario, '_', '\_'))
legend('show','Location','best')



%% Utils
function scenarios = getScenarios(scenarioStr)
scenarioStr = scenarioStr(2:end-1);
scenarioStr = strrep(scenarioStr,'''',''); % remove '
scenarios = split(scenarioStr, ', ');
end