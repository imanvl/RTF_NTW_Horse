function [E, sum_k_E] = f_bootstrap_ensembles(nNodes, capital, node_combinations, z, b)

% This function evaluate network ensembles. If b == 0, no information about
% already known edges is considered, and reconstructed networks will be totally
% new. If b == 1, known edges are considered and edges are created only among
% nodes not in subset_nodes or between nodes in subset_nodes and not in it. 
% 
% Inputs: nNodes --> number of nodes in the snapshot
%         capital --> --> array containing capital values for each node
%         node_combinations --> matrix with each combination of every two nodes
%                               in subset_nodes
%         z --> z-value needed to evaluate ensembles
%         b --> boolean value
%         
% Outputs: E --> Adjacency sparse matrix of the ensemble
%          sum_k_E --> total degree of ensemble E
%          
% Author: Stefano Gurciullo
% 
% Date: 29/05/2014

%% Create NxN matrix with random values in it
E = zeros(nNodes, nNodes);
    
for r = 1:size(E,1)
    for c = 1:size(E,2)
        if r ~= c
            E(r,c) = rand;
        end
    end
end

%% if b == 0, reconstruct entire network, else reconstruct only links for nodes whose net information
% is missing
total_n_combinations = combinator(nNodes,2,'p');

if b == 0
    n_combinations = total_n_combinations;
elseif b == 1
    n_combinations = setdiff(total_n_combinations, node_combinations, 'rows');
end

%% Fill the the adj matrix
% for r = 1:size(E,1)
%     for c = 1:size(E,2)
%         if r ~= c
%             p_value = (z * capital(r) * capital (c)) / (1 + (z * capital(r) * capital(c)));
%             if E(r,c) < p_value
%                 E(r,c) = 1;
%             else
%                 E(r,c) = 0;
%             end
%         end
%     end
% end 

for r = 1:length(n_combinations)
    
    row_comb = n_combinations(r, :);
    p_value = (z * capital(row_comb(1)) * capital (row_comb(2))) / (1 + (z * capital(row_comb(1)) * capital(row_comb(2))));
        
    if E(row_comb(1),row_comb(2)) < p_value
        E(row_comb(1),row_comb(2)) = 1;
    else
        E(row_comb(1),row_comb(2)) = 0;
    end
    
end

%% Polish matrix of nonzero and nonones values
if b == 1
    for r = 1:size(E,1)
        for c = 1:size(E,2)
            if E(r,c) < 1 || E(r,c) < 0 
               E(r,c) = 0;
            end
        end
    end
end


%% Make the matrix sparse and get total degree
E = sparse(E);
sum_k_E = nnz(E); %total degree

