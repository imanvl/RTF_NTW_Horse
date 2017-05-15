function [ Xras ] = maxecode( a, l, dens, Ensemble)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the RAS alogorithm used to balance the interbank matrix estimated using
% Maximum Entropy and Large exposures data.
%
% INPUTS:  a       - Vector of weighted interbank assets
%          l       - Vector of weighted interbank liabilities
%          lrgexp  - A matrix containing the large exposures between the banks in the
%                    system. Cells are zero where no large exposures are known.
%          N       - Number of banks in the system
%          niterat - Number of iterations of the RAS algorithm
%
% OUTPUTS: Xras    - The estimated interbank matrix without the large
%                    exposures figures (these are put in during the final steps of the
%                    maxentropy.m code.
% --------------------------------------------------------------------------------------
% Author: ?
% This version: ?
%
% Edited 23-04-2008 by Bruno Eklund. Replaced existing estimation using loops by
%                                    matrix multiplications reducing run time by >90%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CREATING THE INDEPENDENCE CASE MATRIX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

niterat = 10000;

if size(a,2) > 1
    a = a';
end

Xindep = ones(length(a),length(l)); %a*l';  % This row replaces the next 5 original rows. Results in >95% faster estimation.

% ORIGINAL CODE
% for i = 1: N
%     for j = 1: N
%         Xindep(i,j) = a(i)*l(j);
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RESTRICTING THE INDEPEDNENCE MATRIX AS NECESSARY WHEN LARGE EXPOSURES ARE KNOWN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Xras  = Xindep - diag(diag(Xindep));    % These three rows replaces the next nine original rows.

% ORIGINAL CODE
% Xras = Xindep;
% for i = 1: N
%     Xras(i,i) = 0;
%     for j = 1: N
%         if lrgexp(i,j) > 0
%             Xras(i,j) = 0;
%         end
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WORKING THROUGH THE ALGORITHM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iterat = 1: niterat                 % This loop replaces the original nested loops below, resulting
    % Step 1: Row scaling               % in >97% faster estimation.
    rowscale = sum(Xras,2)';
    index = a <= 0;
    rowscale(index) = 0;
    index = rowscale ~= 0;
    rowscale(index) = a(index)'./rowscale(index);

    Xras = diag(rowscale)*Xras;

    % Step 2: Column scaling
    colscale = sum(Xras,1);
    index = l <= 0;
    colscale(index) = 0;
    index = colscale ~= 0;
    colscale(index) = l(index)'./colscale(index);

    Xras = Xras*diag(colscale);

end


% ORIGINAL CODE
% for iterat = 1: niterat
%     % Step 1: Row scaling
%     rowscale = sum(Xras,2)';
%     for i = 1: N
%         if a(i) > 0 && rowscale(i) ~= 0
%             rowscale(i) = a(i)/rowscale(i);
%         else
%             rowscale(i) = 0;
%         end
%     end
%     for i = 1: N
%         for j = 1: N
%             Xras(i,j) = Xras(i,j)*rowscale(i);
%         end
%     end
% 
%     % Step 2: Column scaling
%     colscale = sum(Xras,1);
%     for j = 1: N
%         if l(j) > 0 && colscale(j) ~= 0
%             colscale(j) = l(j)/colscale(j);
%         else
%             colscale(j) = 0;
%         end
%     end
%     for i = 1: N
%         for j = 1: N
%             Xras(i,j) = Xras(i,j)*colscale(j);
%         end
%     end
% end
