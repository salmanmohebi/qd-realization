clear
close all
clc

%%
load('dlPdcpStats.mat')

targetCellId = 1;
targetRnti = 1;

%% Process dlPdcpStats
scenarios = getScenarios(dimension_labels{1}.scenario);
rows = ["Time", "CellId", "RNTI", "packetSize", "delay"];

for i = 1:length(scenarios)
    % reduce unused dimensions
    dlPdcpStats{i} = vertcat(results{1,i,1,1,1,1,1,:});
    
    dlPdcpStats{i}(rows == "delay", :) = dlPdcpStats{i}(rows == "delay", :) / 1e6; % ns to ms
    % select CellId and RNTI
    if ~isempty(dlPdcpStats{i})
        dlPdcpStats{i} = dlPdcpStats{i}(:, dlPdcpStats{i}(rows == "CellId",:) == targetCellId & dlPdcpStats{i}(rows == "RNTI",:) == targetRnti);
    end
end

statsTab = processDlPdcpStats(dlPdcpStats, scenarios, rows);

%% plot
timeFig = figure();
cdfFig = figure();
for i = 1:length(dlPdcpStats)
    res = dlPdcpStats{i};
    scenario = scenarios{i};
    
    if ~isempty(res)
        plotName = strrep(scenario, '_', '\_');
        
        figure(timeFig)
        plot(res(1, :), res(5, :), 'DisplayName', plotName); hold on
        
        figure(cdfFig)
        [y,x] = ecdf(res(5, :));
        plot(x, y, 'DisplayName', plotName); hold on
    end
end

figure(timeFig)
xlabel('t [s]')
ylabel('delay [ms]')
legend('show', 'Location', 'best')

figure(cdfFig)
xlabel('x = delay [ms]')
ylabel('F(x)')
legend('show', 'Location', 'best')

%% plot stats
% mean delays
figure % refl
boxplot(statsTab.meanDelay, statsTab.refl);
xlabel('Number of reflection')
ylabel('Mean delay [ms]')

figure % qd
boxplot(statsTab.meanDelay, statsTab.qd);
xlabel('QD switch')
ylabel('Mean delay [ms]')

figure % relTh
boxplot(statsTab.meanDelay, statsTab.relTh);
xlabel('Relative Threshold [dB]')
ylabel('Mean delay [ms]')

% mean delays
figure % refl
boxplot(statsTab.maxDelay, statsTab.refl);
xlabel('Number of reflection')
ylabel('Max delay [ms]')

figure % qd
boxplot(statsTab.maxDelay, statsTab.qd);
xlabel('QD switch')
ylabel('Max delay [ms]')

figure % relTh
boxplot(statsTab.maxDelay, statsTab.relTh);
xlabel('Relative Threshold [dB]')
ylabel('Max delay [ms]')

% throughput
figure % refl
boxplot(statsTab.throughput, statsTab.refl);
xlabel('Number of reflection')
ylabel('Throughput [Mbps]')

figure % qd
boxplot(statsTab.throughput, statsTab.qd);
xlabel('QD switch')
ylabel('Throughput [Mbps]')

figure % relTh
boxplot(statsTab.throughput, statsTab.relTh);
xlabel('Relative Threshold [dB]')
ylabel('Throughput [Mbps]')

% ns-3 sim time
figure % refl
boxplot(statsTab.simTime, statsTab.refl);
xlabel('Number of reflection')
ylabel('Ns-3 simulation time [s]')

figure % qd
boxplot(statsTab.simTime, statsTab.qd);
xlabel('QD switch')
ylabel('Ns-3 simulation time [s]')

figure % relTh
boxplot(statsTab.simTime, statsTab.relTh);
xlabel('Relative Threshold [dB]')
ylabel('Ns-3 simulation time [s]')

%% utils
function scenarios = getScenarios(scenarioStr)
scenarioStr = scenarioStr(2:end-1);
scenarioStr = strrep(scenarioStr,'''',''); % remove '
scenarios = split(scenarioStr, ', ');
end


function statsTab = processDlPdcpStats(dlPdcpStats, scenarios, rows)

load('ns3SimTime.mat')

statsTab = table();
for i = 1:length(scenarios)
    tab = getScenarioTab(scenarios{i});
    
    tab.minDelay = min(dlPdcpStats{i}(rows == "delay", :));
    tab.maxDelay = max(dlPdcpStats{i}(rows == "delay", :));
    tab.medianDelay = median(dlPdcpStats{i}(rows == "delay", :));
    tab.meanDelay = mean(dlPdcpStats{i}(rows == "delay", :));
    
    tab.throughput = sum(dlPdcpStats{i}(rows == "packetSize", :)) / dlPdcpStats{i}(rows == "Time", end);
    tab.throughput = tab.throughput * 8 / 1e6; % Bps to Mbps
    
    tab.simTime = results(i);
    
    statsTab = [statsTab; tab];
end

end


function tab = getScenarioTab(scenario)

t = regexp(scenario, 'refl(.+)_qd(.+)_relTh(.+)_floor(.+)', 'tokens');

refl = str2double(t{1}{1});
qd = str2double(t{1}{2});
relTh = str2double(t{1}{3});
floor = t{1}(4);

tab = table(refl, qd, relTh, floor);

end