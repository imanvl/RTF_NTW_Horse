%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function that reads a file containing exposures during one time
% period, e.g. a month and returns an exposure matrix
%
% Inputs: - filename --> name of the csv file exposures are contained
%         - nNodes --> number of nodes consolidated over time
%
% Outputs: - expos_mat --> matrix of exposures
%
% Date: 27/05/2014


function expos_matrix = cvs2mat_exposures(filename, nNodes)


% FORMAT REQUIRED FOR INPUT FILE:
% Col 1 = time, e.g. 200501
% Col2 = lender Id, an integer from 1 to total number of nodes over dataset ( this is also nNodes indicated in DR_Time_Compute). 
% Col3 = borrower Id, an integer from 1 to total number of nodes over dataset ( this is also nNodes indicated in DR_Time_Compute). 
% Col4 = amount

cd ..
cd data_bootstrap_input
A = csvread(filename, 0,0);
cd ..
cd code

date = A(:,1);  % bc index starts at 0
%% if index starts at 1
indI = A(:,2);  % id lender:
indJ = A(:,3);  % id borrower 

%% if index starts at 0
%indI=A(:,2)+1;  % id lender: 
%indJ=A(:,3)+1;  % id borrower 
w = A(:,4);


%% test negative weights
ind=find(w<0);

if ~isempty(ind)
    display(['WARNING: there some negative w in file  ', filename]);
end

w(ind) = -w(ind);

%% exposure matrix
nr = nNodes;
nc = nNodes;
expos_matrix = sparse(indI, indJ, w, nr, nc); % in case there are multiple links these are summed up
