
function M_mast2 = mast2code(Assets, Liabilities, Density, Ensemble)
tic

Sout=Assets';
Sin=Liabilities;

N=length(Assets);

Kout=ones(N,1) .* Density .* N;
Kin=ones(N,1) .* Density .* N;
Link=N*(N-1)*Density;

LengthMarginals=N;

%The initial point has been chosen in order to speed up the searching process of the algorithm.

x0=[Kout/sqrt(Link);Kin/sqrt(Link);0.9*ones(LengthMarginals,1);0.9*ones(LengthMarginals,1)];

%Solving iteratively the system of equations (in our case, 4N equations in 4N unknowns).

yy = ceil(2*log10(N));

options=optimset('Display','off','Algorithm','interior-point','GradObj','off','DerivativeCheck','off','MaxFunEvals',10^5,'MaxIter',10^yy,'TolX',10^(-32),'TolFun',10^(-32));
fitnessE1=fmincon(@(x)SolverFun_DECM(x,Kout,Kin,Sout,Sin,LengthMarginals),x0,[],[],[],[],zeros(4*LengthMarginals,1),[ones(2*LengthMarginals,1)*Inf;ones(2*LengthMarginals,1)+0.1],[],options);
options=optimset('Display','off','Algorithm','trust-region-reflective','Jacobian','on','DerivativeCheck','off','MaxFunEvals',10^5,'MaxIter',10^yy,'TolX',10^(-32),'TolFun',10^(-32));
fitnessE2=fsolve(@(x)Solver_DECM(x,Kout,Kin,Sout,Sin,LengthMarginals),fitnessE1,options);
options=optimset('Display','off','Algorithm','interior-point','GradObj','off','DerivativeCheck','off','MaxFunEvals',10^5,'MaxIter',10^yy,'TolX',10^(-32),'TolFun',10^(-32));
fitnessE3=fmincon(@(x)SolverFun_DECM(x,Kout,Kin,Sout,Sin,LengthMarginals),fitnessE2,[],[],[],[],zeros(4*LengthMarginals,1),[ones(2*LengthMarginals,1)*Inf;ones(2*LengthMarginals,1)+0.1],[],options);
options=optimset('Display','off','Algorithm','trust-region-reflective','Jacobian','on','DerivativeCheck','off','MaxFunEvals',10^5,'MaxIter',10^yy,'TolX',10^(-32),'TolFun',10^(-32));
fitness=fsolve(@(x)Solver_DECM(x,Kout,Kin,Sout,Sin,LengthMarginals),fitnessE3,options);

for i=1:4*LengthMarginals
    if fitness(i)<0
       fitness(i)=0;
    end
end

%Sampling the ensemble of matrices.

[P,W,M]=MatrixSampling_DECM(fitness,LengthMarginals,Ensemble);

M_mast2 = zeros(N, N,Ensemble);

for i = 1 : Ensemble
    M_mast2(:,:,i) = M{i};
end

%Checking the routine performance.

ExpConstraints=[sum(P')';sum(P)';sum(W')';sum(W)'];
Constraints=[Kout;Kin;Sout;Sin];

if abs(max(ExpConstraints-Constraints))<5
   display('Constraints satisfied');
else
   display('Constraints not satisfied');
end


toc