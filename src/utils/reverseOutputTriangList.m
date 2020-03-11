function triangList = reverseOutputTriangList(triangList)
triangList = cellfun(@fliplr, triangList, 'UniformOutput', false);
end