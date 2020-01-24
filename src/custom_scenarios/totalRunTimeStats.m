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
function plotRunTime(tab, runTimeField, categoryField, xLabel, yLabel)

figure
boxplot(tab.(runTimeField), tab.(categoryField))
xlabel(xLabel)
ylabel(yLabel)

% do not allow negative time
ax = gca;
ax.YLim(1) = max(0, ax.YLim(1));

end