
function [folder_input, folder_results, flnm_cap_suffix, flnm_expos_suffix, filenames_cap, filenames_expos, y_range, m_range] = f_bootstrap_import_data()

% Function that imports I/O parameters
%
% Inputs: none
% Outputs: - folder_input --> path to input data model
%          - folder_results --> path to output data model
%          - flnm_cap_suffix --> suffix for csv capital filenames
%          - flnm_expos_suffix --> suffix for csv exposure filenames
%          - filenames_cap --> list of csv capital files
%          - filenames_expos --> list of csv exposure files
%          - y_range --> years for which debtrank is computed
%          - m_range --> months or quarters for which debtrank is computed
%
% Author: Stefano Gurciullo
%
% Date: 25/05/2014

%% set folders and filenames for I/O interaction
folder_input = 'data_bootstrap_input/';
folder_results = 'data_bootstrap_output/';

flnm_cap_suffix = '_capital.csv';
flnm_expos_suffix = '_exposures.csv';

%% load filenames

cd ..
filelist = dir('data_bootstrap_input/'); %it does not accept folder_input, need to check why
cd code;

%filenames for capital csv files
filenames_cap = cell(length(filelist), 1); 
for i = 1:length(filelist)
    is_in = strfind(filelist(i).name, flnm_cap_suffix);
    
    if isempty(is_in) == 0
        filenames_cap(i,1) = cellstr(filelist(i).name);
    end
    
end

%find and remove empty cells
emptyCells = cellfun(@isempty,filenames_cap);
filenames_cap(emptyCells) = [];


%filenames for exposure csv files
filenames_expos = cell(length(filelist), 1); 
for i = 1:length(filelist)
    is_in = strfind(filelist(i).name, flnm_expos_suffix);
    
    if isempty(is_in) == 0
        filenames_expos(i,1) = cellstr(filelist(i).name);
    end
    
end

%find and remove empty cells
emptyCells = cellfun(@isempty,filenames_expos);
filenames_expos(emptyCells) = [];


%% identify year and month/quarter ranges using capital csv filenames

y_range = zeros(length(filenames_cap), 1);
m_range = zeros(length(filenames_cap), 1);

for i = 1:length(filenames_cap)
    y_range(i) = str2num(filenames_cap{i}(1:4)); %assumes format as in readme
    m_range(i) = str2num(filenames_cap{i}(5:6));
end

%sort and get unique values
y_range = sort(unique(y_range));
m_range = sort(unique(m_range)); 
    
    
