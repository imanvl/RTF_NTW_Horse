function [node_combinations, z, p_values] = f_bootstrap_z(agents, subnet_nodes, capital)

% This function finds the latent variable z, needed for the bootstrapping of 
% the network ensembles. Z is found found through numerical simulations. 
% 
% Inputs: agents --> struct containing nodes' individual properties, degree 
%                    included
%         subnet_nodes --> array containing IDs of nodes whose edges are known
%         capital --> array containing capital values for each node
%         
% Outputs: node_combinations --> matrix with each combination of every two nodes
%                                in subset_nodes
%          z --> z-value needed to evaluate ensembles
%          p_values --> probability values of any two nodes in subset_nodes
%                       having an edge
%  
%  Author: Stefano Gurciullo
%  
%  Date: 29/05/2014

%% evaluate sum of total degrees

k_sum = sum(agents.k);

%% create a vector of possible solutions for z, between 0-1
% Note: once you get z, you can augment the precision by lowering the
% sequence range.

z_vec = linspace(0, 1, 10000);

%% solve for z numerically

n_subnet_nodes = length(subnet_nodes); %number of nodes (scalar)
node_combinations = combinator(n_subnet_nodes,2,'p'); %combination of nodes

p_solutions = zeros(length(z_vec), length(node_combinations)); %matrix of solutions
sum_p_solutions = zeros(1, length(z_vec)); %sum of solutions

for p = 1:length(z_vec)
    for ind = 1:length(node_combinations)
        row = node_combinations(ind,:);
        p_solutions(p, ind) = (z_vec(p) * capital(row(1)) * capital (row(2))) / (1 + (z_vec(p) * capital(row(1)) * capital(row(2))));
    end
    sum_p_solutions(p) = sum(p_solutions(p,:));
end

%evaluate difference between each solution and k_sum, take the index of
%smallest difference to identify z
diff = zeros(length(z_vec), 1);

for i = 1:length(z_vec) 
    diff(i) = sum_p_solutions(i) - k_sum;
end

[~, ind_z] = min(abs(diff));
z = z_vec(ind_z);
p_values = p_solutions(ind_z, :);

