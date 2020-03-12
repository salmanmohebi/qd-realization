function qdFiles = readAllQdFiles(scenarioPath)
qdFilesList = dir(fullfile(scenarioPath, 'Output/Ns3/QdFiles'));

qdFiles = {};
for i = 1:length(qdFilesList)
    tok = regexp(qdFilesList(i).name, 'Tx(.+)Rx(.+)\.txt','tokens');
    if isempty(tok)
        continue
    end
    
    tx = str2double(tok{1}{1}) + 1;
    rx = str2double(tok{1}{2}) + 1;
    qdFiles{tx, rx} = readQdFile(fullfile(qdFilesList(i).folder, qdFilesList(i).name));
end

end