function f_edgel2csv(b, row, col, v, subfolder, flnm_e, filenames_expos)

% This function exports estimated networks as csv edgelists. For each snapshot
% a subfolder where its ensembles are stored is created.
% 
% Inputs: b --> boolean value
%         row --> array storing source nodes
%         col --> array storing end nodes
%         v --> edge weight, assumed to be 1 
%         subfolder --> name of the subfolder where csv are stored
%         flnm_e --> filename of the ensemble
%         filenames_expos --> filename of the input exposure file
%  
% Outputs: csv files in folder 'subfolder'
% 
% Author: Stefano Gurciullo
% 
% Date: 29/05/2014


%% get date
d = str2num(filenames_expos(1:6));
t = zeros(length(v), 1);
t(:) = d;

%% write new csv if entire network is reconstructed
if b == 0
    
    cd ..
    cd data_bootstrap_output
    cd(subfolder)
    
    dlmwrite(strcat(flnm_e, '.csv'), [t, row, col, v], 'delimiter', ',', 'precision', 6);
    
    cd ..
    cd ..
    cd code

%% append to existing edgelist otherwise
elseif b == 1
    
    cd ..
    cd data_bootstrap_input
    A = csvread(filenames_expos, 0,0);
    
    cd ..
    cd data_bootstrap_output

    cd(subfolder)
    dlmwrite(strcat(flnm_e, '.csv'), A, 'delimiter', ',', 'precision', 6);
    dlmwrite(strcat(flnm_e, '.csv'), [t, row, col, v], '-append', 'delimiter', ',', 'precision', 6);
    
    
end

cd ..
if b == 1
    cd ..
end
cd code

