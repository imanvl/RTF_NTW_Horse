function [txt] = f_bootstrap_param()
%% test 

cd ..
cd('param_bootstrap_input');
file = fopen('param.txt', 'r');
txt = textscan(file, '%s');

cd .. 
cd('code')