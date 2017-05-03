% Matlab horseMaster.m file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the master file to run various codes to estimate network matrices
% when only limited information is availble. It is part of the work of the
% Research Task Force's Liquidity Stress Testing group.
% 
% Assumptions
% - We assume a folder structure as already defined in the distibuted zip
%   file or Dropbox folder
% - This Horse.m file should be kept in the Horse Race �root� and it will 
%   call on each of the underlying codes in the sub folders
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Choose data set and approaches to run
% -------------------------------------------------------------------------
% Here you set the name of input file (in CSV with no fringes, ie no row or
% column names).
inputfilename = 'NLmatrix';
approachesList = {'anan' 'bara' 'batt' 'dreh' 'hal1' 'hal2' 'masi' 'mast' 'mous' 'musm'};

% Set directory paths
% -------------------------------------------------------------------------
p_fullmatrix = [pwd '\_fullmatrix\'];

% Prepare the input files
% -------------------------------------------------------------------------
% Read in the full information matrix
% We assume that the matrix is in a tab delineated CSV file with banks 
% assets in columns and its liabilities in rows. The marginal are thus a 
% row vector for banks� assets and a column vector for liabilities.
M = csvread([p_fullmatrix inputfilename]);
% Derive descriptive information
rows = size(M,1);
cols = size(M,2);
assert(rows == cols, 'Matrix is not square')

Assets = sum(M,1);
Liabilities = sum(M,2);

% Run codes
% -------------------------------------------------------------------------

for a = approachesList
    % Each of these would leave behind an estimated matrix in the \` approach�\output directory
    
    addpath([pwd '\' a{:} '\code\']);
    if exist([a{:} 'code.m'],'file') == 2
        try
            eval(['M_' a{:} ' = ' a{:} 'code();']);
            if strcmp(a{:},'anan')
                save('outputMatrices.mat', ['M_' a{:}])
            else
                save('outputMatrices.mat', ['M_' a{:}], '-append')
            end
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
    % Given the full matrix and the estimated matrix, compute network measures
    % [THIS IS WHERE KARTIK'S CODE WOULD FIT]
	% run computeNetworkStats
end

%{
% Output
% -------------------------------------------------------------------------
% Combine all the output and combine to a single log file / matrix outcomes
foreach approach of local approachesList {
% read in measures
% combine measures
}
%}