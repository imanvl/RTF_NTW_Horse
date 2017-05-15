%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description: This script reconstructs network ensembles using information 
%              about node attributes and a partial network, using fitness 
%              bootstrapping. 
%              The network estimation is performed at each snapshot provided 
%              in the input folder. See readme.txt for the details.
% 
% Workflow: 1) Set parameters: i. initialize node ids with complete network 
%                              information.
%                              ii. set type of bootstrapping.
%                              iii. number of ensembles for each snapshot
%           2) Import I/O data
%           3) Estimate network for each snapshot
%           4) Exports csv edgelists with estimated networks in subfolders.
%           
% Author: Stefano Gurciullo
% 
% Date: 29/05/2014
%
% Version 1.0



clc
clear all

% set random seed
rng(1989);

%% For which nodes do we have complete network information? Several options:
% 1) just store node ids in a variable (see below)
% 2) new csv file where, for each node, we insert 1 if part of the
% subnetwork, 0 otherwise
% 3) insert an indicator var in the core capital csv
% NOTE: this variable can change according to snapshot - in that case it could be
% inserted in the loop below
subnet_nodes = 1:13;

%% 0 if you want to bootstrap the entire network, 1 if only the missing
%part
b = 1;

%% Number of ensembles
nEnsembles = 50;

%% Import I/O data
[folder_input, folder_results, flnm_cap_suffix, flnm_expos_suffix, filenames_cap, filenames_expos, y_range, m_range] = f_bootstrap_import_data();

%% Cycle through each snapshot to perform the bootstrap, and export ensembles in a subfolder

for i = 1:length(filenames_expos)
   
    %% Evaluate number of nodes, and capital and total assets for each node
    [capital,tot_assets, nNodes] = csv2mat_corecapital(filenames_cap{i});
    
    %% Evaluate the incomplete exposure matrix
    expos_mat = cvs2mat_subnet_exposures(filenames_expos{i}, subnet_nodes);
    
    %% Evaluate agents' structs
    [agents, net] = f_adj2struct(subnet_nodes, expos_mat);
    
    %% Evaluate z and p values for bootstrap estimation
    [node_combinations, z, p_values] = f_bootstrap_z(agents, subnet_nodes, capital);
    
    sentence = ['found z, its value is equal to ', num2str(z)];
    disp(sentence)
    
    %% Create network ensembles and save them as csv edgelists
    
    for e = 1:nEnsembles
        
        %create ensemble adjacency matrix
        [E, sum_k_E] = f_bootstrap_ensembles(nNodes, capital, node_combinations, z, b);
        %turn matrix into edgelist, finding indices of nonzero elements
        [row, col, v] = find(E);
        
        %export edgelist to subfolder
        subfolder = strcat(num2str(filenames_expos{i}(1:6)), '_ensembles');
        flnm_e = strcat(num2str(filenames_expos{i}(1:6)), '_exposure_ensemble', '_', num2str(e));
        
        cd .. 
        cd data_bootstrap_output
        if exist(subfolder, 'dir') ~= 7
            mkdir(subfolder);
        end
        cd ..
        cd code
        
        f_edgel2csv(b, row, col, v, subfolder, flnm_e, filenames_expos{i});
        
        sentence = ['ensemble no.', num2str(e), ' of snapshot ', filenames_expos{i}(1:6), ' exported in folder.'];
        disp (sentence);
        
    end
    
    
end