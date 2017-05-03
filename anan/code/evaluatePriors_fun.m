function priorQ_vec = evaluatePriors_fun(...
    N, ...
    absentLinksList_vec, ...
    interbankAssetsDeficit_mat,...
    interbankLiabilitiesDeficit_mat)

% This function updates matrix of prior probablities with which we select
% new links
%=========================================================================
% Inputs
%   N:
%          Number of banks
%
%   absentLinksList_vec:
%          List of absent links
%
%   interbankAssetsDeficit_mat:
%           Matrix for the differences in the asset marginals and estimated
%           exposures for all banks
%
%   interbankLiabilitiesDeficit_mat:
%           Matrix for the differences in the liability marginals and
%           estimated exposures for all banks
%=========================================================================
% Outputs
%   priorQ_vec:
%           Probabilities with which we select new links to add to the
%           interbank network
%
%=========================================================================
%=========================================================================

priorQ_vec = absentLinksList_vec .* ...
    max(reshape(interbankAssetsDeficit_mat ./ ...
    (interbankLiabilitiesDeficit_mat), 1, N^2), ...
    reshape(interbankLiabilitiesDeficit_mat ./ ...
    interbankAssetsDeficit_mat, 1, N^2));

priorQ_vec(isnan(priorQ_vec)) = 0;
priorQ_vec(isinf(priorQ_vec)) = 0;

%round(reshape(100*full(priorQ_vec/sum(priorQ_vec)),8,8))