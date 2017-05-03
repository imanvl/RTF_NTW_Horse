function dif_measure=dif_fct(inter_ba,intra_ba,n,n1)

% function that calculates the difference between the error measure
% obtained with ME estimation and with copula (gumbel) estimation given
% inter_ba, intra_ba, n, n1


n2=n-n1;   % number of peripheral banks


for i=1:n1
    for j=1:n1
  A(i,j)=rand*500000+500000;              % Core with exposures between 500000 and 1000000
    end
end

for i=n1+1:n
    for j=1:n1
        A(j,i)=5000+rand*inter_ba;              % Core-periphery exposures between 0 and 5000
    end
end

for i=n1+1:n
    for j=n1+1:n
        A(j,i)=rand*500;               % Periphery exposures between 0 and 500
    end
end


%A=ones(21,21);

for i=1:n
    A(i,i)=0;
end

for i=1:n
    for j=i+1:n
        A(i,j)=A(j,i)+rand*intra_ba;
    end
end

%for i=n1+1:n
%    for j=n1+1:n
%     A(i,j)=0;
%    end
%end

%% Generate max entropy matrix

u=sum(A');
v=sum(A);

m=length(u);
n=length(v);

G=zeros(n,m);

for i=1:m
    for j=1:n
        if i ~= j
        G(i,j)=u(i)/(n-1);
        end
    end
end

% max entropy
Max_entropy=RAS(G,u,v,0.00001);

% Goodness-of-fit evaluation

%ce_max_entropy=cross_entropy(A,Max_entropy)
em_max_entropy=error_measure(A,Max_entropy);

%% Generate copula matrix

H=v;
E=u;
D = [H', E'];
w = H';
f = E';
x = ksdensity(w, w,'function','cdf'); %Transform the data into Copula scale
y = ksdensity(f, f,'function','cdf');
%scatterhist(x,y)
%xlabel('x')
%ylabel('y')
[xx, yy] = meshgrid(x, y);

%% Fitting a traditional copula
options=statset('MaxIter',1000);
[paramhat,paramci] = copulafit('gumbel', [x y]);%, 'Options', options);
j = -log(xx);
l = -log(yy);

%for kk=1:100
alpha=1;
C = exp(-(j.^(paramhat*alpha) + l.^(paramhat*alpha)).^(1/paramhat*alpha));
%Probabilities:
C;


%L = zeros(21);
lu=length(u);
for i = 1:lu
C(i, i) = 0;
end

Z = C;

bilateral_estimates_stochastic=scale_matrix_stochastic(Z);



for i=1:m
    for j=1:n
       B(i,j)=bilateral_estimates_stochastic(i,j)*u(i);
    end
end


bilateral_estimates=RAS(B,u,v,0.00001);

em_max_gumbel=error_measure(A,bilateral_estimates);

dif_measure=em_max_entropy-em_max_gumbel;
