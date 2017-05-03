function [adj, sum_k] = f_bootstrap_ensembles(nNodes, P)

% This function evaluate network ensembles.
% 
% Inputs: nNodes --> number of nodes in the snapshot
%         P --> Matrix with probabilities of two nodes being connected
%         
% Outputs: adj - estimated adjacency matrix
%          sum_k_E --> total degree of estimated network
%          
% Author: Stefano Gurciullo
% Version: 2.0
% Date created: 29/05/2014
% Date last modified: 05/12/2014


adj = rand(nNodes, nNodes);
adj = adj < P;

for row = 1:nNodes
    for col = 1:nNodes
        if adj(row,col) == 1
            r = rand;
            if r > 0.5
                adj(row,col) = 0;
                adj(col,row) = 1;
            end
        end
    end
end

adj = sparse(+adj); % '+' sign to convert logical matrix to double
sum_k = nnz(adj);



