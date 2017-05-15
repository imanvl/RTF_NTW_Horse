
function [fitness,M,str]=Main_DECM(InputMatrix,EnsembleCardinality)

%commonFactor = max(max(InputMatrix));
%InputMatrix = InputMatrix / commonFactor;

Sout=sum(InputMatrix')';
Sin=sum(InputMatrix)';
W=sum(Sout);

BinaryMatrix=sign(InputMatrix);

% Kout=sum(BinaryMatrix')';
% Kin=sum(BinaryMatrix)';
% Link=sum(Kout);
% LengthMarginals=length(Kout);

LengthMarginals=length(Sout);
Link=sum(sum(BinaryMatrix));
Kout=(Link/LengthMarginals)*ones(LengthMarginals,1);
Kin=(Link/LengthMarginals)*ones(LengthMarginals,1);

%The initial point has been chosen in order to speed up the searching process of the algorithm.

x0=[Kout/sqrt(Link);Kin/sqrt(Link);0.9*ones(LengthMarginals,1);0.9*ones(LengthMarginals,1)];

%Solving iteratively the system of equations (in our case, 4N equations in 4N unknowns).

options=optimset('Display','iter','Algorithm','interior-point','GradObj','off','DerivativeCheck','off','MaxFunEvals',10^5,'MaxIter',10^3,'TolX',10^(-32),'TolFun',10^(-32));
fitnessE1=fmincon(@(x)SolverFun_DECM(x,Kout,Kin,Sout,Sin,LengthMarginals),x0,[],[],[],[],zeros(4*LengthMarginals,1),[ones(2*LengthMarginals,1)*Inf;ones(2*LengthMarginals,1)+0.1],[],options);
options=optimset('Display','iter','Algorithm','trust-region-reflective','Jacobian','on','DerivativeCheck','off','MaxFunEvals',10^5,'MaxIter',10^3,'TolX',10^(-32),'TolFun',10^(-32));
fitnessE2=fsolve(@(x)Solver_DECM(x,Kout,Kin,Sout,Sin,LengthMarginals),fitnessE1,options);
options=optimset('Display','iter','Algorithm','interior-point','GradObj','off','DerivativeCheck','off','MaxFunEvals',10^5,'MaxIter',10^3,'TolX',10^(-32),'TolFun',10^(-32));
fitnessE3=fmincon(@(x)SolverFun_DECM(x,Kout,Kin,Sout,Sin,LengthMarginals),fitnessE2,[],[],[],[],zeros(4*LengthMarginals,1),[ones(2*LengthMarginals,1)*Inf;ones(2*LengthMarginals,1)+0.1],[],options);
options=optimset('Display','iter','Algorithm','trust-region-reflective','Jacobian','on','DerivativeCheck','off','MaxFunEvals',10^5,'MaxIter',10^3,'TolX',10^(-32),'TolFun',10^(-32));
fitness=fsolve(@(x)Solver_DECM(x,Kout,Kin,Sout,Sin,LengthMarginals),fitnessE3,options);

for i=1:4*LengthMarginals
    if fitness(i)<0
       fitness(i)=0;
    end
end

%Sampling the ensemble of matrices.

[P,W,M]=MatrixSampling_DECM(fitness,LengthMarginals,EnsembleCardinality);
%M = M .* commonFactor;
%Checking the routine performance.

ExpConstraints=[sum(P')';sum(P)';sum(W')';sum(W)'];
Constraints=[Kout;Kin;Sout;Sin];

if abs(max(ExpConstraints-Constraints))<5
   str=sprintf('Constraints satisfied');
else
   str=sprintf('Constraints not satisfied');
end