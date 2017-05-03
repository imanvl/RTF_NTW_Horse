function [agents, net] = f_adj2struct(subnet_nodes, expos_mat)

% This function creates two struct  for the agents' scalar network values
% 
% Inputs: subnet_nodes --> array containing IDs of nodes whose edges are known
%         expos_mat --> exposure matrix of nodes contained in subset_nodes
%         
% Outputs: agents --> struct with values as described below
%          net --> struct with values as described below
% 
% Date: 298/05/2014


%% Initialize structs
% k --> sum of in- and out-degree
% ki --> in-degree
% ko --> out-degree

% p --> predecessor
% pw --> predecessor weigth
% s --> successor
% sw --> successor weigth

agents = struct('id',[],'k', [], 'ki',[],'ko',[]);
net = struct('p',[],'pw',[],'s',[],'sw',[]); 

n_subnet_nodes = length(subnet_nodes);

agents.id = subnet_nodes;
agents.k = zeros(n_subnet_nodes, 1);
agents.ki = zeros(n_subnet_nodes, 1);
agents.ko = zeros(n_subnet_nodes, 1);

for I=subnet_nodes
    net(I).p = [];
    net(I).pw = []; 
    net(I).s = []; 
    net(I).sw = []; 
end


%% fill the structs

for I = subnet_nodes
    
    succ = find(expos_mat(I,:) > 0);
    
    if length(succ) > 0
        % set link weight
        net(I).s = succ; % WARNING! important that is horizontal
        net(I).sw = expos_mat(I,succ);
    end
    
    pred=find(expos_mat(:,I)>0);
    
    if length(pred) > 0    
        net(I).p = pred; % WARNING! important that is horizontal
        net(I).pw = expos_mat(pred,I);
    end
    
    agents.ko(I) = length(net(I).s); 
    agents.ki(I) = length(net(I).p); 
    agents.k(I) = agents.ko(I) + agents.ki(I);
    
end
