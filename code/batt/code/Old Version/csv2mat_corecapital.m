function [capital,tot_assets, nNodes] = csv2mat_corecapital(filename)

%  function that reads a file containing the capital and rotal assets during one time
%  period, e.g. a month and returns arrays
%
% Inputs: - filename --> name of the csv file data is contained
%
% Outputs: - capital --> vector of bank capital 
%          - tot_assets --> total assets for each bank
%          - nNodes --> number of nodes in the snapshot
%
% Date: 27/05/2014

% FORMAT REQUIRED FOR INPUT FILE:
% Col 1 = time, e.g. 200501
% Col2 = node Id, an integer from 1 to total number of nodes over dataset 
% Col3 = capital
% Col4 = total asset size
%
% WARNING: pay attention to the indices of banks: do they start from 1 or
% from 0? See line 22, 25
%

cd ..
cd data_bootstrap_input
A = csvread(filename, 0,0);
cd ..
cd code

% evaluate numeber of nodes
nNodes = length(A);

capital = zeros(nNodes, 1);    

tot_assets = zeros(nNodes, 1);

date = A(:, 1); 

indI = A(:, 2);  % if index starts at 1
%indI=A(:,2)+1;% in case index starts at 0

capital(indI) = A(:, 3);

tot_assets(indI) = A(:, 4);






