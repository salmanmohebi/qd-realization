clear
close all
clc

%%
campaign = "IwcmcParkingLot";
rtNetMatFile = 'matlab_stats_16_1.mat';
load(fullfile(campaign, rtNetMatFile))

ratio = 'SINR';

%% MATLAB RT-Net
tFig = figure();
cdfFig = figure();
capacityFig = figure();

for i = length(rtNetResults):-1:1
    if ~contains(rtNetResults(i).scenario, 'relTh-Inf')
        continue
    end
    
    plotName = strrep(rtNetResults(i).scenario, '_', '\_');
    
    figure(tFig)
    plot(rtNetResults(i).([ratio, '_db']), 'DisplayName', plotName); hold on
    
    figure(cdfFig)
    [y, x] = ecdf(rtNetResults(i).([ratio, '_db']));
    plot(x, y, 'DisplayName', plotName); hold on
    
    figure(capacityFig)
    [y, x] = ecdf(log2(1 + db2pow(rtNetResults(i).([ratio, '_db']))));
    plot(x, y, 'DisplayName', plotName); hold on
    
end
figure(tFig)
xlabel('t [timestep]')
ylabel([ratio, ' [dB]'])
legend('show', 'Location', 'best')

figure(cdfFig)
xlabel(['x = ', ratio, ' [dB]'])
ylabel('F(x)')
legend('show', 'Location', 'best')

figure(capacityFig)
xlabel('x = Capacity [bit/s/Hz]')
ylabel('F(x)')
legend('show', 'Location', 'best')
