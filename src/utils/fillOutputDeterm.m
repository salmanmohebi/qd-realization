function output = fillOutputDeterm(reflOrder, dod, doa, rayLen, pathGain,...
    dopplerFactor, freq)
%FILLOUTPUTDETERM Systematically creates a consistent output vector for a 
%given deterministic ray.
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

% Compute missing outputs
delay = rayLen / 299792458; % c0 = 299,792,458 [m/s]

aodAz = mod(atan2d(dod(2), dod(1)), 360);
aodEl = acosd(dod(3) / norm(dod));
aoaAz = mod(atan2d(doa(2), doa(1)), 360);
aoaEl = acosd(doa(3) / norm(doa));

txPolarization = nan(1, 4);

reflPhaseShift = reflOrder * pi;

xPolPathGain = NaN;

dopplerFreq = dopplerFactor * freq;

output = fillOutput(reflOrder, dod, doa, delay, pathGain,...
    [aodAz, aodEl], [aoaAz, aoaEl], txPolarization, reflPhaseShift,...
    xPolPathGain, dopplerFreq);

end