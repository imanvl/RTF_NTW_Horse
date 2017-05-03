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
% column names). This is the small trainer set, should be part of the
% standard package
inputfilename = 'matrix.xlsx';

% Please fill in your country's ISO-2 country code and date stamp (mmyyyy) for the
% network. If you run multiple networks, please number them consecutively
% starting with 01. So, for example, for the Netherlands this would be
% NL01_112012 and so on.
networkName = 'TEST_092014';

% Set directory paths
% -------------------------------------------------------------------------
if ispc == 1
    p_fullmatrix = [pwd '\fullmatrix\'];
    p_results = [pwd '\results\'];
else
    % Alternate reference on MAC/LINUX
    p_fullmatrix = 'fullmatrix/';
    p_results = 'results/';
end

addpath('statistics');

% Prepare the input files
% -------------------------------------------------------------------------
% Read in the full information matrix
% We assume that the matrix is in a tab delineated CSV file with banks
% assets in columns and its liabilities in rows. The marginal are thus a
% row vector for banks’ assets and a column vector for liabilities.
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

% The batt, dreh and mast2 algorithms generate distributions for the
% matricies. Here we specify the number ensemble size (number of matricies
% to produce). Default should be 50
nEnsembles = 50;

% We rescale the matrices and balance sheet entries
nOrder = numel(num2str(ceil(max(max(M_orig)))));
M_orig = M_orig / 10^(nOrder-2);
E = E / 10^(nOrder-2);
TA = TA / 10^(nOrder-2);
LA = LA / 10^(nOrder-2);

% Derive descriptive information
rows   = size(M_orig,1);
cols   = size(M_orig,2);
assert(rows == cols, 'Matrix is not square')

Assets      = nansum(M_orig,2)';
Liabilities = nansum(M_orig,1)';

%% Run codes
% -------------------------------------------------------------------------
approachesList = {'orig','anan','bara','batt','dreh','hala','mast2','maxe'};


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
    
    computeNetworkStatistics_07
    
    outputMatrices.(technique).Network = estimatedResults;
    outputMatrices.(technique).Links = Links;
    outputMatrices.(technique).Density = Density;
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
        'herfindhalIndexAsset_mean','herfindhalIndexAsset_median',...      
        'herfindhalIndexLiab_mean','herfindhalIndexLiab_median',...        
        'liquidityShortfall','xAssetNorm_mat','xLiabNorm_mat');
    
    toc;
    display('---------------------------------');
    
end

%% Compute additional metrics - debtRank, similarity and for the original matrix, the distribution of centrality measures

computeDebtRank
computeSimilarity
 
computeCentralityOrigMatrix

%% Save outputs, plot spy charts and heat maps

outFile = strcat('outputMatrices', networkName, '.mat');
save([ p_results outFile ],'outputMatrices')

%outputMatricesRTF = outputMatrices;
%outputMatricesRTF = rmfield(outputMatricesRTF,'orig');

%outFile = strcat('outputMatricesRTF', networkName, '.mat');
%save([ p_results outFile ],'outputMatricesRTF');

%printTable15;
plot_spies;
plot_HeatMaps;

clear('approachesList','ensemble','estimatedResults','herfindhalIndexAsset_vec',...
    'herfindhalIndexLiab_vec','k','nOrder','temp','technique');
clear('msg','networkName','outFile','outputMatrices','p_results','rows')
clear('cosine_simi','hamming_dist','jaccard_dist','techniqueFileName');
%%

display('Computation completed!');