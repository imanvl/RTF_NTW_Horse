function [z, P] = f_bootstrap_z(nNodes, k_sum, fitness, z_vec)

% This function finds the latent variable z, needed for the bootstrapping of 
% the network ensembles. Z is found found through numerical simulations. 
% 
% Inputs: nNodes --> total number of nodes in the network
%         k_sum --> total number of links desired
%         fitness --> fitness value
%         z_vec --> vector of candidate solutions for z
%         
% Outputs: z --> z-value needed to estimate networks
%          P --> Matrix with probabilities of two nodes being connected
%  
%  Author: Stefano Gurciullo
%  Version: 2.0
%  Date created: 29/05/2014
%  Date last modified: 06/12/2014

disp('finding z, please wait a moment...')

%% solve for z numerically

p_solutions = sparse(nNodes, nNodes); %matrix of solutions
sum_p_solutions = zeros(1, length(z_vec)); %sum of solutions

for p = 1:length(z_vec)
    
    
    for row = 1:nNodes
        
        for col = 1:row-1 %trick to skip diagonal
            p_solutions(row, col) = (z_vec(p) * fitness(row) * fitness (col)...
                / (1 + (z_vec(p) * fitness(row) * fitness(col))));
        end
        
        for col = 1+row:nNodes
            p_solutions(row, col) = (z_vec(p) * fitness(row) * fitness (col)...
                / (1 + (z_vec(p) * fitness(row) * fitness(col))));
        end
        
    end
    
    sum_p_solutions(p) = sum(sum(p_solutions));
    %disp(sum_p_solutions(p));
    if sum_p_solutions(p) > (k_sum+10) %stop when we already found z
        break
    end
end

%evaluate difference between each solution and k_sum, take the index of
%smallest difference to identify z
diff = zeros(length(z_vec), 1);
for i = 1:length(z_vec) 
    diff(i) = sum_p_solutions(i) - k_sum;
end

[~, ind_z] = min(abs(diff));
z = z_vec(ind_z);

%% z_vec may not yield the z values, in such cases the user should modify z_vec
if z == 0
    disp(['your z solution vector has a range of values that is too high, '...
        'set a range of smaller values for z_vec']);
elseif z == max(z_vec)
    disp(['your z solution vector has a range of value that is too small, '...
        'set a higher range of values for z_vec']);
else
    disp(['z found: ' num2str(z)]);
end
    


%% Evaluate probability matrix (only half of it, don't want double edges)
P = zeros(nNodes, nNodes);

for row = 1:nNodes 
    for col = 1:row-1
        P(row, col) = (z * fitness(row) * fitness (col)...
            / (1 + (z * fitness(row) * fitness(col))));
    end
end

