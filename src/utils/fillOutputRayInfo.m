function output = fillOutputRayInfo(rayInfo)
%FILLOUTPUTRAYINFO Systematically creates a consistent output vector from
%its rayInfo structure.
%
%SEE ALSO: FILLOUTPUT


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

nOut = 1;

% Compute missing outputs
dod = nan(nOut, 3);
doa = nan(nOut, 3);
txPolarization = nan(nOut, 4);
xPolPathGain = nan(nOut, 1);
dopplerFreq = nan(nOut, 1);

output = fillOutput(rayInfo.reflOrder, dod, doa, rayInfo.delay,...
    rayInfo.pathGain, [rayInfo.aodAz, rayInfo.aodEl],...
    [rayInfo.aoaAz, rayInfo.aoaEl], txPolarization, rayInfo.phaseOffset,...
    xPolPathGain, dopplerFreq);

end