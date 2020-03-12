function qdFileOut = applyQdToTimestep(qdFileIn, triangList, nodesPosition, cadData, materialLibrary, paramCfg)
% extract time-step information
% LoS delay
nodesDistance = nodesPosition{2} - nodesPosition{1};
losDelay = norm(nodesDistance) / physconst('LightSpeed');

% Threshold for minimum path gain
minPgThreshold = -Inf;

% init
qdArrayOut = nan(qdFileIn.numRays * 20, 21);
qdOutLastIdx = 0;

for i = 1:qdFileIn.numRays
    rayInfo = struct('pathGain', qdFileIn.pathGain(i),...
        'delay', qdFileIn.delay(i),...
        'phaseOffset', qdFileIn.phaseOffset(i),...
        'aodAz', qdFileIn.aodAz(i),...
        'aodEl', qdFileIn.aodEl(i),...
        'aoaAz', qdFileIn.aoaAz(i),...
        'aoaEl', qdFileIn.aoaEl(i),...
        'reflOrder', length(triangList{i}));
    
    qdArray = fillOutputRayInfo(rayInfo);
    
    if rayInfo.reflOrder > 0
        % Reflected ray: generate QD
        arrayOfMaterials = cadData(triangList{i}, 14);
        qdArray = reducedMultipleReflectionQdGenerator(qdArray, arrayOfMaterials, materialLibrary, losDelay, minPgThreshold);
    end
    
    % Add new rays
    numMpcs = size(qdArray, 1);
    qdArrayOut(qdOutLastIdx+1:qdOutLastIdx+numMpcs, :) = qdArray;
    qdOutLastIdx = qdOutLastIdx + numMpcs;
    
end

qdArrayOut = qdArrayOut(1:qdOutLastIdx, :);
qdFileOut = qdArray2Struct(qdArrayOut);

end


%% UTILS
function intersectTriangIdx = findIntersectedTriang(cadData, visibilityMatrix, nodePos, direction)

for triangIdx = 1:size(cadData, 1)
    a = cadData(triangIdx, 1:3);
    b = cadData(triangIdx, 4:6);
    c = cadData(triangIdx, 7:9);
    planeEq = cadData(triangIdx, 10:13);
    
    intersection = planeIntersectsHalfLine(planeEq, nodePos, direction, false);
    if ~isempty(intersection) &&... % intersecting the plane in the right direction
            pointInTriangle(intersection, a, b, c) &&... % intersecting the triangle
            ~isRayObstructed(nodePos, intersection, cadData, visibilityMatrix, triangIdx)
        
        intersectTriangIdx = triangIdx;
        return
    end
end

error('No valid intersecting triangle found')

end


function qStruct = qdArray2Struct(qdArray)
qStruct = struct('numRays', size(qdArray, 1),...
        'pathGain', qdArray(:, 9),...
        'delay', qdArray(:, 8),...
        'phaseOffset', qdArray(:, 18),...
        'aodAz', qdArray(:, 10),...
        'aodEl', qdArray(:, 11),...
        'aoaAz', qdArray(:, 12),...
        'aoaEl', qdArray(:, 13));
end