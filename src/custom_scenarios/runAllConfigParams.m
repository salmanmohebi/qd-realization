clear
close all
clc

addpath('..') % add src folder to path

%% Parameters
campaign = "Journal1ParkingLot";

reflList = [1, 2, 3];
switchQdList = [0];
relThList = [-Inf, -40, -25, -15];
floorList = ["Ceiling"];

%% parfor setup
parpool(4);

%% Loop over all combinations of parameters
tableVarNames = {'totalNumberOfReflections', 'switchQDGenerator',...
    'minRelativePathGainThreshold', 'floorMaterial', 'runTime'};
runTimeTable = table('Size',[0, length(tableVarNames)],...
    'VariableTypes', ["double", "double", "double", "string", "double"],...
    'VariableNames', tableVarNames);

for refl = reflList
    for switchQd = switchQdList
        for floorMaterial = floorList
            parfor relThIdx = 1:length(relThList)
                relTh = relThList(relThIdx);
                
                partialunTimeTable = table('Size',[0, length(tableVarNames)],...
                    'VariableTypes', ["double", "double", "double", "string", "double"],...
                    'VariableNames', tableVarNames);
                
                % setup scenario folder
                scenarioName = sprintf('refl%d_qd%d_relTh%.0f_floor%s',...
                    refl, switchQd, relTh, floorMaterial);
                scanarioPath = fullfile(pwd, campaign, scenarioName);
                
                try
                    [status, message, messageid] = rmdir(scanarioPath, 's');
                    if ~status
                        warning('%s: %s', messageid, message)
                    end
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
                    getMaterialLibraryPathFromFloorMaterial(scanarioPath, floorMaterial, campaign));
                
                % run raytracer
                t0 = tic;
                launchRaytracer(scanarioPath);
                runTime = toc(t0);
                
                % save run time
                tableRow = table(refl, switchQd, relTh, floorMaterial, runTime,...
                    'VariableNames', tableVarNames);
                partialRunTimeTable(relThIdx, :) = tableRow;
            end
            runTimeTable = [runTimeTable; partialRunTimeTable];
            save(fullfile(campaign, 'runTimeTable'), 'runTimeTable')
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

if strcmp(parameter, 'materialLibraryPath') && isempty(value)
    % do nothing
else
    cfgTable{parameterMask, 2} = {value};
    
    writetable(cfgTable, cfgFilePath, 'Delimiter', '\t');
end
end


function matLibPath = getMaterialLibraryPathFromFloorMaterial(scanarioPath, floorMaterial, campaign)
paraCfg = parameterCfg(scanarioPath);
matLibFolder = fileparts(paraCfg.materialLibraryPath);

switch(campaign)
    case 'Journal1ParkingLot'
        % do nothing
        matLibPath = [];
        
    case {'Journal1Indoor1', 'Journal1Lroom'}
        switch(floorMaterial)
            case 'Metal'
                matLibName = 'LectureRoomAllMaterialsMetalFloor.csv';
            case 'Ceiling'
                matLibName = 'LectureRoomAllMaterialsCeilingFloor.csv';
            otherwise
                error('Unknown floor material ''%s''', floorMaterial)
        end
        matLibPath = fullfile(matLibFolder, matLibName);
        
    otherwise
        error('Campaign ''%s'' not recognized', campaign)
end

end