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

%%% NLoS
dRayOutput(1) = 1;
[out, cursorOut] = qdGenerator(dRayOutput, arrayOfMaterials, materialLibrary);

% Plots
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

%% Real setup
scenarioName = 'examples/Indoor1';
Tx = 0;
Rx = 1;

qdFile = readQdFile(sprintf('%s/Output/Ns3/QdFiles/Tx%dRx%d.txt',...
    scenarioName, Tx, Rx));
qdFile1 = qdFile(1);

% TODO: check materials for this scenario
materialLibrary = readtable('material_libraries/LectureRoomAllMaterials.csv');
materialLibrary.Reflector = string(materialLibrary.Reflector);

reflOrder = [0; ones(6, 1); 2*ones(qdFile1.numRays - 6 - 1, 1)]; % assumes box scenario (e.g., examples/Indoor1)

allDRaysOutput = [reflOrder,... refl. order
    nan(qdFile1.numRays, 3),... DoD
    nan(qdFile1.numRays, 3),... DoA
    qdFile1.delay.',... delay
    qdFile1.pathGain.',... path gain
    qdFile1.aodAz.',... AoD Az
    qdFile1.aodEl.',... AoD El
    qdFile1.aoaAz.',... AoA Az
    qdFile1.aoaEl.',... AoA El
    nan(qdFile1.numRays, 2),... PolarizationTx
    nan(qdFile1.numRays, 2),... PolarizationRx
    reflOrder * pi,... reflected phase
    nan(qdFile1.numRays, 1),... X-Pol path gain
    zeros(qdFile1.numRays, 1),... doppler phase shift
    zeros(qdFile1.numRays, 1)]; % ?

allQdRaysOutput = [];
allCursorsOutput = [];
for i = 1:size(allDRaysOutput, 1)
    dRayOutput = allDRaysOutput(i, :);
    arrayOfMaterials = randi(size(materialLibrary, 1));
    
    [out, cursorOut] = qdGenerator(dRayOutput, arrayOfMaterials, materialLibrary);
    allQdRaysOutput = [allQdRaysOutput; out];
    allCursorsOutput = [allCursorsOutput; cursorOut];
end

% Plots
titleStr = scenarioName;

% PG vs tau - D-Rays
figure
scatter(allDRaysOutput(:, 8) * 1e9, allDRaysOutput(:, 9))
xlabel('$\tau$ [ns]')
ylabel('Path gain [dB]')
title(titleStr)
legend('D-Rays', 'Location', 'best')

% PG vs tau - QD
figure
scatter(allQdRaysOutput(:, 8) * 1e9, allQdRaysOutput(:, 9)); hold on
scatter(allCursorsOutput(:, 8) * 1e9, allCursorsOutput(:, 9)); hold off
xlabel('$\tau$ [ns]')
ylabel('Path gain [dB]')
title(titleStr)
legend('MPCs', 'Cursors', 'Location', 'best')

% AoD
figure
scatter(allQdRaysOutput(:, 10), allQdRaysOutput(:, 11)); hold on
scatter(allCursorsOutput(:, 10), allCursorsOutput(:, 11)); hold off
xlabel('AoD azimuth [deg]')
ylabel('AoD elevation [deg]')
title(titleStr)
xlim([0, 360])
ylim([0, 180])
set(gca, 'XTick', 0:45:360)
set(gca, 'YTick', 0:45:180)
legend('MPCs', 'Cursors', 'Location', 'best')

% AoA
figure
scatter(allQdRaysOutput(:, 12), allQdRaysOutput(:, 13)); hold on
scatter(allCursorsOutput(:, 12), allCursorsOutput(:, 13)); hold off
xlabel('AoA azimuth [deg]')
ylabel('AoA elevation [deg]')
title(titleStr)
xlim([0, 360])
ylim([0, 180])
set(gca, 'XTick', 0:45:360)
set(gca, 'YTick', 0:45:180)
legend('MPCs', 'Cursors', 'Location', 'best')

%%
cd('../test')