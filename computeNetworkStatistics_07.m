
%%  -------- LOAD A NETWORK TO ANALYZE ------------------------------------------
X = estimatedResults;

if ndims(X) == 3
    ensemble = size(X,3);
else
    ensemble = 1;
end

Links = zeros(1,ensemble);
Densities = zeros(1,ensemble);
MeanDeg = zeros(1,ensemble);
MedoDeg = zeros(1,ensemble);
SymPearson = zeros(1,ensemble);
LendDep = zeros(1,ensemble);
BoroDep = zeros(1,ensemble);
herfindhalIndexAsset_vec = zeros(size(X, 1),ensemble);  % We could preserve all the vectors for each ensamble but I still don't know how to do it
herfindhalIndexAsset_mean = zeros(1,ensemble);          % For this reason I computed the mean and median for each ensamble
herfindhalIndexAsset_median = zeros(1,ensemble);        % For this reason I computed the mean and median for each ensamble
herfindhalIndexLiab_vec = zeros(size(X, 1),ensemble);   % We could preserve all the vectors for each ensamble but I still don't know how to do it
herfindhalIndexLiab_mean = zeros(1,ensemble);           % For this reason I computed the mean and median for each ensamble
herfindhalIndexLiab_median = zeros(1,ensemble);         % For this reason I computed the mean and median for each ensamble
Cmit = zeros(1,ensemble);
coresize = zeros(1,ensemble);
score = zeros(1,ensemble);
debtRank = zeros(size(X, 1),ensemble);
liquidityShortfall = zeros(size(X,1),ensemble);
sinkRank = zeros(size(X, 1),ensemble);

for e = 1 : ensemble
    
    x = full(spones(X(:,:,e)));
    
    
    % Number of links
    Links(e) = nnz(x);
    
    % Network density
    Densities(e) = 100*dens(X(:,:,e));
    
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
    herfindhalIndexAsset_mean(e) = mean(herfindhalIndexAsset_vec);      % For this reason I computed the mean and median for each ensamble
    herfindhalIndexAsset_median(e) = median(herfindhalIndexAsset_vec);  % For this reason I computed the mean and median for each ensamble
    
    xLiabNorm_mat = X(:,:,e) ./ repmat(sum(X(:,:,e)), length(X(:,:,e)), 1);
    herfindhalIndexLiab_vec = sum(xLiabNorm_mat .* xLiabNorm_mat);
    herfindhalIndexLiab_vec(isnan(herfindhalIndexLiab_vec)) = 0;
    herfindhalIndexLiab_mean(e) = mean(herfindhalIndexLiab_vec);        % For this reason I computed the mean and median for each ensamble
    herfindhalIndexLiab_median(e) = median(herfindhalIndexLiab_vec);    % For this reason I computed the mean and median for each ensamble
    
    % Core-Periphery:
    [core, errors, error] = RepeatFitCP(X(:,:,e),2); n=size(X(:,:,e),1);
    coresize(e) = 100*nnz(core)/n; score(e) = 100*error/nnz(X(:,:,e));
    
    % Debt Rank
    debtRank(:,e) = debtrank_ecovalue(X(:,:,e),TA,E);
    
    % Liquidity Shortfall
    liquidityShortfall(:,e)  = liquidityShortfall_fun(X(:,:,e), LA, runoff);
    
    % Sink Rank
    sinkRank(:,e) = sinkRank_fun(X(:,:,e));
    
end
