
%Procedure for computing the likelihood function of our null model, given
%the constraints, creating an ensemble of matrices and sampling matrices 
%once the likelihood equation is solved

function M_cimi = cimicode(Assets, Liabilities, Density, Ensemble)

%The number of links is set to 250. Notice that the total number of
%links must be known in advance.
%The number of banks (and, thus, the dimension of the vector of marginals)
%is deduced from the dimension of the SOut and SIn vectors.
%The ensemble cardinality is set to 1000.

SOut = Assets;
SIn = Liabilities;

Link=length(Assets) * (length(Assets) - 1) * Density;
LengthMarginals=length(SOut);
EnsembleCardinality=Ensemble;

%The initial point has been chosen in order to speed up the searching 
%process of the algorithm.

eps=sum(SOut)/Link;
x0=1/(Link*eps^2);

%Solving the system of equations (in our case, one equation in one
%unknown).

options=optimset('Display','off','Algorithm','trust-region-reflective','Jacobian','on','MaxIter',10^5,'TolX',10^(-32),'TolFun',10^(-32));

x=fsolve(@(x)SystemSolver(x,SOut,SIn,LengthMarginals,Link),x0,options);

%Sampling the ensemble of matrices.

M=MatrixSampling(x,SOut,SIn,LengthMarginals,EnsembleCardinality);

M_cimi = zeros(length(SOut), length(SOut), EnsembleCardinality);
for e = 1 : EnsembleCardinality
    M_cimi(:,:,e) = cell2mat(M(e));
end