
%%  -------- LOAD A NETWORK TO ANALYZE ------------------------------------------
X = estimatedResults;

if ndims(X) == 3
    ensemble = size(X,3);
else
    ensemble = 1;
end

Links = zeros(1,ensemble);
Density = zeros(1,ensemble);
MeanDeg = zeros(1,ensemble);
MedoDeg = zeros(1,ensemble);
SymPearson = zeros(1,ensemble);
LendDep = zeros(1,ensemble);
BoroDep = zeros(1,ensemble);
herfindhalIndexAsset_vec = zeros(size(X, 1),ensemble);
herfindhalIndexLiab_vec = zeros(size(X, 1),ensemble);
Cmit = zeros(1,ensemble);
coresize = zeros(1,ensemble);
score = zeros(1,ensemble);
impact_debtrank = zeros(size(X, 1),ensemble);
liquidityShortfall = zeros(1,ensemble);

temp = 0;
temp2 = 0;
for e = 1 : ensemble
    
    x = full(spones(X(:,:,e)));
    %%
    
    if  length(x)*(length(x)-1)-nnz(x) > 0
        % Go through measures
        
        % Number of links
        Links(e) = nnz(x);
        
        % Network density
        Density(e) = 100*dens(X(:,:,e));
        
        % Mean and Median degrees
        odX = (sum(x')');
        MeanDeg(e) = mean(odX);
        MedoDeg(e) = median(odX);
        
        % Assortativity and Clustering
        SymPearson(e) = full(assortative(x));
        [C1z,C2z]  = clust_coeff(x); Cmit(e) = 100*C2z; % MIT routine
        
        % Dependency measures
        boro = sum(X(:,:,e),1); lend = sum(X(:,:,e),2);
        boromax = max(X(:,:,e),[],1); lendmax = max(X(:,:,e),[],2);
        lratio = 100*lendmax./lend; bratio = (100*boromax./boro)';
        l = find(~isnan(lratio)); b = find(~isnan(bratio)); % pick only active banks
        LendDep(e) = mean(lratio(l)); BoroDep(e) = mean(bratio(b));
        
        % Herfindhal Indices
        xAssetNorm_mat = X(:,:,e)./repmat(sum(X(:,:,e),2),1,length(X(:,:,e)));
        herfindhalIndexAsset_vec = sum(xAssetNorm_mat .* xAssetNorm_mat,2);
        herfindhalIndexAsset_vec(isnan(herfindhalIndexAsset_vec)) = 0;
        
        xLiabNorm_mat = X(:,:,e) ./ repmat(sum(X(:,:,e)), length(X(:,:,e)), 1);
        herfindhalIndexLiab_vec = sum(xLiabNorm_mat .* xLiabNorm_mat);
        herfindhalIndexLiab_vec(isnan(herfindhalIndexLiab_vec)) = 0;
        
        % Core-Periphery:
        [core, errors, error] = RepeatFitCP(X(:,:,e),2); n=size(X(:,:,e),1);
        coresize(e) = 100*nnz(core)/n; score(e) = 100*error/nnz(X(:,:,e));
        
        % Debt Rank
        edgeList = adj2edgeL(X(:,:,e));
        
        if max(max(X(:,:,e))) == 1 && min(min(X(:,:,e))) == 0
            temp = temp + 1;
            impact_debtrank(e) = 0;
        else
            % DR_time_compute;
            impact_debtrank(:,e) = debtrank_ecovalue(X(:,:,e),TA,E);
        end
        
        
        liquidityShortfall = liquidityShortfall_fun(X(:,:,e), LA, runoff);
    end
    
    %     clc; display(['====== NETWORK CHARACTERISTICS for ' [upper(a{:})] ' ==========='])
    %     display(['Number of links:      ', num2str(Links)])
    %     display(['Network density (%):  ', num2str(Density)])
    %     display(['Mean degree:          ', num2str(MeanDeg)])
    %     display(['Median degree:        ', num2str(MedoDeg)])
    %     display(['Assortativity:        ', num2str(SymPearson)])
    %     display(['Dependency lending:   ', num2str(LendDep)])
    %     display(['Dependency borrowing: ', num2str(BoroDep)])
    %     display(['Local clustering:     ', num2str(Cmit)])
    %     display(['Core size (% banks):  ', num2str(coresize)])
    %     display(['Error score(% links): ', num2str(score)])
    %     display(['Avg debt rank:        ', num2str(mean(impact_debtrank))])
    
end

if temp > 0
    display(['In ' num2str(temp) ' instances debtRank was not computed']);
end

