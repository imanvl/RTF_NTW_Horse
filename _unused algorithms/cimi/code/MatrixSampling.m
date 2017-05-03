
%Procedure for creating an ensemble of matrices and sampling matrices once 
%the likelihood equation is solved

function M=MatrixSampling(z,SOut,SIn,LengthMarginals,EnsembleCardinality)

%Definition of the ensemble of matrices. Creating a "cell" object, i.e. a 
%list of matrices.

TotOut=sum(SOut);
TotIn=sum(SIn);
Ensemble=cell(1,EnsembleCardinality);

    for k=1:EnsembleCardinality
        WMatrix=zeros(LengthMarginals,LengthMarginals);
        for i=1:LengthMarginals
            for j=1:LengthMarginals
                 if  i~=j && rand<(z*SOut(i)*SIn(j))/(1+z*SOut(i)*SIn(j))
                     WMatrix(i,j)=(SOut(i)*SIn(j)+1/z)/sqrt(TotOut*TotIn);
                end
            end
        end
        Ensemble{k}=WMatrix;
    end
M=Ensemble;