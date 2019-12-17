function output = qdGenerator(dRayOutput, arrayOfMaterials,...
    materialLibrary)
% output:
% 1. reflection order
% 2:4. DoD
% 5:7. DoA
% 8. delay
% 9. Path Gain
% 10. AoD Azimuth
% 11. AoD Elevation
% 12. AoA Azimuth
% 13. AoA Elevation
%     14:15. PolarizationTx(1,:)
%     16:17. PolarizationTx(2,:)
% 18. phase (reflOrder*pi)
%     19. Cross-pol path gain
% 20. phase (dopplerFactor*freq)
% 21. 0 (?)

if dRayOutput(1) == 0
    % no diffused components for LoS ray
    output = dRayOutput;
    return;
end

% Add randomness to deterministic reflection loss
dRayOutput(9) = getRandomPg0(dRayOutput, arrayOfMaterials, materialLibrary);

% Pre/post cursors output
outputPre = getQdOutput(dRayOutput, arrayOfMaterials, materialLibrary, 'pre');
outputPost = getQdOutput(dRayOutput, arrayOfMaterials, materialLibrary, 'post');

output = [outputPre; dRayOutput; outputPost];

end


%% Utils
function pg = getRandomPg0(dRayOutput, arrayOfMaterials, MaterialLibrary)
warning('TODO: Add randomness to reflection loss of deterministic ray')

% Baseline: deterministic path gain
pg = dRayOutput(9);
for i = 1:length(arrayOfMaterials)
    matIdx = arrayOfMaterials(i);
    
    s_material = MaterialLibrary.s_RL(matIdx);
    sigma_material = MaterialLibrary.sigma_RL(matIdx);
    rl = rndRician(s_material, sigma_material, 1, 1);
    
    muRl = MaterialLibrary.mu_RL(matIdx);
    pg = pg - (rl - muRl);
end

end


function output = getQdOutput(dRayOutput, arrayOfMaterials, MaterialLibrary, prePostParam)
params = getParams(arrayOfMaterials, MaterialLibrary, prePostParam);

% delays
tau0 = dRayOutput(8); % main cursor's delay [s]
pg0db = dRayOutput(9); % main cursor's path gain [dB]
aodAzCursor = dRayOutput(10); % main cursor's AoD azimuth [deg]
aodElCursor = dRayOutput(11); % main cursor's AoD elevation [deg]
aoaAzCursor = dRayOutput(12); % main cursor's AoA azimuth [deg]
aoaElCursor = dRayOutput(13); % main cursor's AoA elevation [deg]

lambda = rndRician(params.s_lambda, params.sigma_lambda, 1, 1) * 1e9; % [1/s]

if isnan(lambda) || lambda == 0
    % No pre/post cursors
    output = [];
    return;
end

interArrivalTime = rndExp(lambda, params.nRays, 1); % [s]
taus = tau0 + params.delayMultiplier*cumsum(interArrivalTime); % [s]
% TODO: remove rays arriving before LoS

% path gains
Kdb = rndRician(params.s_K, params.sigma_K, 1, 1); % [dB]
gamma = rndRician(params.s_gamma, params.sigma_gamma, 1, 1) * 1e-9; % [s]
sigma_s = rndRician(params.s_sigmaS, params.sigma_sigmaS, 1, 1); % [std.err in exp]

s = sigma_s * randn(params.nRays, 1);
pg = pg0db - Kdb + 10*log10(exp(1)) * (-abs(taus - tau0)/gamma + s);
% TODO: remove MPCs with more power than main cursor

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
% Copy D-ray outputs as some columns are repeated (e.g., reflection order)
output = repmat(dRayOutput, params.nRays, 1);
% delay
output(:,8) = taus;
% path gain
output(:,9) = pg;
% AoD azimuth
output(:,10) = aodAz;
% AoD elevation
output(:,11) = aodEl;
% AoA azimuth
output(:,12) = aoaAz;
% AoA elevation
output(:,13) = aoaEl;
% phase
output(:,18) = rand(params.nRays, 1) * 2*pi;
% doppler phase shift: uniformly random included in "phase" entry
output(:,20) = 0;

end


function params = getParams(arrayOfMaterials, MaterialLibrary, prePostParam)

materialIdx = arrayOfMaterials(end); % QD based on last reflector

switch(prePostParam)
    case 'pre'
        params.s_K = MaterialLibrary.s_K_Precursor(materialIdx);
        params.sigma_K = MaterialLibrary.sigma_K_Precursor(materialIdx);
        params.s_gamma = MaterialLibrary.s_gamma_Precursor(materialIdx);
        params.sigma_gamma = MaterialLibrary.sigma_gamma_Precursor(materialIdx);
        params.s_sigmaS = MaterialLibrary.s_sigmaS_Precursor(materialIdx);
        params.sigma_sigmaS = MaterialLibrary.sigma_sigmaS_Precursor(materialIdx);
        params.s_lambda = MaterialLibrary.s_lambda_Precursor(materialIdx);
        params.sigma_lambda = MaterialLibrary.sigma_lambda_Precursor(materialIdx);
        params.delayMultiplier = -1;
        params.nRays = 3;
        
    case 'post'
        params.s_K = MaterialLibrary.s_K_Postcursor(materialIdx);
        params.sigma_K = MaterialLibrary.sigma_K_Postcursor(materialIdx);
        params.s_gamma = MaterialLibrary.s_gamma_Postcursor(materialIdx);
        params.sigma_gamma = MaterialLibrary.sigma_gamma_Postcursor(materialIdx);
        params.s_sigmaS = MaterialLibrary.s_sigmaS_Postcursor(materialIdx);
        params.sigma_sigmaS = MaterialLibrary.sigma_sigmaS_Postcursor(materialIdx);
        params.s_lambda = MaterialLibrary.s_lambda_Postcursor(materialIdx);
        params.sigma_lambda = MaterialLibrary.sigma_lambda_Postcursor(materialIdx);
        params.delayMultiplier = 1;
        params.nRays = 16;
        
    otherwise
        error('prePostParam=''%s''. Should be ''pre'' or ''post''', prePostParam)
end

params.s_sigmaAlphaAz = MaterialLibrary.s_sigmaAlphaAz(materialIdx);
params.sigma_sigmaAlphaAz = MaterialLibrary.sigma_sigmaAlphaAz(materialIdx);
params.s_sigmaAlphaEl = MaterialLibrary.s_sigmaAlphaEl(materialIdx);
params.sigma_sigmaAlphaEl = MaterialLibrary.sigma_sigmaAlphaEl(materialIdx);

end


function [az, el] = getDiffusedAngles(azCursor, elCursor,...
    azimuthSpread, elevationSpread, nRays)
az = azCursor + rndLaplace(azimuthSpread, nRays, 1);
el = elCursor + rndLaplace(elevationSpread, nRays, 1);
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