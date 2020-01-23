clear
close all
clc

%% process
campaign = "IwcmcLroom";
rtNetMatFile = 'matlab_stats_64_1.mat';
qdRunTimeFile = 'runTimeTable.mat';

load(fullfile(campaign, rtNetMatFile))
load(fullfile(campaign, qdRunTimeFile))

% pre-processing
rtRunTimeTab = runTimeTable;
rtRunTimeTab.Properties.VariableNames{rtRunTimeTab.Properties.VariableNames == "runTime"} = 'rtRunTime';

matlabRtNetRunTimeTab = getMatlabNetRunTimeTab(rtNetResults);

%% Plot
% RT
plotRunTime(rtRunTimeTab, 'rtRunTime', 'totalNumberOfReflections', 'Number of Reflections', 'RT Simulation Time [s]')
% plotRunTime(rtRunTimeTab, 'rtRunTime', 'switchQDGenerator', 'QD Switch', 'RT Simulation Time [s]')
plotRunTime(rtRunTimeTab, 'rtRunTime', 'minRelativePathGainThreshold', 'Relative Threshold [dB]', 'RT Simulation Time [s]')
% plotRunTime(rtRunTimeTab, 'rtRunTime', 'floorMaterial', 'Floor Material', 'RT Simulation Time [s]')

% Matlab net
plotRunTime(matlabRtNetRunTimeTab, 'matlabRtNetSimTime', 'totalNumberOfReflections', 'Number of Reflections', 'MATLAB Net. Sim. Time [s]')
% plotRunTime(matlabRtNetRunTimeTab, 'matlabRtNetSimTime', 'switchQDGenerator', 'QD Switch', 'MATLAB Net. Sim. Time [s]')
plotRunTime(matlabRtNetRunTimeTab, 'matlabRtNetSimTime', 'minRelativePathGainThreshold', 'Relative Threshold [dB]', 'MATLAB Net. Sim. Time [s]')
% plotRunTime(matlabRtNetRunTimeTab, 'matlabRtNetSimTime', 'floorMaterial', 'Floor Material', 'MATLAB Net. Sim. Time [s]')


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

function matlabRtNetRunTimeTab = getMatlabNetRunTimeTab(rtNetResults)

matlabRtNetRunTimeTab  = table();
for i = 1:length(rtNetResults)
    scenarioTab = getScenarioTab(rtNetResults(i).scenario);
    scenarioTab.matlabRtNetSimTime = rtNetResults(i).fullSimTime;
    
    matlabRtNetRunTimeTab = [matlabRtNetRunTimeTab; scenarioTab];
end

end

function plotRunTime(tab, runTimeField, categoryField, xLabel, yLabel)

figure
boxplot(tab.(runTimeField), tab.(categoryField))
xlabel(xLabel)
ylabel(yLabel)

end