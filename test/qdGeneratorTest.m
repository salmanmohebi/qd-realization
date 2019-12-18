clear
close all
clc

cd('../src')
%% Setup
% LoS
dRayOutput = [0,...
    nan, nan, nan,...
    nan, nan, nan,...
    10e-9,...
    -80,...
    0, 90,...
    0, 90,...
    nan, nan,...
    nan, nan,...
    pi,...
    nan,...
    0,...
    0];

arrayOfMaterials = [6];
lastMatIdx = arrayOfMaterials(end);

materialLibrary = readtable('material_libraries/LectureRoomAllMaterials.csv');
materialLibrary.Reflector = string(materialLibrary.Reflector);

out = qdGenerator(dRayOutput, arrayOfMaterials, materialLibrary);

assert(size(out, 1) == 1, 'LoS ray should not have any additional diffused components')

% Reflections
dRayOutput(1) = 1;
out = qdGenerator(dRayOutput, arrayOfMaterials, materialLibrary);

%% Plots
titleStr = sprintf('Last material: `%s'', ID: %d',...
    materialLibrary.Reflector(lastMatIdx), lastMatIdx);

% PG vs tau
figure(1)
scatter(out(:, 8) * 1e-9, out(:, 9))
xlabel('$\tau$ [ns]')
ylabel('Path gain [dB]')
title(titleStr)

% AoD
figure(2)
scatter(out(:, 10), out(:, 11))
xlabel('AoD azimuth [deg]')
ylabel('AoD elevation [deg]')
title(titleStr)
xlim([0, 360])
ylim([0, 180])
set(gca, 'XTick', 0:45:360)
set(gca, 'YTick', 0:45:180)

% AoA
figure(3)
scatter(out(:, 12), out(:, 13))
xlabel('AoA azimuth [deg]')
ylabel('AoA elevation [deg]')
title(titleStr)
xlim([0, 360])
ylim([0, 180])
set(gca, 'XTick', 0:45:360)
set(gca, 'YTick', 0:45:180)

%%
cd('../test')