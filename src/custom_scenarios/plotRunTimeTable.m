clear
close all
clc

%%
campaign = "NistCallJanuaryInterference";
load(fullfile(campaign, 'runTimeTable1'))

for i = 1:size(runTimeTable, 2)-1
    figure
    boxplot(runTimeTable{:, end}, runTimeTable{:, i})
    xlabel(runTimeTable.Properties.VariableNames{i})
    ylabel('Run-time [s]')
    grid on
    grid minor
end