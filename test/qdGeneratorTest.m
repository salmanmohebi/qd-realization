clear
close all
clc

cd('../src')
addpath('raytracer', 'utils')

%% Dummy setup
%%%% LoS
dRayOutput = [0,... refl. order
    nan, nan, nan,... DoD
    nan, nan, nan,... DoA
    10e-9,... delay
    -80,... path gain
    0, 90,... AoD Az, El
    0, 90,... AoA Az, El
    nan, nan,... PolarizationTx
    nan, nan,... PolarizationRx
    pi,... reflected phase
    nan,... X-Pol path gain
    0,... doppler phase shift
    0]; % ?

arrayOfMaterials = [6];
lastMatIdx = arrayOfMaterials(end);

materialLibrary = readtable('material_libraries/LectureRoomAllMaterials.csv');
materialLibrary.Reflector = string(materialLibrary.Reflector);

out = qdGenerator(dRayOutput, arrayOfMaterials, materialLibrary);

assert(size(out, 1) == 1, 'LoS ray should not have any additional diffused components')

% Reflections
dRayOutput(1) = 1;
[out, cursorOut] = qdGenerator(dRayOutput, arrayOfMaterials, materialLibrary);

%% Plots
titleStr = sprintf('Last material: `%s'', ID: %d',...
    materialLibrary.Reflector(lastMatIdx), lastMatIdx);

% PG vs tau
figure
scatter(out(:, 8) * 1e9, out(:, 9)); hold on
scatter(cursorOut(:, 8) * 1e9, cursorOut(:, 9)); hold off
xlabel('$\tau$ [ns]')
ylabel('Path gain [dB]')
title(titleStr)
legend('MPCs', 'Cursor', 'Location', 'best')

% AoD
figure
scatter(out(:, 10), out(:, 11)); hold on
scatter(cursorOut(:, 10), cursorOut(:, 11)); hold off
xlabel('AoD azimuth [deg]')
ylabel('AoD elevation [deg]')
title(titleStr)
xlim([0, 360])
ylim([0, 180])
set(gca, 'XTick', 0:45:360)
set(gca, 'YTick', 0:45:180)
legend('MPCs', 'Cursor', 'Location', 'best')

% AoA
figure
scatter(out(:, 12), out(:, 13)); hold on
scatter(cursorOut(:, 12), cursorOut(:, 13)); hold off
xlabel('AoA azimuth [deg]')
ylabel('AoA elevation [deg]')
title(titleStr)
xlim([0, 360])
ylim([0, 180])
set(gca, 'XTick', 0:45:360)
set(gca, 'YTick', 0:45:180)
legend('MPCs', 'Cursor', 'Location', 'best')

%%
cd('../test')