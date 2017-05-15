function output=error_measure(A,B)
% Function that returns the error between two matrices. Matrix A is
% the true matrix and B is the estimated one

szmat=size(A);
aux=0;
tot=sum(sum(A));

for i=1:szmat(1)
    for j=1:szmat(2)
       
        aux=aux+abs(B(i,j)-A(i,j));
        
    end
end

output=aux/tot;