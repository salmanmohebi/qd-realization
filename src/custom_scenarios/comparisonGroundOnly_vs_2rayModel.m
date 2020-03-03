clear
close all
% clc


%% Math model params
f = 60e9; % Hz
reflLoss = 0; % dB

ht = 2.9;
hr = 1.5;

lambda = physconst('LightSpeed')/f;

Gamma = - 10^(-reflLoss / 20);


%% Math model
dLos = @(d) sqrt(d.^2 + (ht-hr)^2);
dRefl = @(d) sqrt(d.^2 + (ht+hr)^2);
phi = @(d) 2*pi*(dRefl(d) - dLos(d))/lambda;

Pr = @(d) (lambda/(4*pi))^2 * abs(exp(-1j*2*pi*dLos(d)/lambda)./dLos(d) + Gamma*exp(-1j*2*pi*dRefl(d)/lambda)./dRefl(d)).^2;


%% Simulation
campaign = "Journal1GroundOnly";
scenario = "refl1_qd0_relTh-Inf_floorPec";
filename = fullfile(campaign, "matlab_stats_1_1_SVD.mat");

load(filename)

% extract results
scenarioMask = {rtNetResults.scenario} == scenario;
results = rtNetResults(scenarioMask);

% Nodes positions
rxPos = csvread(fullfile(campaign, "Input", "NodePosition1.dat"));
txPos = csvread(fullfile(campaign, "Input", "NodePosition2.dat"));
% remove last position as it is ignored by the RT
rxPos(end, :) = [];
txPos(end, :) = [];

dist2d = vecnorm(rxPos(:, 1:2) - txPos(:, 1:2), 2, 2);
pgSim = results.Prx_dbm - params.Ptx;


%% Plots
dLim = [0.01, 18.8];

% line plot comparison
figure
fplot(@(d) pow2db(Pr(d)), dLim, 'DisplayName', 'Math. Model'); hold on
plot(dist2d, pgSim, 'DisplayName', 'Simulation'); hold on

legend('show', 'Location', 'best')
xlabel('Distance [m]')
ylabel('Path Gain [dB]')
set(gca, 'XScale', 'log')
xlim(dLim)

% point-wise error
mathModelPowerSampled = pow2db(Pr(dist2d));
error = mathModelPowerSampled - pgSim;

figure
% stem
subplot(1,2,1)
stem(dist2d, error)

xlabel('Distance [m]')
ylabel('Path Gain Error [dB]')
set(gca, 'XScale', 'log')
xlim(dLim)

% histogram
subplot(1,2,2)
histogram(error)

xlabel('Path Gain Error [dB]')
ylabel('Bin Count')
xlim([-2, 2])