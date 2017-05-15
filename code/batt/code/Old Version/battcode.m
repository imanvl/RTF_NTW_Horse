function M_batt = battcode(a, M, Assets, Liabilities, E, TA, Ensemble)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: This script reconstructs network ensembles using information
%              about node attributes and a partial network, using fitness
%              bootstrapping.
%              The network estimation is performed at each snapshot provided
%              in the input folder. See readme.txt for the details.
%
% Author: Stefano Gurciullo
%
% Date: 29/05/2014
%
% Version 1.0


%% For which nodes do we have complete network information? Several options:
% 1) just store node ids in a variable (see below)
% 2) new csv file where, for each node, we insert 1 if part of the
% subnetwork, 0 otherwise
% 3) insert an indicator var in the core capital csv
% NOTE: this variable can change according to snapshot - in that case it could be
% inserted in the loop below
subnet_nodes = 1:length(M);

%% 0 if you want to bootstrap the entire network, 1 if only the missing
%part
b = 0;

%% Number of ensembles
nEnsembles = Ensemble;

%% Import I/O data
%[folder_input, folder_results, flnm_cap_suffix, flnm_expos_suffix, filenames_cap, filenames_expos, y_range, m_range] = f_bootstrap_import_data();

tot_assets = TA;
fitness = tot_assets;
nNodes = length(M);

%% Evaluate the incomplete exposure matrix
expos_mat = M;

%% Evaluate agents' structs
[agents, ~] = f_adj2struct(subnet_nodes, expos_mat);

%% Evaluate z and p values for bootstrap estimation

flag = 0;
order = -8;
while flag == 0
    [node_combinations, z, ~] = f_bootstrap_z(agents, subnet_nodes, fitness);

    if z == 1 || z == 0
        fitness = tot_assets / 10^(order);
        order = order + 1;
    else
        flag = 1;
    end
end
display(['Average fitness: ' num2str(mean(fitness))]);
sentence = ['found z, its value is equal to ', num2str(z)];
disp(sentence)

%% Create network ensembles and save them as csv edgelists

%output = zeros(nNodes,nNodes,nEnsembles);
density = zeros(1,nEnsembles);
ee = 1;
for e = 1:nEnsembles
    
    %create ensemble adjacency matrix
    [E, sum_k_E] = f_bootstrap_ensembles(nNodes, fitness, node_combinations, z, b);
    %turn matrix into edgelist, finding indices of nonzero elements
    [row, col, v] = find(E);
    estimatedInterbank_mat = full(sparse(row, col, v));
    density(e) = 100* nnz(estimatedInterbank_mat)/(nNodes*(nNodes-1));
    if sum(size(estimatedInterbank_mat) == size(M)) == 2
        output(:,:,ee) = estimatedInterbank_mat;
        ee = ee + 1;
    end
end

M_batt = output;