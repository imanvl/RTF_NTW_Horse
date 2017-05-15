% Script that generates estimation distributions for the simulated matrix
% data
clear all
clc

ndatapoints=100;                        % number of data points simulated for each set of parameters of asymmetry
nrepetitions=10;                      % number that increments the asymmetry parameters
auxvec=zeros(ndatapoints,1);            % initialize the vector that stores the simulated differences between each method
auxvec_mean=zeros(nrepetitions,1);      % initialize vector that stores the mean difference between the methods
auxvec_stdev=zeros(nrepetitions,1);     %  '' ''' ''''''''''''''''''''''''' stdev of the '''''''''''''''''''''''''''''

% Parameters of the simulation

intra_ba=1;                          % intra block asymmetry initial point
inter_ba=100;                           % inter block asymmetry initial point
n=100;                                  % number of nodes 
n1=20;                                  % number of core nodes

for i=1:nrepetitions
    for j=1:ndatapoints
        auxvec(j)=dif_fct(inter_ba,intra_ba+(0.99*(10000/nrepetitions))*i,n,n1);
    end
    i/nrepetitions
    auxvec_mean(i)=mean(auxvec);
    auxvec_stdev(i)=std(auxvec);
end
%%
x=1:nrepetitions;
index = x;  
x_up=(auxvec_mean+auxvec_stdev)';
x_lo=(auxvec_mean-auxvec_stdev)';
baseLine = min(x_lo-0.000005);        %# Baseline value for filling under the curves

plot(x,100*x_up,'b',x,100*auxvec_mean,'r',x,100*x_lo,'b');                              %# Plot the first line
hold on;
%fill(x,x_up,'b')
%# Add to the plot
h1 = fill(x(index([1 1:end end])),[100*baseLine 100*x_up(index) 100*baseLine],'b','EdgeColor','none');
plot(x,100*x_lo,'g');                              %# Plot the second line
h2 = fill(x(index([1 1:end end])),...        %# Plot the second filled polygon
          [100*baseLine 100*x_lo(index) 100*baseLine],...
         'w','EdgeColor','none');
     plot(x,100*auxvec_mean,'r','LineWidth',2)
xlabel('Intra-ba');
ylabel('EMME - EMGumbel (%)')