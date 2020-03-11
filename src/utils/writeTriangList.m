function writeTriangList(triangList, useOptimizedOutputToFile,...
    fids, iTx, iRx, triangListPath)

if ~useOptimizedOutputToFile
    filename = sprintf('Tx%dRx%d.txt', iTx - 1, iRx - 1);
    filepath = fullfile(triangListPath, filename);
    fid = fopen(filepath, 'A');
else
    fid = fids(iTx, iRx);
end
    

numRays = length(triangList);
fprintf(fid, '%d\n', numRays);

if isempty(triangList)
    return
end

for i = 1:numRays
    list = triangList{i};
    
    if length(list) > 1
        fprintf(fid, '%d,', list(1:end-1));
    end
    fprintf(fid, '%d\n', list(end));
    
end

if ~useOptimizedOutputToFile
    fclose(fid);
end

end