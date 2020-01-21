function visibilityMatrix = getVisibilityMatrix(cadOutput)
%GETVISIBILITYMATRIX Create the sparse visibility matrix of the given
%cadOutput. Each element (i,j) contains true iff triangle(j) (i.e.,
%cadOutput(j,:)) is in front of triangle(i).
%Thus, row (i) contains true values in columns (j) corresponding to 
%triangles in front of (i).
%Instead, column (i) contains true values in rows (j) corresponding to
%triangles (j) for which (i) is in front of.
%
% SEE ALSO: ISTRIANGLEINFRONTOFTRIANGLE
nTriangles = size(cadOutput,1);

rows = [];
cols = [];

for i = 1:nTriangles
    t1 = cadOutput(i,:);
    for j = [1:i-1, i+1:nTriangles] % Avoid corner case t1=t2
        t2 = cadOutput(j,:);
        
        isVisible = isTriangleInFrontOfTriangle(t2, t1, true);
        
        if isVisible
            rows = [rows, i];
            cols = [cols, j];
        end
        
        
    end
end

visibilityMatrix = sparse(rows, cols, true(size(rows)));

end