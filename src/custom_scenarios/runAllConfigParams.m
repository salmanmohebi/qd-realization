clear
close all
clc

addpath('../..') % add src folder to path

%% Parameters
campaign = "NistCallJanuaryInterference";

reflList = [1, 2, 3];
switchQdList = [0, 1];
relThList = [-Inf, -40, -25, -15];
floorList = ["Metal", "Ceiling"];

%% Loop over all combinations of parameters
tableVarNames = {'totalNumberOfReflections', 'switchQDGenerator',...
    'minRelativePathGainThreshold', 'floorMaterial', 'runTime'};
runTimeTable = table('Size',[0, length(tableVarNames)],...
    'VariableTypes', ["double", "double", "double", "string", "double"],...
    'VariableNames', tableVarNames);

for refl = reflList
    for switchQd = switchQdList
        for relTh = relThList
            for floorMaterial = floorList
                % setup scenario folder
                scenarioName = sprintf('refl%d_qd%d_relTh%.0f_floor%s',...
                    refl, switchQd, relTh, floorMaterial);
                scanarioPath = fullfile(pwd, campaign, scenarioName);
                
                try
                    rmdir(scanarioPath, 's')
                catch
                end
                mkdir(scanarioPath)
                copyfile(fullfile(campaign, 'Input'), fullfile(scanarioPath, 'Input'), 'f')
                
                % change cfg file
                cfgFilePath = fullfile(scanarioPath, 'Input', 'paraCfgCurrent.txt');
                updateCfgFile(cfgFilePath, 'totalNumberOfReflections', refl);
                updateCfgFile(cfgFilePath, 'switchQDGenerator', switchQd);
                updateCfgFile(cfgFilePath, 'minRelativePathGainThreshold', relTh);
                updateCfgFile(cfgFilePath, 'materialLibraryPath',...
                    getMaterialLibraryPathFromFloorMaterial(scanarioPath, floorMaterial));
                
                % run raytracer
                t0 = tic;
                launchRaytracer(scanarioPath);
                runTime = toc(t0);
                
                % save run time
                tableRow = table(refl, switchQd, relTh, floorMaterial, runTime,...
                    'VariableNames', tableVarNames);
                runTimeTable(end + 1, :) = tableRow;
                
                save(fullfile(campaign, 'runTimeTable'), 'runTimeTable')
            end
        end
    end
end


%% Utilities
function updateCfgFile(cfgFilePath, parameter, value)
cfgTable = readtable(cfgFilePath, 'Delimiter', '\t');

parameterMask = strcmp(cfgTable{:,1}, parameter);
if nnz(parameterMask) ~= 1
    error('Invalid parameter name')
end

if isnumeric(value)
    value = num2str(value);
end

cfgTable{parameterMask, 2} = {value};

writetable(cfgTable, cfgFilePath, 'Delimiter', '\t');
end


function matLibPath = getMaterialLibraryPathFromFloorMaterial(scanarioPath, floorMaterial)
paraCfg = parameterCfg(scanarioPath);
matLibFolder = fileparts(paraCfg.materialLibraryPath);

switch(floorMaterial)
    case 'Metal'
        matLibName = 'LectureRoomAllMaterialsMetalFloor.csv';
    case 'Ceiling'
        matLibName = 'LectureRoomAllMaterialsCeilingFloor.csv';
    otherwise
        error('Unknown floor material ''%s''', floorMaterial)
end

matLibPath = fullfile(matLibFolder, matLibName);
end