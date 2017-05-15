function [adj, actual_sum_rows, actual_sum_cols, diff, diff_r]  = f_bootstrap_weights2(adj, IBAssets_frac, IBLiab_frac, IBAssets, IBLiabilities)

% This function assign weights to networks estimated by using an iterative 
% fitting method, such that the sum of the marginals of the adjacency matrix
% approaches the empirical sums of total assets and of total liabilities.
% 
% Inputs:
%     adj - estimated adjacency matrix
%     IB_in - adjusted total interbank liabilities
%     IB_out - adjusted total intebank assets
%     
% Outputs:
%     adj - estimated adj matrix with weights
%     actual_sum_rows - sum of interbank liabilites assigned
%     actual_sum_cols - sum of interbank assets assigned
%     
% Author: Stefano Gurciullo
% Version: 1.2
% Date created: 26/11/2014
% Date last modified: 10/01/2015


%cycle through rows and cols
rows = size(adj,1);
cols = size(adj,2);

ib_out = IBAssets_frac * sum(IBAssets);
ib_in = IBLiab_frac * sum(IBLiabilities);

actual_sum_rows = zeros(size(adj,1),1);
actual_sum_cols = zeros(size(adj,2),1);

adj1 = adj;

for count = 1:20

    %if the difference between marginal assigned assets and actual assets
    %is less than 0.01% for each bank, stop
    diff = (actual_sum_cols - IBAssets)./IBAssets;
    diff_r = (actual_sum_rows - IBLiabilities)./IBLiabilities;
    
    ind = find(diff ~= -1);
    if abs(diff(ind)) < 0.001
        break
    end
    

    %first, adjust the cols
    for c = 1:cols
        for j = 1:length(adj1(:,c))
            div = (adj1(j,c)/sum(adj1(:,c)));
            if isnan(div)
                div = 0;
            end
            adj(j,c) = div*ib_in(c);
        end
        %update matrix again
        adj1 = adj;
    end
    
    %second, adjust the rows
    for r = 1:rows
        %row adjustment
        for i = 1:length(adj1(r,:))
            div = (adj1(r,i)/sum(adj1(r,:)));
            if isnan(div)
                div = 0;
            end
            adj(r,i) = div*ib_out(r);
        end
        %update matrix
        adj1 = adj;
        
    end
    
    
    %evaluate sum of cols
    actual_sum_cols = full(sum(adj,2));
    actual_sum_rows = full(sum(adj))';

     %display(actual_sum_rows);
     %display(actual_sum_cols);
%     display(count);
    

    
end