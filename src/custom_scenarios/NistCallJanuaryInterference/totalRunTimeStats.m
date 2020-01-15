clear
close all
clc

%% process
load('ns3SimTime.mat')
scenarios = getScenarios(dimension_labels{1}.scenario);

load('runTimeTable2.mat');
rtRunTimeTab = runTimeTable;
rtRunTimeTab.Properties.VariableNames{rtRunTimeTab.Properties.VariableNames == "runTime"} = 'rtRunTime';

ns3RunTimeTab = table();
for i = 1:length(scenarios)
    ns3RunTimeTab(end+1, :) = getScenarioTab(scenarios{i});
end
ns3RunTimeTab.ns3RunTime = shiftdim(results);

runTimeTab = join(rtRunTimeTab, ns3RunTimeTab,...
    'Keys', ["totalNumberOfReflections", "switchQDGenerator", "minRelativePathGainThreshold", "floorMaterial"]);

runTimeTab.totRunTime = runTimeTab.rtRunTime + runTimeTab.ns3RunTime;

%% Plot
% RT
figure
boxplot(runTimeTab.rtRunTime, runTimeTab.totalNumberOfReflections)
xlabel('Number of reflections')
ylabel('RT simulation time [s]')

figure
boxplot(runTimeTab.rtRunTime, runTimeTab.switchQDGenerator)
xlabel('QD switch')
ylabel('RT simulation time [s]')

figure
boxplot(runTimeTab.rtRunTime, runTimeTab.minRelativePathGainThreshold)
xlabel('Relative Threshold [dB]')
ylabel('RT simulation time [s]')

figure
boxplot(runTimeTab.rtRunTime, runTimeTab.floorMaterial)
xlabel('Floor Material')
ylabel('RT simulation time [s]')

% ns-3
figure
boxplot(runTimeTab.ns3RunTime, runTimeTab.totalNumberOfReflections)
xlabel('Number of reflections')
ylabel('Ns-3 simulation time [s]')

figure
boxplot(runTimeTab.ns3RunTime, runTimeTab.switchQDGenerator)
xlabel('QD switch')
ylabel('Ns-3 simulation time [s]')

figure
boxplot(runTimeTab.ns3RunTime, runTimeTab.minRelativePathGainThreshold)
xlabel('Relative Threshold [dB]')
ylabel('Ns-3 simulation time [s]')

figure
boxplot(runTimeTab.ns3RunTime, runTimeTab.floorMaterial)
xlabel('Floor Material')
ylabel('Ns-3 simulation time [s]')

% Total
figure
boxplot(runTimeTab.totRunTime, runTimeTab.totalNumberOfReflections)
xlabel('Number of reflections')
ylabel('Totale simulation time [s]')

figure
boxplot(runTimeTab.totRunTime, runTimeTab.switchQDGenerator)
xlabel('QD switch')
ylabel('Totale simulation time [s]')

figure
boxplot(runTimeTab.totRunTime, runTimeTab.minRelativePathGainThreshold)
xlabel('Relative Threshold [dB]')
ylabel('Totale simulation time [s]')

figure
boxplot(runTimeTab.totRunTime, runTimeTab.floorMaterial)
xlabel('Floor Material')
ylabel('Totale simulation time [s]')

%% Utils
function scenarios = getScenarios(scenarioStr)
scenarioStr = scenarioStr(2:end-1);
scenarioStr = strrep(scenarioStr,'''',''); % remove '
scenarios = split(scenarioStr, ', ');
end

function tab = getScenarioTab(scenario)

t = regexp(scenario, 'refl(.+)_qd(.+)_relTh(.+)_floor(.+)', 'tokens');

totalNumberOfReflections = str2double(t{1}{1});
switchQDGenerator = str2double(t{1}{2});
minRelativePathGainThreshold = str2double(t{1}{3});
floorMaterial = string(t{1}{4});

tab = table(totalNumberOfReflections, switchQDGenerator, minRelativePathGainThreshold, floorMaterial);

end