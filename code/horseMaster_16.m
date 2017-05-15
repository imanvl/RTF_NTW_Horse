% horseMaster.m file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the master file to run various codes to estimate network matrices
% when only limited information is available. It is part of the work of the
% BCBS Research Task Force's Liquidity Stress Testing group.
%
% Assumptions
% - We assume a folder structure as already defined in the distibuted zip
%   file or Dropbox folder
% - This Horse.m file should be kept in the Horse Race ?root? and it will
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Preparations
% -------------------------------------------------------------------------
clear all
clc

warning('off','all')

% set random seed
rng(1989);

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

% Several of the algorithms generate distributions for the
% matricies. Here we specify the number ensemble size (number of matricies
% to produce). Default should be 50
nEnsembles = 50;


% Choose data set and approaches to run
% -------------------------------------------------------------------------
% Here you set the name of input file (in CSV with no fringes, ie no row or
% column names). This is the small trainer set, should be part of the
% standard package
fileList = {'CIBL01.xls','CIBL02.xls'};

% Please fill in your country's ISO-2 country code and date stamp (mmyyyy) for the
% network. So, for example, for the Netherlands this would be
% NL01_112012 and so on.
networkList = {'TEST01','TEST02'};
networkCounter = 1;

for filename = fileList
    inputfilename = filename{:};
    networkName = networkList{networkCounter};
    
    display('*********************************');
    display([' ']);
    display(['Preparing network ' networkName]);
    display([' ']);
    % Prepare the input files
    % -------------------------------------------------------------------------
    % Read in the full information matrix
    % We assume that the matrix is in a tab delineated CSV file with banks
    % assets in columns and its liabilities in rows. The marginal are thus a
    % row vector for banks? assets and a column vector for liabilities.
    M_orig = xlsread([p_fullmatrix inputfilename],'matrix');
    E      = xlsread([p_fullmatrix inputfilename],'capital');
    TA     = xlsread([p_fullmatrix inputfilename],'total_assets');
    
    % We need to amount of liquid assets (including interbank assets) for each
    % banks. Assume this to be 20% of the total assets
    LA = 0.2 * TA;
    TA = TA - LA;
    
    % To calculate the liquidity shortfall, we must determine the exogenous
    % liquidity shock to banks, which in this case we take to be 15% of total
    % assets
    runoff = 0.15 * TA;
    
    
    % Derive descriptive information
    nrows   = size(M_orig,1);
    ncols   = size(M_orig,2);
    assert(nrows == ncols, 'Matrix is not square')
    nBanks = nrows;
    
    Assets      = nansum(M_orig,2)';
    Liabilities = nansum(M_orig,1)';
    Density = dens(M_orig);
    
    %% Run codes
    
    approachesList = {'orig','anan','bara','batt','cimi','dreh','hala','maxe'};
    
    % This list should be modified as seen appropriate - if a user wishes to
    % run only one algorithm, then only that algorithm's acronym should appear
    % in the list
    
    for a = approachesList
        
        
        technique = a{:};
        estimatedResults = zeros(nBanks);
        
        if strcmp(technique,'orig') == 0
            tic;
            
            display('*********************************');
            
            display(['Technique: ' technique]);
            
            addpath([technique '/code']);
            
            techniqueFileName = [technique 'code.m'];
            
            if exist(techniqueFileName,'file') == 2
                
                try
                    estimatedResults = eval([technique 'code(Assets, Liabilities, Density, nEnsembles);']);
                    
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
                            'Script for ', techniqueFileName, ' seems to crash.');
                        display(msg);
                        estimatedResults = zeros(nrows);
                    end
                end
            end
            toc;
        else
            estimatedResults = M_orig;
        end
        
        computeNetworkStatistics_07
        
        outputMatrices.(technique).Network = estimatedResults;
        outputMatrices.(technique).Nodes = length(TA);
        outputMatrices.(technique).Links = Links;
        outputMatrices.(technique).Densities = Densities;
        outputMatrices.(technique).MeanDeg = MeanDeg;
        outputMatrices.(technique).MedoDeg = MedoDeg;
        outputMatrices.(technique).SymPearson = SymPearson;
        outputMatrices.(technique).LendDep = LendDep;
        outputMatrices.(technique).BoroDep = BoroDep;
        outputMatrices.(technique).MeanHHIAsset = herfindhalIndexAsset_mean;
        outputMatrices.(technique).MedianHHIAsset = herfindhalIndexAsset_median;
        outputMatrices.(technique).MeanHHILiab = herfindhalIndexLiab_mean;
        outputMatrices.(technique).MedianHHILiab = herfindhalIndexLiab_median;
        outputMatrices.(technique).Cmit = Cmit;
        outputMatrices.(technique).coresize = coresize;
        outputMatrices.(technique).score = score;
        outputMatrices.(technique).debtrank = debtRank;
        outputMatrices.(technique).sinkrank = sinkRank;
        outputMatrices.(technique).liquidityShortfall = liquidityShortfall;
        
        clear('A','Links','Densities','MeanDeg','MedoDeg','SymPearson','LendDep',...
            'BoroDep','Cmit','coresize','score','C1z','C2z','X','ans',...
            'b','boro','boromax','bratio','cols','error','errors','l','lend',...
            'lendmax','lratio','n','odX','core','x',...
            'I','W','a','ag','ag_new','ans_compute_DebtRank','aval_size',...
            'capital','case_load_capital','edgeList','gamma',...
            'debtRank','sinkRank','impact_default','ind','ind_aval',...
            'inputfilename','nNodes','nSteps','net','node_list',...
            'phi0','seed_node','seed_nodes',...
            'strength','theta','tot_asset','v0','impact','temp2',...
            'herfindhalIndexAsset_mean','herfindhalIndexAsset_median',...
            'herfindhalIndexLiab_mean','herfindhalIndexLiab_median',...
            'liquidityShortfall','xAssetNorm_mat','xLiabNorm_mat','e',...
            'ensemble','estimatedResults','rows',...
            'techniqueFileName','herfindhalIndexAsset_vec',...
            'herfindhalIndexLiab_vec');
        
    end
    
    %% Compute additional metrics - debtRank, similarity and for the original matrix, the distribution of centrality measures
    
    computeDebtRank
    computeLiquidityRank
    computeSinkRank
    computeSimilarity
    
    computeCentralityOrigMatrix
    
    %% Save outputs, plot spy charts and heat maps
    
    printTables16;
    plot_spies;
    plot_HeatMaps;
    
    % %% Save output to be shared with the RTF (ie excluding the original
    % matrix)
    outputMatrices.orig.Network = 0;
    outFile = strcat('outputMatrices_', networkName, '.mat');
    save([ p_results outFile ],'outputMatrices');
    
    clear('approachesList','ensemble','estimatedResults','herfindhalIndexAsset_vec',...
        'herfindhalIndexLiab_vec','k','temp','technique');
    clear('msg','networkName','outFile','nBanks')
    clear('cosine_simi','hamming_dist','jaccard_dist','techniqueFileName');
   
    display([' ']);
    display([' ']);
    
    clear('Assets','Density','E','LA','Liabilities','M_orig','runoff','TA');
    networkCounter = networkCounter + 1;
end


display('Computation completed!');
clear('networkCounter','filename','p_results','outputMatrices',...
    'outputMatricesRTF','p_fullmatrix','nEnsembles','fileList','networkList');
