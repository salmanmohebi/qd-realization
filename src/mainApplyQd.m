% clear
% close all
% clc

addpath('utils', 'raytracer')
%%
scenario = 'ScenarioTest';
qdGeneratorFunc = @completeMultipleReflectionQdGenerator;

% Import Output files
qdFiles = readAllQdFiles(scenario);
triangLists = readAllTriangLists(scenario);
nodesPosition = readAllNodesPositions(scenario);

paramCfg = parameterCfg(scenario);

% Import material library
% Working directory might be different, reset it to src/
matLibraryPath = paramCfg.materialLibraryPath;
startPathIdx = strfind(matLibraryPath, 'material_libraries/');
matLibraryPath = matLibraryPath(startPathIdx:end);

materialLibrary = importMaterialLibrary(matLibraryPath);

% Import cadData
[cadData, switchMaterial] = getCadOutput(...
    paramCfg.environmentFileName,...
    fullfile(scenario, 'Input'),...
    materialLibrary,...
    paramCfg.referencePoint,...
    paramCfg.selectPlanesByDist,...
    paramCfg.indoorSwitch);

%% post-processing
if switchMaterial
    qdFilesOut = applyQd(qdFiles, triangLists, nodesPosition, cadData,...
        materialLibrary, paramCfg, qdGeneratorFunc);
end

%% write to file
qdFolderPath = fullfile(scenario, 'Output/Ns3/QdFiles_QD');
mkdir(qdFolderPath)
writeAllQdFiles(qdFilesOut, qdFolderPath, 6);