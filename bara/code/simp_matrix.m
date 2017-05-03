% function that simplifies the matrix to eliminate the diagonal elements
function output=simp_matrix(input)

szmat=size(input);
n=szmat(2);

aux=zeros(szmat(1),1);
k=0;
for j=1:n
    if j~=1+(sqrt(n)+1)*k
    aux=horzcat(aux,input(:,j));
    else
        k=k+1;
    end
end

output=aux(:,2:end);
