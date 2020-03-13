function [output, cursorOutput, outputPre, outputPost] =...
    singleReflectionQdGenerator(inRayOutput, materialId, materialLibrary,...
    losDelay, minPgThreshold)
%SINGLEREFLECTIONQDGENERATOR Generate diffused components starting from a
%deterministic ray on a single reflector following NIST's
%Quasi-Deterministic model.


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

assert(size(inRayOutput, 1) == 1, 'QD generator only works on single rays')

if inRayOutput(1) == 0
    % no diffused components for LoS ray
    cursorOutput = inRayOutput;
    outputPre = [];
    outputPost = [];
    output = cursorOutput;
    return;
end

% Add randomness to deterministic reflection loss
cursorOutput = inRayOutput;
cursorOutput(9) = getRandomPg0(inRayOutput, materialId, materialLibrary);

% Pre/post cursors output
outputPre = getQdOutput(cursorOutput, materialId, materialLibrary,...
    losDelay, minPgThreshold, 'pre');
outputPost = getQdOutput(cursorOutput, materialId, materialLibrary,...
    losDelay, minPgThreshold, 'post');

output = [outputPre; cursorOutput; outputPost];

end


%% Utils
function pg = getRandomPg0(inRayOutput, materialId, materialLibrary)
% Baseline: deterministic path gain
pg = inRayOutput(9);
    
sRl = materialLibrary.s_RL(materialId);
sigmaRl = materialLibrary.sigma_RL(materialId);
rl = rndRician(sRl, sigmaRl, 1, 1);

muRl = materialLibrary.mu_RL(materialId);
pg = pg - (rl - muRl);

end


function output = getQdOutput(inRayOutput, materialId, materialLibrary,...
    losDelay, minPgThreshold, prePostParam)
params = getParams(materialId, materialLibrary, prePostParam);

% delays
tau0 = inRayOutput(8); % main cursor's delay [s]
pg0db = inRayOutput(9); % main cursor's path gain [dB]
aodAzCursor = inRayOutput(10); % main cursor's AoD azimuth [deg]
aodElCursor = inRayOutput(11); % main cursor's AoD elevation [deg]
aoaAzCursor = inRayOutput(12); % main cursor's AoA azimuth [deg]
aoaElCursor = inRayOutput(13); % main cursor's AoA elevation [deg]

lambda = rndRician(params.s_lambda, params.sigma_lambda, 1, 1) * 1e9; % [1/s]

if isnan(lambda) || lambda == 0
    % No pre/post cursors
    output = [];
    return;
end

interArrivalTime = rndExp(lambda, params.nRays, 1); % [s]
taus = tau0 + params.delayMultiplier*cumsum(interArrivalTime); % [s]
taus(taus < losDelay) = [];
params.nRays = length(taus);

% path gains
Kdb = rndRician(params.s_K, params.sigma_K, 1, 1); % [dB]
gamma = rndRician(params.s_gamma, params.sigma_gamma, 1, 1) * 1e-9; % [s]
sigmaS = rndRician(params.s_sigmaS, params.sigma_sigmaS, 1, 1); % [std.err in exp]

s = sigmaS * randn(params.nRays, 1);
pg = pg0db - Kdb + 10*log10(exp(1)) * (-abs(taus - tau0)/gamma + s);

% Remove MPCs with more power than main cursor or below minimum path gain
% thresholds
removeMpcMask = pg >= pg0db & pg < minPgThreshold;
taus(removeMpcMask) = [];
pg(removeMpcMask) = [];
params.nRays = length(taus);

% angle spread
aodAzimuthSpread = rndRician(params.s_sigmaAlphaAz, params.sigma_sigmaAlphaAz, 1, 1);
aodElevationSpread = rndRician(params.s_sigmaAlphaEl, params.sigma_sigmaAlphaEl, 1, 1);
aoaAzimuthSpread = rndRician(params.s_sigmaAlphaAz, params.sigma_sigmaAlphaAz, 1, 1);
aoaElevationSpread = rndRician(params.s_sigmaAlphaEl, params.sigma_sigmaAlphaEl, 1, 1);
[aodAz, aodEl] = getDiffusedAngles(aodAzCursor, aodElCursor,...
    aodAzimuthSpread, aodElevationSpread, params.nRays);
[aoaAz, aoaEl] = getDiffusedAngles(aoaAzCursor, aoaElCursor,...
    aoaAzimuthSpread, aoaElevationSpread, params.nRays);

% Combine results into output matrix
phase = rand(params.nRays, 1) * 2*pi;
dopplerShift = zeros(params.nRays, 1);
output = fillOutputQd(taus, pg, aodAz, aodEl, aoaAz, aoaEl, phase, dopplerShift);

end


function params = getParams(materialId, materialLibrary, prePostParam)

switch(prePostParam)
    case 'pre'
        params.s_K = materialLibrary.s_K_Precursor(materialId);
        params.sigma_K = materialLibrary.sigma_K_Precursor(materialId);
        params.s_gamma = materialLibrary.s_gamma_Precursor(materialId);
        params.sigma_gamma = materialLibrary.sigma_gamma_Precursor(materialId);
        params.s_sigmaS = materialLibrary.s_sigmaS_Precursor(materialId);
        params.sigma_sigmaS = materialLibrary.sigma_sigmaS_Precursor(materialId);
        params.s_lambda = materialLibrary.s_lambda_Precursor(materialId);
        params.sigma_lambda = materialLibrary.sigma_lambda_Precursor(materialId);
        params.delayMultiplier = -1;
        params.nRays = 3;
        
    case 'post'
        params.s_K = materialLibrary.s_K_Postcursor(materialId);
        params.sigma_K = materialLibrary.sigma_K_Postcursor(materialId);
        params.s_gamma = materialLibrary.s_gamma_Postcursor(materialId);
        params.sigma_gamma = materialLibrary.sigma_gamma_Postcursor(materialId);
        params.s_sigmaS = materialLibrary.s_sigmaS_Postcursor(materialId);
        params.sigma_sigmaS = materialLibrary.sigma_sigmaS_Postcursor(materialId);
        params.s_lambda = materialLibrary.s_lambda_Postcursor(materialId);
        params.sigma_lambda = materialLibrary.sigma_lambda_Postcursor(materialId);
        params.delayMultiplier = 1;
        params.nRays = 16;
        
    otherwise
        error('prePostParam=''%s''. Should be ''pre'' or ''post''', prePostParam)
end

params.s_sigmaAlphaAz = materialLibrary.s_sigmaAlphaAz(materialId);
params.sigma_sigmaAlphaAz = materialLibrary.sigma_sigmaAlphaAz(materialId);
params.s_sigmaAlphaEl = materialLibrary.s_sigmaAlphaEl(materialId);
params.sigma_sigmaAlphaEl = materialLibrary.sigma_sigmaAlphaEl(materialId);

end


function [az, el] = getDiffusedAngles(azCursor, elCursor,...
    azimuthSpread, elevationSpread, nRays)
az = rndLaplace(azCursor, azimuthSpread, nRays, 1);
el = rndLaplace(elCursor, elevationSpread, nRays, 1);
[az, el] = wrapAngles(az, el);

end


function [az, el] = wrapAngles(az, el)
% If elevation is negative, bring it back in [0,180] and rotate azimuth by
% half a turn
negativeElMask = el < 0;
el(negativeElMask) = -el(negativeElMask);
az(negativeElMask) = az(negativeElMask) + 180;

% If elevation is over 180, bring it back in [0,180] and rotate azimuth by
% half a turn
over180ElMask = el > 180;
el(over180ElMask) = 360 - el(over180ElMask);
az(over180ElMask) = az(over180ElMask) + 180;

% Wrap azimuth to [0,360)
az = mod(az, 360);

end