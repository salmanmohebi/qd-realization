clear
close all
clc

%% Math model parameters
f = 60e9; % Hz
reflectionLoss = 0; % dB
ht = 2.9;
hr = 1.5;

lambda = 3e8/f;
Gamma = - 10^(reflectionLoss/10);

%% Math model
dLos = @(d) sqrt(d.^2 + (ht-hr)^2);
dRefl = @(d) sqrt(d.^2 + (ht+hr)^2);
phi = @(d) 2*pi*(dRefl(d) - dLos(d))/lambda;

Pr = @(d) (lambda/(4*pi))^2 * abs(1./dLos(d) + Gamma*exp(-1j*phi(d))./dRefl(d)).^2;

%% Plot
dLim = [0.01, 20];

figure
fplot(@(d) pow2db(Pr(d)), dLim, 'DisplayName', 'Mathematical Model'); hold off

xlabel('distance [m]')
ylabel('Path Gain [dB]')
set(gca, 'XScale', 'log')