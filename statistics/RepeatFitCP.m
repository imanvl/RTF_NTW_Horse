function [core errors error]=RepeatFitCP(M,T)
% Fits core-periphery T times (default 10) to network M
% and picks miminum - to see whether solution is reliable
% Call this routine e.g. like this
%[core errors error]=RepeatFitCP(tierednet(100,10,0.1),10)
%[core errors error]=RepeatFitCP(rand(100,100)>0.05,10)
% RUN FIRST load 'C:\Users\cbmepego\data\ForPapers\NetworkData\Tiering.mat'
% Goetz von Peter 2013

if nargin<2
    T=10;
end

% ========= T Realisations, build sequence M(t) =========
Errors=zeros(4,T); Cores=zeros(size(M,1),T);
for t=1:T
    %M=tierednet(1800,42,0.56/100); spy(M)
    %display(['Fitting network #',num2str(t)])
    %[Core LossFun]=PublicUseCore(M);           % Public version
    [Core LossFun]=CorePeriphery(M);           % amend lines 413 onward to experiment
    %[Core LossFun]=CorePeripheryDiag(M);       % Ignoring off-diagonal errors (Borgatti)
    %[Core LossFun]=CorePeripheryStrong(M);      % FULL regularity on CP and PC blocks
    %[Core LossFun]=CorePeripheryFunctional(M); % Silo version - wrong.
    Errors(:,t) = LossFun';
    Cores(:,t)  = Core;
end
score=sum(Errors);              % row vector of total errors
core =sum(Cores);               % row vector of number of core banks
%plot([score; core]);

y=find(score==min(score));      % where are the minima
error=score(y);

coresize=sum(Cores(:,y));
z=find(coresize==min(coresize));% pick the smallest core among min errors
foundit=y(z(1));                % just take first element if there are several
errors=Errors(:,foundit);       
error =sum(errors(:));          % sums up error matrix of best result
core=Cores(:,foundit);

% display('***************** REPORT *****************')
% display(['Core size (# banks):             ', num2str(nnz(core))])
% display(['Core size (% banks):             ', num2str(100*nnz(core)/size(M,1)) ])
% display(['Errors (absolute number):        ', num2str(error)])
% display(['Error score (% of active links): ', num2str(100*error/nnz(M))])


%Activate to show output 
% score
% Errors
% Cores
% foundit


close all
% figure;
% bar(1:T, Errors', 'stack');
% %axis([0 13 0 100000]);
% title('Errors in each block');
% xlabel('Run');
% ylabel('Number of errors');
% legend('CC', 'CP', 'PC','PP');


