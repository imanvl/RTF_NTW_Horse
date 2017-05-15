function output=RAS(A_0,u,v,tol)
% Source: SCHNEIDERM, . H., ANDS . A. ZENIOS1 (1990). A Comparative Study of Algorithms for Matrix Balancing. Opns. Res. 38, 439-455.
% function that returns the rebalanced matrix given:
% - A_0,the initial matrix A (e.g., the one obatined by dividing total
% exposures equaly);
% - u, vector of a priori sum of the rows;
% - v, vector of a priori sum of the columns;
% - tol, the tolerance assigned to the stopping rule.

% Nr. of rows
m=length(u);

% Nr. of columns
n=length(v);

% Step 0 (Initialization)

A_aux=A_0;
tol_effective=inf;
k=1;
while tol_effective>tol %k<max_iter || 
 
% Step 1 (Row Scaling)

for i=1:m
    if sum(A_aux(i,:))>0
    rho(i)=u(i)/sum(A_aux(i,:));
    else
        rho(i)=0;
    end
end

for i=1:m
    for j=1:n
A_aux2(i,j)=rho(i)*A_aux(i,j);
    end
end

 % Step 2 (Column Scaling)

for j=1:n
    if sum(A_aux(:,j))>0
    sigma(j)=v(j)/sum(A_aux(:,j));
    else
        sigma(j)=0;
    end
end


for i=1:m
    for j=1:n
A_aux2(i,j)=sigma(j)*A_aux2(i,j);
    end
end

tol_effective=0;

for i=1:m
    for j=1:n
tol_effective=tol_effective+abs(A_aux(i,j)-A_aux2(i,j));
    end
end
tol_effective;
k=k+1;
A_aux=A_aux2;
end
%fprintf('converged after %d iterations',k);

output=A_aux;
%output(2)=rho;
%output(3)=sigma;