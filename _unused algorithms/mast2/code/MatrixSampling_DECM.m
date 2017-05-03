
%Procedure for creating an ensemble of matrices and sampling from it once 
%the likelihood equation is solved

function [P,W,M]=MatrixSampling_DECM(fitness,LengthMarginals,EnsembleCardinality)

xOutFit=fitness(1:LengthMarginals);
xInFit=fitness((LengthMarginals+1):(2*LengthMarginals));
yOutFit=fitness((2*LengthMarginals+1):(3*LengthMarginals));
yInFit=fitness((3*LengthMarginals+1):(4*LengthMarginals));

P=zeros(LengthMarginals);
W=zeros(LengthMarginals);
        for i=1:LengthMarginals
            for j=1:LengthMarginals
                if i~=j
                   P(i,j)=(xOutFit(i)*xInFit(j)*yOutFit(i)*yInFit(j))/(1-yOutFit(i)*yInFit(j)+xOutFit(i)*xInFit(j)*yOutFit(i)*yInFit(j));
                   W(i,j)=(xOutFit(i)*xInFit(j)*yOutFit(i)*yInFit(j))/((1-yOutFit(i)*yInFit(j))*(1-yOutFit(i)*yInFit(j)+xOutFit(i)*xInFit(j)*yOutFit(i)*yInFit(j)));
                end
            end
        end

%Definition of the ensemble of matrices. Creating a "cell" object, i.e. a 
%list of matrices.
        
Ensemble=cell(1,EnsembleCardinality);
    for k=1:EnsembleCardinality
        WMatrix=zeros(LengthMarginals,LengthMarginals);
        for i=1:LengthMarginals
            for j=1:LengthMarginals
                 if i~=j && rand<P(i,j)
                    WMatrix(i,j)=geornd(1-yOutFit(i)*yInFit(j))+1;
                end
            end
        end
        Ensemble{k}=WMatrix;
    end
M=Ensemble;