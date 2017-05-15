% function that recovers from the simplified matrix
function output=recov_matrix(input,n)

aux=zeros(n,n);

k=0;
for i=1:n
    for j=1:n
        if i~=j
            k=k+1;
            aux(i,j)=input(k);
        end
    end
end

output=aux;
            