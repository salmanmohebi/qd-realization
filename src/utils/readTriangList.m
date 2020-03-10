function out = readTriangList(path)
%READQDFILE Function that extracts the QD file from the
% output file, as described by the documentation).
% NOTE: unlike READQDFILE, sorting is not supported
%
% INPUTS:
% - path: file path. This could be either and absolute path, or a relative
% path, starting at least from the Output/ folder.
%
% OUTPUTS:
% - out: a cell array containing the TriangList. The first index refers to
% the timestep, the second one to the ray idx of a given timestep
%
% SEE ALSO: ISTRIANGLIST


% Copyright (c) 2020, University of Padova, Department of Information
% Engineering, SIGNET lab.
%
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
%
%    http://www.apache.org/licenses/LICENSE-2.0
%
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.


fid = fopen(path,'r');
assert(fid ~= -1,...
    'File path ''%s'' not valid', path)

i = 1;
out = {};
while ~feof(fid)
    % Each timestep is delimited by a number, indicating the number of rays
    % in that timestep, i.e., how many rows have to be read before the next
    % cluster
    line = fgetl(fid);
    numRays = sscanf(line,'%d');

    out{i} = importTriangLists(fid, numRays);
    
    i = i+1;
end

fclose(fid);

end

%% Utils
function out = importTriangLists(fid, numRays)

if numRays==0
    % if there are no rays, return empty cell
    out = {};
    return
end

out = cell(1, numRays);
for i = 1:numRays
    line = fgetl(fid);
    out{i} = str2num(line); %#ok<ST2NM>, extracting vectors
end

end