function M_batt = battcode(Assets, Liabilities, Density, Ensemble)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: This script reconstructs network ensembles using information
%              about node attributes, using fitness modeling.
%              The networks estimation is performed at each time snapshot
%              provided in the input folder. See readme.txt for the details.
%
% Workflow: 1) Parameters to be set:
%                              i. number of estimated networks for each snapshot
%                              ii. desired density of the network
%                              iii. initialization of the vector of z solutions
%
%           2) Import data
%           3) Estimate networks for each snapshot
%           4) Export adjancency matrices and csv edgelists with estimated
%              networks in subfolders.
%
% Author: Stefano Gurciullo
%         s.gurciullo@cs.ucl.ac.uk
%
% Last modified: 23/03/2015
%
%
% Version 1.1

%number of banks
nNodes = length(Assets);

%output matrix
M_batt = zeros(nNodes, nNodes, Ensemble);

%vector containing potential solutions for z
z_vec = linspace(105000, 150000, 1000);

% interbank assets
IBassets = Assets + 1;

% interbank liabilities
IBliabilities = Liabilities + 1;


%% find z

%input density: must set at twice the actual density
k_sum = 2 * Density;

%initialise fitness
%NOTE: fitness can be any quantity desired, here is our take
fitness = (Assets + Liabilities') / sum(Assets + Liabilities'); %TA/sum(TA);

IBAssets_frac = IBassets/sum(IBassets);
IBLiab_frac =  IBliabilities/sum(IBliabilities);

%initiliaze z solutions vector
[z, P] = f_bootstrap_z(nNodes, k_sum, fitness, z_vec);

%% Evaluate networks for the ensemble
sum_k = zeros(1,Ensemble);

t = 1;
for nitr = 1:Ensemble
    
    %creat adjacency matrix
    [adj, sum_k(nitr)] = f_bootstrap_ensembles(nNodes, P);
    
    %assign weights
    [adj, ~, ~, ~, ~] = ...
        f_bootstrap_weights2(adj,IBAssets_frac, IBLiab_frac, IBassets',...
        IBliabilities);

    estimatedInterbank_mat = full(adj);
    
    size(estimatedInterbank_mat)
    
    M_batt(:,:,t) = estimatedInterbank_mat;
    t = t+1;
    
end

%display(['Average difference between column and row marginals are ' num2str(Delta_c) ' and ' num2str(Delta_r) ' respectively']);


