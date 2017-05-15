function d=dens(X,f)
% Simple measure of density, the ratio of active to total links. 
% Routine also handles non-square matrices, and detects loops (if none,
% diagonal is excluded). Also handles 3D matrices, returning a vector d.
% To get a plot, enter any number as second argument.
% 
% Use density.m and flip_density for more sophisticated handling, 
% eg adjusting for reporting population the context of international banking  
% Goetz von Peter 2007


% ================ Input Handling =====================
[i j T]=size(X);        % dimensions
d=zeros(T,1); l=d;      % pre-allocate output (time-series)

for t=1:T                   % checking whether there are any loops
    l(t)=any(trace(X(:,:,t))); % returns 1 if any diagonal element is non-zero
end
if any(l)
    %disp('Loops are taken into account in density.')
    cells=i*j; 
else
    %disp('There are no loops; diagonal cells will not be counted for density.')
    cells=i*j-min(i,j);     % exclude diagonal from potential links
end

% To ignore any existing loops, activate this line: 
%X=diag2zero(X); cells=i*j-min(i,j);     

% ================ Calculation =====================
for t=1:T
    x=X(:,:,t);         % take sheet t
    N=full(spones(x));  % dichotomize it (non-valued adjacency matrix)
    d(t)=nnz(N)/cells;
end

if nargin>1             % if user wishes plot
dp=100*d;
figure
    plot(dp,'b+','LineWidth',1)
title('Density over time (%)','FontSize',16);              
%xlabel('Quarters','FontSize',12)
end