% horseMaster.m file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the master file to run various codes to estimate network matrices
% when only limited information is available. It is part of the work of the
% BCBS Research Task Force's Liquidity Stress Testing group.
%
% Assumptions
% - We assume a folder structure as already defined in the distibuted zip
%   file or Dropbox folder
% - This Horse.m file should be kept in the Horse Race ‘root’ and it will
%   call on each of the underlying codes in the sub folders
% - For MAC/LINUX the program defines alternative paths
% - Output is written to the '_results' folder. Once with all information
%   and once without the orginal matrix (to share witht the RTF)
%
% For any inputfile it will apply the approaches chosen. For each of these
% approaches, a series of networks statistics is computed.
% In addition, the real, observed network is compared with
% 1. ME
% 2. The networks as estimated with the various approaches
%
% In some cases, the approach only estimates an adjacency matrix (eg batt).
% In this case the observed network is transformed into an adjacency matrix
%
% TO DO
% - store the network stats for all approaches as a table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Preparations
% -------------------------------------------------------------------------
clear all
clc

% set random seed
rng(1989);

% Choose data set and approaches to run
% -------------------------------------------------------------------------
% Here you set the name of input file (in CSV with no fringes, ie no row or
% column names).
inputfilename = 'TaT_130628_sh.xlsx';

% Please fill in your country's ISO-2 country code. If you run multiple
% networks, please number them consecutively starting with 01. So, for
% example, for the Netherlands this would be NL01 and so on.
networkName = '_TEST';

% Set directory paths
% -------------------------------------------------------------------------
if ispc == 1
    p_fullmatrix = [pwd '\_fullmatrix\'];
    p_results = [pwd '\_results\'];
else
    % Alternate reference on MAC/LINUX
    p_fullmatrix = '_fullmatrix/';
    p_results = '_results/';
end

addpath('statistics');
addpath('statistics/debtrank_poledna');

% Prepare the input files
% -------------------------------------------------------------------------
% Read in the full information matrix
% We assume that the matrix is in a tab delineated CSV file with banks
% assets in columns and its liabilities in rows. The marginal are thus a
% row vector for banks’ assets and a column vector for liabilities.
M_orig = xlsread([p_fullmatrix inputfilename],'matrix');
E      = xlsread([p_fullmatrix inputfilename],'capital');
TA     = xlsread([p_fullmatrix inputfilename],'total_assets');
%LA     = xlsread([p_fullmatrix inputfilename],'liquid_assets');
LA = 0.5 * TA;

% We rescale the matrices and balance sheet entries
nOrder = numel(num2str(ceil(max(max(M_orig)))));
M_orig = M_orig / 10^(nOrder-2);
E = E / 10^(nOrder-2);
TA = TA / 10^(nOrder-2);
LA = LA / 10^(nOrder-2);

% To calculate the liquidity shortfall, we must determine the exogenous
% liquidity shock to banks, which in this case we take to be 2% of the
% liquid assets
runoff = 0.10 * LA;

% Derive descriptive information
rows   = size(M_orig,1);
cols   = size(M_orig,2);
assert(rows == cols, 'Matrix is not square')

Assets      = nansum(M_orig,2)';
Liabilities = nansum(M_orig,1)';

% Define similarly function to compare matricies
% Compares adjcency matrices only
hamming_dist = @(a,b)sum(1*(a(:)>0)~=1*(b(:)>0));
jaccard_dist = @(a,b)sum(a(:) & b(:))/ sum(a(:) | b(:));

% Compares valued networks
cosine_simi = @(a,b)dot(a(:),b(:))/(sqrt(dot(a(:),a(:)))*sqrt(dot(b(:),b(:))));
% For the Jensen Shannon distance we have the function jsdiv(a,b)

%% Run codes
% -------------------------------------------------------------------------
approachesList = {'orig','anan','bara','batt','dreh','hala','mast2','maxe'};

% The batt, dreh and mast2 algorithms generate distributions for the
% matricies. Here we specify the number ensemble size (number of matricies
% to produce).
nEnsembles = 5;

for a = approachesList
    
    tic;
    technique = a{:};
    estimatedResults = zeros(rows);
    
    if strcmp(technique,'orig') == 0
        
        display('*********************************');
        
        display(['Technique: ' technique]);
        
        addpath([technique '/code']);
        
        techniqueFileName = [technique 'code.m'];
        
        if exist(techniqueFileName,'file') == 2
            
            try
                estimatedResults = eval([technique 'code(a, M_orig, Assets, Liabilities, E, TA, nEnsembles);']);
                
                % Debugging
                display(['Size of estimated network / ensemble is (' num2str(size(estimatedResults)) ')']);
                
            catch err
                % Give more information for mismatch.
                
                if exist(techniqueFileName,'file') == 0
                    msg = sprintf('%s', ...
                        'Matlab cannot find script ', techniqueFileName, '. Make sure it exists in a designated folder.');
                    display(msg);
                    
                    % Display any other errors as usual.
                else
                    msg = sprintf('%s', ...
                        'Script for ', techniqueFileName, ' seems to crash. Make sure it is working properly and is giving a matrix as output.');
                    display(msg);
                    estimatedResults = zeros(rows);
                end
            end
        end
    else
        estimatedResults = M_orig;
    end
    
    computeNetworkStatistics_05
    
    outputMatrices.(technique).Network = estimatedResults;
    outputMatrices.(technique).Links = Links;
    outputMatrices.(technique).Density = Density;
    outputMatrices.(technique).MeanDeg = MeanDeg;
    outputMatrices.(technique).MedoDeg = MedoDeg;
    outputMatrices.(technique).SymPearson = SymPearson;
    outputMatrices.(technique).LendDep = LendDep;
    outputMatrices.(technique).BoroDep = BoroDep;
    outputMatrices.(technique).HHIAsset = herfindhalIndexAsset_vec;
    outputMatrices.(technique).HHILiab = herfindhalIndexLiab_vec;
    outputMatrices.(technique).Cmit = Cmit;
    outputMatrices.(technique).coresize = coresize;
    outputMatrices.(technique).score = score;
    outputMatrices.(technique).debtrank = impact_debtrank;
    outputMatrices.(technique).liquidityShortfall = liquidityShortfall;
    
    clear('A','Links','Density','MeanDeg','MedoDeg','SymPearson','LendDep',...
        'BoroDep','Cmit','coresize','score','C1z','C2z','X','ans',...
        'b','boro','boromax','bratio','cols','error','errors','l','lend',...
        'lendmax','lratio','n','odX','core','x',...
        'I','W','a','ag','ag_new','ans_compute_DebtRank','aval_size',...
        'capital','case_load_capital','edgeList','gamma',...
        'impact_debtrank','impact_default','ind','ind_aval',...
        'inputfilename','nNodes','nSteps','net','node_list',...
        'p_fullmatrix','phi0','seed_node','seed_nodes',...
        'strength','theta','tot_asset','v0','impact','temp2',...
        'herfindhalIndexAsset_vec','herfindhalIndexLiab_vec',...
        'liquidityShortfall','xAssetNorm_mat','xLiabNorm_mat');
    
    toc;
    display('---------------------------------');
    
end

labels=1:1:rows;
labels=labels';

approachesList2 = {'orig','anan','bara','hala','maxe'};
for a = approachesList2
    
    technique = a{:};
    
    % Compare the ordering of debtRank importance
    outputMatrices.(technique).rank = horzcat(outputMatrices.(technique).debtrank,labels);
    outputMatrices.(technique).rank = sortrows(outputMatrices.(technique).rank,-1);
    outputMatrices.(technique).top1 = ismember(outputMatrices.orig.rank(1,2),outputMatrices.(technique).rank(1,2));
    outputMatrices.(technique).top3 = ismember(outputMatrices.orig.rank(1,2),outputMatrices.(technique).rank(1:3,2));
    outputMatrices.(technique).corr = corr(outputMatrices.orig.debtrank,outputMatrices.(technique).debtrank);
    outputMatrices.(technique).overlap1 = length(intersect(outputMatrices.orig.rank(1,2),outputMatrices.(technique).rank(1,2))) / ...
        length(union(outputMatrices.orig.rank(1,2),outputMatrices.(technique).rank(1,2)));
    outputMatrices.(technique).overlap3 = length(intersect(outputMatrices.orig.rank(1:3,2),outputMatrices.(technique).rank(1:3,2))) / ...
        length(union(outputMatrices.orig.rank(1:3,2),outputMatrices.(technique).rank(1:3,2)));
    
    
    % Compute similarity measures
    vectorizedEstimatedNetwork = outputMatrices.(technique).Network(:);
    vectorizedEstimatedNetwork(isnan(vectorizedEstimatedNetwork) | isinf(vectorizedEstimatedNetwork)) = 0;
    
    outputMatrices.(technique).similarity.hamming = hamming_dist(outputMatrices.orig.Network(:), vectorizedEstimatedNetwork);
    outputMatrices.(technique).similarity.jaccard = jaccard_dist(outputMatrices.orig.Network(:), vectorizedEstimatedNetwork);
    outputMatrices.(technique).similarity.cosine  = cosine_simi(outputMatrices.orig.Network(:), vectorizedEstimatedNetwork);
    outputMatrices.(technique).similarity.jensen  = jsdiv(outputMatrices.orig.Network(:) / sum(outputMatrices.orig.Network(:)), ...
        vectorizedEstimatedNetwork / sum(vectorizedEstimatedNetwork));
    
    
    % Compute confusion matrix
    [truePositives,...
        trueNegatives,...
        falsePositives,...
        falseNegatives,...
        accuracy] = classification_performance_fun(outputMatrices.orig.Network,outputMatrices.(technique).Network);
    
    outputMatrices.(technique).confusionMatrix.truePositives = truePositives;
    outputMatrices.(technique).confusionMatrix.trueNegatives = trueNegatives;
    outputMatrices.(technique).confusionMatrix.falsePositives = falsePositives;
    outputMatrices.(technique).confusionMatrix.falseNegatives = falseNegatives;
    outputMatrices.(technique).confusionMatrix.accuracy = accuracy;
end


approachesList3 = {'batt','dreh','mast2'};
for a = approachesList3
    
    technique = a{:};
    
    ensembleN = size(outputMatrices.(technique).Network,3);
    
    for e = 1 : ensembleN
        
        % Compare the ordering of debtRank importance
        outputMatrices.(technique).rank(:,:,e) = horzcat(outputMatrices.(technique).debtrank(:,e),labels);
        outputMatrices.(technique).rank(:,:,e) = sortrows(outputMatrices.(technique).rank(:,:,e),-1);
        outputMatrices.(technique).top1(e) = ismember(outputMatrices.orig.rank(1,2),outputMatrices.(technique).rank(1,2,e));
        outputMatrices.(technique).top3(e) = ismember(outputMatrices.orig.rank(1,2),outputMatrices.(technique).rank(1:3,2,e));
        outputMatrices.(technique).corr(e) = corr(outputMatrices.orig.debtrank,outputMatrices.(technique).debtrank(:,e));
        outputMatrices.(technique).overlap1(e) = length(intersect(outputMatrices.orig.rank(1,2),outputMatrices.(technique).rank(1,2,e))) / ...
            length(union(outputMatrices.orig.rank(1,2),outputMatrices.(technique).rank(1,2,e)));
        outputMatrices.(technique).overlap3(e) = length(intersect(outputMatrices.orig.rank(1:3,2),outputMatrices.(technique).rank(1:3,2,e))) / ...
            length(union(outputMatrices.orig.rank(1:3,2),outputMatrices.(technique).rank(1:3,2,e)));
        
        % Compute similarity measures
        vectorizedEstimatedNetwork = reshape(outputMatrices.(technique).Network(:,:,e), rows^2, 1);
        vectorizedEstimatedNetwork(isnan(vectorizedEstimatedNetwork) | isinf(vectorizedEstimatedNetwork)) = 0;
        
        outputMatrices.(technique).similarity.hamming(e) = hamming_dist(outputMatrices.orig.Network(:), vectorizedEstimatedNetwork);
        outputMatrices.(technique).similarity.jaccard(e) = jaccard_dist(outputMatrices.orig.Network(:), vectorizedEstimatedNetwork);
        outputMatrices.(technique).similarity.cosine(e)  = cosine_simi(outputMatrices.orig.Network(:), vectorizedEstimatedNetwork);
        outputMatrices.(technique).similarity.jensen(e)  = jsdiv(outputMatrices.orig.Network(:) / sum(outputMatrices.orig.Network(:)), ...
            vectorizedEstimatedNetwork / sum(vectorizedEstimatedNetwork));
        
        % Compute confusion matrix
        [truePositives, trueNegatives, falsePositives, falseNegatives,...
            accuracy] = classification_performance_fun(outputMatrices.orig.Network,outputMatrices.(technique).Network(:,:,e));
        
        outputMatrices.(technique).confusionMatrix.truePositives(e) = truePositives;
        outputMatrices.(technique).confusionMatrix.trueNegatives(e) = trueNegatives;
        outputMatrices.(technique).confusionMatrix.falsePositives(e) = falsePositives;
        outputMatrices.(technique).confusionMatrix.falseNegatives(e) = falseNegatives;
        outputMatrices.(technique).confusionMatrix.accuracy(e) = accuracy;
    end
end

%%

outFile = strcat('outputMatrices', networkName, '.mat');
save([ p_results outFile ],'outputMatrices')

outputMatricesRTF = outputMatrices;
outputMatricesRTF = rmfield(outputMatricesRTF,'orig');

outFile = strcat('outputMatricesRTF', networkName, '.mat');
save([ p_results outFile ],'outputMatricesRTF');

%printTable;
%printTable10;
%printTable90;

clear('a','e','approachesList','approachesList2','approachesList3','labels','msg','networkName','outFile','outputMatrices','p_results','rows')
clear('cosine_simi','hamming_dist','jaccard_dist','ensembleN','technique','techniqueFileName',...
    'temp','vectorizedEstimatedNetwork','ensemble');
clear('truePositives','trueNegatives','falsePositives','falseNegatives','accuracy');
%%

display('Computation completed!');