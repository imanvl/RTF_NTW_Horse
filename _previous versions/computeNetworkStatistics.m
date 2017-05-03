
%%  -------- LOAD A NETWORK TO ANALYZE ------------------------------------------

eval(['X = M_' a{:}]);
x = spones(X);
 
%% REPORT ON THE CHARACTERISTICS OF A SINGLE NETWORK


% Go through measures

% Number of links
Links = nnz(x);             

%Network density
Density = 100*dens(X);        

% Mean and Median degrees
odX = (sum(x')');
MeanDeg =  mean(odX);
MedoDeg = median(odX); 

% Assortativity and Clustering
SymPearson = assortative(x);  
[C1z,C2z] = clust_coeff(x); Cmit = 100*C2z; % MIT routine

% Dependency measures
boro = sum(X,1); lend = sum(X,2); 
boromax = max(X,[],1); lendmax = max(X,[],2);  
lratio = 100*lendmax./lend; bratio = (100*boromax./boro)'; 
l = find(~isnan(lratio)); b = find(~isnan(bratio)); % pick only active banks
LendDep = mean(lratio(l)); BoroDep = mean(bratio(b));

% Core-Periphery:
[core errors error] = RepeatFitCP(X,2); n=size(X,1);
coresize = 100*nnz(core)/n; score = 100*error/nnz(X);

%Debt Rank
edgeList = adj2edgeL(X);
if max(max(X)) == 1 && min(min(X)) == 0
    display(['Adj. matrix only - cannot compute debtrank'])
    impact_debtrank = 0;
else
    DR_time_compute;
end

clc; display(['====== NETWORK CHARACTERISTICS =============='])
display(['Number of links:      ', num2str(Links)])
display(['Network density:      ', num2str(Density)])
display(['Mean degree:          ', num2str(MeanDeg)])
display(['Median degree:        ', num2str(MedoDeg)])
display(['Assortativity:        ', num2str(SymPearson)])
display(['Dependency lending:   ', num2str(LendDep)])
display(['Dependency borrowing: ', num2str(BoroDep)])
display(['Local clustering: ', num2str(Cmit)])
display(['Core size (% banks):  ', num2str(coresize)])
display(['Error score(% links): ', num2str(score)])
display(['Avg debt rank:        ', num2str(mean(impact_debtrank))])


