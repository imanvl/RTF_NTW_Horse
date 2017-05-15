function output=scale_matrix_stochastic(input)
% Function that scales a matrix into a stochastic ones

szmat=size(input);

aux=zeros(szmat(1),szmat(1));
sum_rows=sum(input');

for i=1:szmat(1)
    for j=1:szmat(2)
        aux(i,j)=input(i,j)/sum_rows(i);
    end
end

output=aux;