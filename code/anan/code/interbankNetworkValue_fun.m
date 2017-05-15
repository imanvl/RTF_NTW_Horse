function V = interbankNetworkValue_fun(...
    c, ...
    assetsPenalty_vec,...
    liabilitiesPenalty_vec,...
    estimatedInterbank_mat,...
    totalInterbankAssets_vec, ...
    totalInterbankLiabilities_vec)

% This function evaluates the "value" of interbank networks, based on the
% value function
%=========================================================================
% Inputs
%   c:
%          Penalty term in the value function for the number of links
%
%
%   assetsPenality_vec:
%           Penalty term for deviations from the asset marginals
%           
%
%   liabilitiesPenality_vec:
%           Penalty term for deviations from the liabilities marginals
%
%   estimatedInterbank_mat:
%          The current interbank network
%
%   totalInterbankAssets_vec:
%           Total Interbank assets for each bank
%
%   totalInterbankLiabilities_vec:  
%           Total interbank liabilities for each bank
%=========================================================================
% Outputs
%   V:
%           The value of the interbank network
%
%=========================================================================
%=========================================================================
numberLinks = sum(sum(estimatedInterbank_mat > 0));

V = -c * numberLinks ...
    - sum(assetsPenalty_vec .* ...
    (sum(estimatedInterbank_mat, 2) - totalInterbankAssets_vec) .* ...
	(sum(estimatedInterbank_mat, 2) - totalInterbankAssets_vec)) ...
   - sum(liabilitiesPenalty_vec' .* ...
   (sum(estimatedInterbank_mat) - totalInterbankLiabilities_vec') .* ...
   (sum(estimatedInterbank_mat) - totalInterbankLiabilities_vec'));