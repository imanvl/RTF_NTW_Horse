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
inputfilename = 'matrix.xlsx';

% Please fill in your country's ISO-2 country code. If you run multiple
% networks, please number them consecutively starting with 01. So, for
% example, for the Netherlands this would be NL01 and so on.
networkName = 'NL';

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
addpath('statistics/debtrank');
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
approachesList = {'orig','anan','bara','batt','dreh','mast2','maxe'};

for a = approachesList
    if strcmp(a,'orig') == 0
        
        display('*********************************');
        display(a{:});
        
        addpath([a{:} '/code']);
        if exist([a{:} 'code.m'],'file') == 2
            try
                eval(['M_' a{:} ' = ' a{:} 'code(a, M_orig, Assets, Liabilities, E, TA);']);
                eval(['outputMatrices.' a{:} '.M = M_' a{:} ';']);
            catch err
                % Give more information for mismatch.
                if exist([a{:} 'code.m'],'file') == 0
                    msg = sprintf('%s', ...
                        'Matlab cannot find script ', [a{:} 'code.m'], '. Make sure it exists in a designated folder.');
                    display(msg);
                    
                    % Display any other errors as usual.
                else
                    msg = sprintf('%s', ...
                        'Script for ', [a{:} 'code.m'], ' seems to crash. Make sure it is working properly and is giving a matrix as output.');
                    display(msg);
                end
            end
        end
    end
    
    computeNetworkStatistics_04
    
    eval(['outputMatrices.' a{:} '.Network = M_' a{:} ';']);
    eval(['outputMatrices.' a{:} '.Links = Links;' ]);
    eval(['outputMatrices.' a{:} '.Density = Density;']);
    eval(['outputMatrices.' a{:} '.MeanDeg = MeanDeg;']);
    eval(['outputMatrices.' a{:} '.MedoDeg = MedoDeg;']);
    eval(['outputMatrices.' a{:} '.SymPearson = SymPearson;']);
    eval(['outputMatrices.' a{:} '.LendDep = LendDep;']);
    eval(['outputMatrices.' a{:} '.BoroDep = BoroDep;']);
    eval(['outputMatrices.' a{:} '.Cmit = Cmit;']);
    eval(['outputMatrices.' a{:} '.coresize = coresize;']);
    eval(['outputMatrices.' a{:} '.score = score;']);
    eval(['outputMatrices.' a{:} '.debtrank = impact_debtrank;']);
    
    clear('A','Links','Density','MeanDeg','MedoDeg','SymPearson','LendDep',...
        'BoroDep','Cmit','coresize','score','C1z','C2z','X','ans',...
        'b','boro','boromax','bratio','cols','error','errors','l','lend',...
        'lendmax','lratio','n','odX','core','x',...
        'I','W','a','ag','ag_new','ans_compute_DebtRank','aval_size',...
        'capital','case_load_capital','edgeList','gamma',...
        'impact_debtrank','impact_default','ind','ind_aval',...
        'inputfilename','nNodes','nSteps','net','node_list',...
        'p_fullmatrix','phi0','seed_node','seed_nodes',...
        'strength','theta','tot_asset','v0','impact');
    
    display('---------------------------------');
    
end

labels=1:1:rows;
labels=labels';

approachesList2 = {'orig','anan','bara','maxe'};
for a = approachesList2
    eval(['outputMatrices.' a{:} '.rank = horzcat(outputMatrices.' a{:} '.debtrank,labels);']);
    eval(['outputMatrices.' a{:} '.rank = sortrows(outputMatrices.' a{:} '.rank,-1);']);
    eval(['outputMatrices.' a{:} '.top1 = ismember(outputMatrices.orig.rank(1,2),outputMatrices.' a{:} '.rank(1,2));']);
    eval(['outputMatrices.' a{:} '.top3 = ismember(outputMatrices.orig.rank(1,2),outputMatrices.' a{:} '.rank(1:3,2));']);
    eval(['outputMatrices.' a{:} '.corr = corr(outputMatrices.orig.debtrank,outputMatrices.' a{:} '.debtrank);']);
    eval(['outputMatrices.' a{:} '.overlap1 = size(intersect(outputMatrices.orig.rank(1,2),outputMatrices.' a{:} '.rank(1,2))) / size(union(outputMatrices.orig.rank(1,2),outputMatrices.' a{:} '.rank(1,2)));']);
    eval(['outputMatrices.' a{:} '.overlap3 = size(intersect(outputMatrices.orig.rank(1:3,2),outputMatrices.' a{:} '.rank(1:3,2)))/ size(union(outputMatrices.orig.rank(1:3,2),outputMatrices.' a{:} '.rank(1:3,2)));']);
    
    eval(['outputMatrices.' a{:} '.similarity.hamming = hamming_dist(outputMatrices.orig.Network(:), outputMatrices.' a{:} '.Network(:));']);
    eval(['outputMatrices.' a{:} '.similarity.jaccard = jaccard_dist(outputMatrices.orig.Network(:), outputMatrices.' a{:} '.Network(:));']);
    eval(['outputMatrices.' a{:} '.similarity.cosine  = cosine_simi(outputMatrices.orig.Network(:), outputMatrices.' a{:} '.Network(:));']);
    eval(['outputMatrices.' a{:} '.similarity.jensen  = jsdiv(outputMatrices.orig.Network(:)/sum(outputMatrices.orig.Network(:)), outputMatrices.' a{:} '.Network(:)/sum(outputMatrices.' a{:} '.Network(:)));']);
end


approachesList3 = {'batt','dreh','mast2'};
for a = approachesList3
    eval(['ensembleN = size(outputMatrices.' a{:} '.Network,3);']);
    for e = 1 : ensembleN
        eval(['outputMatrices.' a{:} '.rank(:,:,e) = horzcat(outputMatrices.' a{:} '.debtrank(:,e),labels);']);
        eval(['outputMatrices.' a{:} '.rank(:,:,e) = sortrows(outputMatrices.' a{:} '.rank(:,:,e),-1);']);
        eval(['outputMatrices.' a{:} '.top1(e) = ismember(outputMatrices.orig.rank(1,2),outputMatrices.' a{:} '.rank(1,2,e));']);
        eval(['outputMatrices.' a{:} '.top3(e) = ismember(outputMatrices.orig.rank(1,2),outputMatrices.' a{:} '.rank(1:3,2,e));']);
        eval(['outputMatrices.' a{:} '.corr(e) = corr(outputMatrices.orig.debtrank,outputMatrices.' a{:} '.debtrank(:,e));']);
        eval(['outputMatrices.' a{:} '.overlap1(e) = size(intersect(outputMatrices.orig.rank(1,2),outputMatrices.' a{:} '.rank(1,2,e))) / size(union(outputMatrices.orig.rank(1,2),outputMatrices.' a{:} '.rank(1,2,e)));']);
        eval(['outputMatrices.' a{:} '.overlap3(e) = size(intersect(outputMatrices.orig.rank(1:3,2),outputMatrices.' a{:} '.rank(1:3,2,e)))/ size(union(outputMatrices.orig.rank(1:3,2),outputMatrices.' a{:} '.rank(1:3,2,e)));']);
        
        eval(['outputMatrices.' a{:} '.similarity.hamming(e) = hamming_dist(outputMatrices.orig.Network(:), reshape(outputMatrices.' a{:} '.Network(:,:,e),rows^2,1));']);
        eval(['outputMatrices.' a{:} '.similarity.jaccard(e) = jaccard_dist(outputMatrices.orig.Network(:), reshape(outputMatrices.' a{:} '.Network(:,:,e),rows^2,1));']);
        eval(['outputMatrices.' a{:} '.similarity.cosine(e)  = cosine_simi(outputMatrices.orig.Network(:), reshape(outputMatrices.' a{:} '.Network(:,:,e),rows^2,1));']);
        eval(['outputMatrices.' a{:} '.similarity.jensen(e)  = jsdiv(outputMatrices.orig.Network(:)/sum(outputMatrices.orig.Network(:)), reshape(outputMatrices.' a{:} '.Network(:,:,e),rows^2,1)/sum(reshape(outputMatrices.' a{:} '.Network(:,:,e),rows^2,1)));']);
    end
end

%%

outFile = strcat('outputMatrices', networkName, '.mat');
save([ p_results outFile ],'outputMatrices')

outputMatricesRTF = outputMatrices;
outputMatricesRTF = rmfield(outputMatricesRTF,'orig');
%outputMatricesRTF = rmfield(outputMatricesRTF,'batt.Network');
%outputMatricesRTF = rmfield(outputMatricesRTF,'dreh.Network');
%outputMatricesRTF = rmfield(outputMatricesRTF,'mast2.Network');


outFile = strcat('outputMatricesRTF', networkName, '.mat');
save([ p_results outFile ],'outputMatricesRTF');

clear('a','approachesList','approachesList2','approachesList3','labels','msg','networkName','outFile','outputMatrices','p_results','rows')
clear('cosine_simi','hamming_dist','jaccard_dist');
%%


msg = sprintf('%s', 'Results completed');
display(msg);