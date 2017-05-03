% Matlab horseMaster.m file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the master file to run various codes to estimate network matrices
% when only limited information is availble. It is part of the work of the
% Research Task Force's Liquidity Stress Testing group.
% 
% Assumptions
% - We assume a folder structure as already defined in the distibuted zip
%   file or Dropbox folder
% - This Horse.m file should be kept in the Horse Race ‘root’ and it will 
%   call on each of the underlying codes in the sub folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
clc

% set random seed
rng(1989);

% Choose data set and approaches to run
% -------------------------------------------------------------------------
% Here you set the name of input file (in CSV with no fringes, ie no row or
% column names).
inputfilename = 'matrix.xlsx';
approachesList = {'anan', 'batt'};
%approachesList = {'anan' 'bara' 'batt' 'dreh' 'hal1' 'hal2' 'masi' 'mast' 'mous' 'musm'};

% Set directory paths
% -------------------------------------------------------------------------
%p_fullmatrix = [pwd '\_fullmatrix\'];
p_fullmatrix = ['_fullmatrix/']; %<<-- Alternate reference on MAC/LINUX
addpath('statistics');
addpath('statistics/debtrank');
addpath('bara/code')

% Prepare the input files
% -------------------------------------------------------------------------
% Read in the full information matrix
% We assume that the matrix is in a tab delineated CSV file with banks 
% assets in columns and its liabilities in rows. The marginal are thus a 
% row vector for banks’ assets and a column vector for liabilities.
M = xlsread([p_fullmatrix inputfilename],'matrix');
E = xlsread([p_fullmatrix inputfilename],'capital');
TA = xlsread([p_fullmatrix inputfilename],'total_assets');

% Derive descriptive information
rows = size(M,1);
cols = size(M,2);
assert(rows == cols, 'Matrix is not square')

Assets = sum(M,1);
Liabilities = sum(M,2);


% Run codes
% -------------------------------------------------------------------------

for a = approachesList
    % Each of these would leave behind an estimated matrix in the \` approach’\output directory
    
    % addpath([pwd '\' a{:} '\code\']); %<<-- Alternate reference on MAC/LINUX
    addpath([a{:} '/code']);
    if exist([a{:} 'code.m'],'file') == 2
        try
            %eval(['M_' a{:} ' = ' a{:} 'code();']);
            eval(['M_' a{:} ' = ' a{:} 'code(a, M, Assets, Liabilities, E, TA);']);
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
    
    computeNetworkStatistics
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
        'lendmax','lratio','n','odX','core','x','rows','M_anan',...
        'I','W','a','ag','ag_new','ans_compute_DebtRank','aval_size',...
        'capital','case_load_capital','edgeList','gamma',...
        'impact_debtrank','impact_default','ind','ind_aval',...
        'inputfilename','nNodes','nSteps','net','node_list',...
        'p_fullmatrix','phi0','seed_node','seed_nodes',...
        'strength','theta','tot_asset','v0','impact','M_batt');
end

%here run separately the GUI of BaralFique
savdir = [pwd '\bara\code\'];        
out_file = 'outdegree.mat';
save(fullfile(savdir,out_file),'Assets');
out_file = 'indegree.mat';
save(fullfile(savdir,out_file),'Liabilities');

cd([pwd '\bara\code\'])
eval(BaralFique)
load outputMatrices_bara.mat

cd ..\..
