function liquidityShortfall_vec = ...
    liquidityShortfall_fun(interbank_mat, ...
    totalLiquidAssets_vec, ...
    liquidityShock_vec)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% liquidityShortfall_fun computes the change in liquid assets according to
% the fixed-point solution of Lee (2013)

% INPUT:      
%       interbank_mat         - matrix of interbank obligations (#banks x #banks)
%       totalLiquidAssets_vec - vector of liquid assets (#banks x 1)
%       liquidityShock_vec    - liquididity run-off shock (#banks x 1)
%
% OUTPUT:      
%       totalLiquidityShortfall - liquidity shortfall summed over all banks
%       liquidityShortfall_vec - vector of liquidity shortfalls for all banks
%
% REMARK:
%       Lee, S.H. (2013) Systemic liquidity shortage and interbank network
%       structure, Journal of Financial Stability, vol. 9, pages 1-12
%
% ------------------------------------------------------------------------------
% Adapted by: Kartik Anand (Bank of Canada)
% This version: 19/11/2014
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

myoptions = optimset('Display','none','MaxFunEvals',500,'TolX', 0.00001);

phi_mat = interbank_mat' ./ ...
    repmat(totalLiquidAssets_vec', length(interbank_mat), 1);
phi_mat(isnan(phi_mat))=0;

objfun=@(deltaLiquidAssets_vec) ...
    deltaLiquidAssets_vec ...
    - min(totalLiquidAssets_vec, ...
    liquidityShock_vec + phi_mat * deltaLiquidAssets_vec);

[deltaLiquidAssetsStar_vec, ~] = fsolve(objfun, ...
    zeros(size(totalLiquidAssets_vec)), ...
    myoptions);

liquidityShortfall_vec = max(0, ...
    phi_mat * deltaLiquidAssetsStar_vec + liquidityShock_vec ...
    - totalLiquidAssets_vec);

totalLiquidityShortfall = sum(liquidityShortfall_vec);
