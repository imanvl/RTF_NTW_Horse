function [nChar] = f_bootstrap_net_properties(sentence)
%% test


nChar = length(sentence);

cd ..
cd('data_bootstrap_output');

file = fopen('output2.txt', 'w');
fprintf(file, '%u', nChar);
fclose(file);

cd ..
cd('code');



