% Script that uses monte carlo simulations to find the contrained matrix

%%
clear all
clc

inter_ba=100;                             % Inter Block Asymmetry
intra_ba=10;                             % Intra Block Asymmetry
n=11;
n1=2;
n2=n-n1;


for i=1:n1
    for j=1:n1
  A(i,j)=rand*5000+5000;              % Core with exposures between 5000 and 10000
    end
end

for i=n1+1:n
    for j=1:n1
        A(j,i)=rand*inter_ba;              % Core-periphery exposures between 0 and 500
    end
end

for i=1:n
    for j=n1+1:n
        A(j,i)=rand*1;               % Periphery exposures between 0 and 50
    end
end


%A=ones(21,21);

for j=1:n
    for i=j+1:n
        A(i,j)=A(j,i)+rand*intra_ba;            %Changes the lower (left) triangular part of A.
    end
end

for i=n1+1:n
    for j=n1+1:n
      %A(i,j)=0;                            %Periphery-Periphery set to 0
       A(i,j)=rand*50 + 50
    end
end

for i=1:n
    A(i,i)=0;
end

%Qa=generate_prior(A);
%qa=simp_matrix(roll_on(Qa));

%% Generate max entropy matrix

u=sum(A');
v=sum(A);

m=length(u);
n=length(v);

G=zeros(n,m);

for i=1:m
    for j=1:n
        if i ~= j
        G(i,j)=u(i)/((n-1)+(1e-10));
        end
    end
end

% max entropy
Max_entropy=RAS(G,u,v,0.001);

% Goodness-of-fit evaluation


em_max_entropy=error_measure(A,Max_entropy)

%% Generate copula matrix

%H = [263568, 519251, 466128, 417825, 305089, 87327, 1560650, 620016, 175944, 1133296, 2657994, 132066, 449501, 236948, 842227, 845716, 717589, 199219, 140316, 150217,5154184];
%E = [164150, 265697, 267268, 749220, 1409794, 1997, 2224449, 929507, 18935, 2389814, 2564646, 63466, 370196, 27826, 598811, 1868847, 996659, 86699, 321063, 19013, 1901164];
H=u;
E=v;
D = [H', E'];
w = H';
f = E';
x = ksdensity(w, w,'function','cdf'); %Transform the data into Copula scale
y = ksdensity(f, f,'function','cdf');
scatterhist(x,y)
xlabel('x')
ylabel('y')
[xx, yy] = meshgrid(x, y);

%% Fitting a traditional copula
options=statset('MaxIter',1000000);
[paramhat,paramci] = copulafit('gumbel', [x y]);%, 'Options', options);
j = -log(xx);
k = -log(yy);

%for kk=1:100
%alpha=1;
C = exp(-(j.^(paramhat) + k.^(paramhat)).^(1/paramhat));
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
%Qa=generate_prior(bilateral_estimates);
%Qa=generate_prior(A);
%qa=simp_matrix(roll_on(Qa));      %simp_matrix removes the diag from the matrix. roll_on function vectorizes a matrix. So, size of qa is 25 - 5 where 
                                  %5 is the number of elements in the diagonal

em_max_gumbel=error_measure(A,bilateral_estimates)

options=statset('MaxIter',1000000);
%[paramhatfour,paramcifour] = copulafit('gumbel', [x y]);%, 'Options', options);
%for kk=1:100
%alpha=1;
Cind = xx.*yy
%Probabilities:
Cind;


%L = zeros(21);
lu=length(u);
for i = 1:lu
Cind(i, i) = 0;
end

Zind = Cind;

bilateral_estimates_stochasticind=scale_matrix_stochastic(Zind);



for i=1:m
    for j=1:n
       Bind(i,j)=bilateral_estimates_stochasticind(i,j)*u(i);
    end
end


bilateral_estimates_ind=RAS(Bind,u,v,0.00001);
%Qa=generate_prior(bilateral_estimates);
%Qa=generate_prior(A);
%qa=simp_matrix(roll_on(Qa));      %simp_matrix removes the diag from the matrix. roll_on function vectorizes a matrix. So, size of qa is 25 - 5 where 
                                  %5 is the number of elements in the diagonal

em_max_ind=error_measure(A,bilateral_estimates_ind)

%[paramhatone,paramcione] = copulafit('frank', [x y]);%, 'Options', options);
%r = -1/(paramhatone);
%m1 = exp(-paramhatone.*xx) - 1;
%m2 = exp(-paramhatone.*yy) - 1;
%e = exp(- paramhatone) - 1;
%frank = r*log(1 + (m1*m2)/e);

%F = frank

%bilateral_estimates_stochastic_frank=scale_matrix_stochastic(F);


%for i=1:m
 %   for j=1:n
  %     F(i,j)=bilateral_estimates_stochastic_frank(i,j)*u(i);
   % end
%end

%frank_estimate=RAS(F,u,v,0.00001);
%Qb=generate_prior(frank_estimate);
%qb=simp_matrix(roll_on(Qb));

%em_max_frank=error_measure(A,frank_estimate)


[paramhattwo,paramcitwo] = copulafit('clayton', [x y]);%, 'Options', options);
q = -1/(paramhattwo);
q1 = xx.^(-paramhattwo);
q2 = yy.^(-paramhattwo);
clayton = (q1 + q2 - 1).^q;

L = clayton

bilateral_estimates_stochastic_clayton=scale_matrix_stochastic(L);


for i=1:m
    for j=1:n
      L(i,j)=bilateral_estimates_stochastic_clayton(i,j)*u(i);
  end
end

clayton_estimate=RAS(L,u,v,0.00001);
%Ql=generate_prior(clayton_estimate);
%ql=simp_matrix(roll_on(Ql));

em_max_clayton=error_measure(A,clayton_estimate)


%Define new variables
nq = length(qa);
g = 0.9;             %proportion of Gumbel
%h = 0.2;             %proportion of clayton
nq1 = g*nq ;         %Number of elements to be taken from qa  
nq2 = (1 - g)*nq ;         %Number of elements to be taken from ql
%nq3 = (1 - g - h)*nq

qstar = zeros(1, nq);    %Initialize vector for mixture of gumbel and frank with 0.4*Gumbel and 0.6* Frank, i.e., first 40% are of Gumbel and last 60% are of Frank.

for r = 1:nq1
qstar(1, r) = qa(1, r);
end

for s = nq1+1:nq2
qstar(1, s) = ql(1, s)
end

%for t = nq1+1:nq
%for t = nq1+1:nq
%qstar(1, t) = qb(1, t)
%end

%for t = nq2+1:nq
%qstar(1, t) = qb(1, t)
%end



%% Optimization Problem via MC

% Parameters
szA=size(A);
N=szA(1);             % Number of nodes in the network


% Restrictions
  
  % Initialize restrictions matrix and independent term

R=zeros(1,N*N);  %R is the restriction matrix, and B is the target matrix. For e.g., Ax = B where A = R. And in our case, x = p_{i, j}'s in a matrix form.
B=0;

  % First set restrictions: \sum_j p_ij*v_j=y_i [equation 7]
 
  for i=1:N
      aux=zeros(N,N);
      for j=1:N
          aux(i,j)=v(j)/sum(v);
      end
        R=vertcat(R,roll_on(aux));
        B=vertcat(B,u(i)/sum(u));
  end
  
  % Second set of restrictions*: \sum_i p_ij=1 [equation 8] THESE WILL BE
  % SELF IMPOSED BY THE MC METHOD
  
  %for j=1:N
   %   aux=zeros(N,N);
   %   for i=1:N
   %       aux(i,j)=1;
   %   end
   %   R=vertcat(R,roll_on(aux));
   %   B=vertcat(B,1);
 % end
  
  % Diagonal with 0's
  
% for i=1:n1
 %     aux=zeros(N,N);
 %     aux(i,i)=1;
 %     R=vertcat(R,roll_on(aux));
 %     B=vertcat(B,0);
%  end
  
  % Empty periphery-periphery

  %for i=n1+1:N
  %aux=zeros(N,N);
  %for j=n1+1:N
   %   aux(i,j)=1;
   %end
    %R=vertcat(R,roll_on(aux));
     %B=vertcat(B,0);
  %end
     
  R=R(2:end,:);
  B=B(2:end);
 
  R=simp_matrix(R);
  
  %% MC
  
  %guess=qa;
  guess=qstar
  M=1000000000000000000000000000;
  of=inf;
  %tol=5;
  iter=1;
  
  while iter<10000%of>tol
      
      l=length(guess);
      
      aux=guess;
      
      for i=1:l
          aux2=guess;
          aux2(i)=aux2(i)+rand*5;
          aux2=recov_matrix(aux2,N);
          aux2=generate_prior(aux2);
          aux=vertcat(aux,simp_matrix(roll_on(aux2)));
      end
      
      szaux=size(aux);
      
      for k=1:szaux(1)
          %objaux(k)=sum((aux(k,:)-qa)*(aux(k,:)'-qa'))+sum(abs(R*aux(k,:)'-B))*M;
          %objaux(k)=sum(abs(aux(k,:)'-qa'))+sum(abs(R*aux(k,:)'-B))*M;
          objaux(k)=sum(abs(aux(k,:)'-qstar'))+sum(abs(R*aux(k,:)'-B))*M;
          %objaux(k)=sum((aux(k,:)-qstar)*(aux(k,:)'-qstar'))+sum(abs(R*aux(k,:)'-B))*M;
          if objaux(k)<of
              of=objaux(k);
              aux_star=aux(k,:);
          end
      end
     
      guess=aux_star;
      iter=iter+1;
      clc
      fprintf('%g',iter/10000);
  end
  
  
  %objaux_star=sum(abs(aux_star'-qa'))+sum(abs(R*aux_star'-B))*M
  objaux_star=sum(abs(aux_star'-qstar'))+sum(abs(R*aux_star'-B))*M
  %objaux_star=sum((aux_star'-qstar')*(aux_star - qstar))+sum(abs(R*aux(k,:)'-B))*M
  
  SP=recov_matrix(aux_star,N);
  
  for j=1:m
    for i=1:n
       SP(i,j)=SP(i,j)*v(j);
    end
  end

em_max_sp=error_measure(A,SP)
em_max_entropy
em_max_gumbel
%em_max_frank
 em_max_clayton     
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
  