
%This code runs the Baral Fique method
%When run, this code calls GUI form where the following things need to be done:
% - choose "Empirical distribution" radio button
% - then browse the files : indegree.mat and outdegree.mat normally in the
% same working directory
% - choose "Gumbell" radio button, scroll it to 100%
% - choose "Error measure" radio button
% - in the last dropping window, choose "2.Copula based simulated network"
% - push button GO
% The results are saved in the bara\output directory with the predecided
% name

inputfilename = 'FRmatrix.txt';

% Set directory paths
% -------------------------------------------------------------------------
addpath(pwd)
code_path = pwd;
cd ..\..
p_fullmatrix = [pwd '\fullmatrix\'];
% Prepare the input files
% -------------------------------------------------------------------------
% Read in the full information matrix
% We assume that the matrix is in a tab delineated CSV file with banks 
% assets in columns and its liabilities in rows. The marginal are thus a 
% row vector for banks’ assets and a column vector for liabilities.
M = csvread([p_fullmatrix inputfilename]);
% Derive descriptive information
rows = size(M,1);
cols = size(M,2);
assert(rows == cols, 'Matrix is not square')

Assets = sum(M,1);
Liabilities = sum(M,2);

% For Baral-Fique method, the vectors of marginal assets and liabilities need to be saved
savdir = [pwd '\bara\code\'];        
out_file = 'outdegree.mat';
save(fullfile(savdir,out_file),'Assets');
out_file = 'indegree.mat';
save(fullfile(savdir,out_file),'Liabilities');

cd(code_path)
eval(BaralFique)