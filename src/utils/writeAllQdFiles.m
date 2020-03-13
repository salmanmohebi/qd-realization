function writeAllQdFiles(qdFiles, folderPath, precision)

assert(size(qdFiles, 1) == size(qdFiles, 2))
numNodes = size(qdFiles, 1);

for txIdx = 1:numNodes
    for rxIdx = 1:numNodes
        if txIdx == rxIdx
            continue
        end
        
        filename = sprintf('Tx%dRx%d.txt', txIdx-1, rxIdx-1);
        filepath = fullfile(folderPath, filename);
        writeQdFile(qdFiles{txIdx, rxIdx}, filepath, precision);
    end
end

end