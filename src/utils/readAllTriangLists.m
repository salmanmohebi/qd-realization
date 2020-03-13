function triangLists = readAllTriangLists(scenarioPath)
triangListFiles = dir(fullfile(scenarioPath, 'Output/TriangList'));

triangLists = {};
for i = 1:length(triangListFiles)
    tok = regexp(triangListFiles(i).name, 'Tx(.+)Rx(.+)\.txt','tokens');
    if isempty(tok)
        continue
    end
    
    tx = str2double(tok{1}{1}) + 1;
    rx = str2double(tok{1}{2}) + 1;
    triangLists{tx, rx} = readTriangList(fullfile(triangListFiles(i).folder, triangListFiles(i).name));
end

end