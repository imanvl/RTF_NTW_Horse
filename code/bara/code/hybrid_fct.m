function output=hybrid_fct(g)
global H sss H1 qstar ql iter iter_max u v
% Function that uses monte carlo simulations to find the contrained matrix
iter=0.0000001;

  iter_max=10;
% Dependencies
 % l36  bilateral_estimates=RAS(B,u,v,0.00001);
%l205 R=simp_matrix(R);
%l225  aux2=recov_matrix(aux2,n);
%l226 aux2=generate_prior(aux2);
%l227   aux=vertcat(aux,simp_matrix(roll_on(aux2)));

n=length(u);
D = [u', v'];
w = u';
f = v';
x = ksdensity(w, w,'function','cdf'); %Transform the data into Copula scale
y = ksdensity(f, f,'function','cdf');
%scatterhist(x,y)
%xlabel('x')
%ylabel('y')
[xx, yy] = meshgrid(x, y);

%% Fitting a traditional copula
options=statset('MaxIter',1000000);
[paramhat,paramci] = copulafit('gumbel', [x y]);%, 'Options', options);
j = -log(xx);
k = -log(yy);
paramhat
%for kk=1:100
%alpha=1;
C = exp(-(j.^(paramhat) + k.^(paramhat)).^(1/paramhat));
%Probabilities:

for i = 1:n
C(i, i) = 0;
end
bilateral_estimates_stochastic=scale_matrix_stochastic(C);
for i=1:n
    for j=1:n
       B(i,j)=bilateral_estimates_stochastic(i,j)*u(i);
    end
end

bilateral_estimates=RAS(B,u,v,0.00001);
%Qa=generate_prior(bilateral_estimates);
%Qa=generate_prior(A);
%qa=simp_matrix(roll_on(Qa));      %simp_matrix removes the diag from the matrix. roll_on function vectorizes a matrix. So, size of qa is 25 - 5 where 
                                  %5 is the number of elements in the diagonal
if g==1
    output=bilateral_estimates;
else
    Progress
%options=statset('MaxIter',1000000);
%[paramhatfour,paramcifour] = copulafit('gumbel', [x y]);%, 'Options', options);
%for kk=1:100
%alpha=1;
%Cind = xx.*yy;
%Probabilities:
%Cind;

%for i = 1:n
%Cind(i, i) = 0;
%end
%bilateral_estimates_stochasticind=scale_matrix_stochastic(Cind);

%for i=1:n
 %   for j=1:n
  %     Bind(i,j)=bilateral_estimates_stochasticind(i,j)*u(i);
  %  end
%end


%bilateral_estimates_ind=RAS(Bind,u,v,0.00001);
Qa=generate_prior(bilateral_estimates);
%Qa=generate_prior(A);
qa=simp_matrix(roll_on(Qa));      %simp_matrix removes the diag from the matrix. roll_on function vectorizes a matrix. So, size of qa is 25 - 5 where 
                                  %5 is the number of elements in the diagonal


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
paramhattwo
q = -1/(paramhattwo);
q1 = xx.^(-paramhattwo);
q2 = yy.^(-paramhattwo);
clayton = (q1 + q2 - 1).^q;
for i = 1:n
clayton(i, i) = 0;
end
bilateral_estimates_stochastic_clayton=scale_matrix_stochastic(clayton);


for i=1:n
    for j=1:n
      L(i,j)=bilateral_estimates_stochastic_clayton(i,j)*u(i);
  end
end

clayton_estimate=RAS(L,u,v,0.00001);
Ql=generate_prior(clayton_estimate);
ql=simp_matrix(roll_on(Ql));


%Define new variables
nq = length(qa);
                     % g is proportion of Gumbel
%h = 0.2;             %proportion of clayton
nq1 = round(g*nq) ;         %Number of elements to be taken from qa  
%nq2 = nq-nq1;         %Number of elements to be taken from ql
%nq3 = (1 - g - h)*nq

qstar = zeros(1, nq);    %Initialize vector for mixture of gumbel and frank with 0.4*Gumbel and 0.6* Frank, i.e., first 40% are of Gumbel and last 60% are of Frank.

for r = 1:nq1
qstar(1, r) = qa(1, r);
end

for s = nq1+1:nq
qstar(1, s) = ql(1, s);
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

% Restrictions
  
  % Initialize restrictions matrix and independent term

R=zeros(1,n*n);  %R is the restriction matrix, and B is the target matrix. For e.g., Ax = B where A = R. And in our case, x = p_{i, j}'s in a matrix form.
B=0;

  % First set restrictions: \sum_j p_ij*v_j=y_i [equation 7]
 
  for i=1:n
      aux=zeros(n,n);
      for j=1:n
          aux(i,j)=v(j)/(sum(v)+1e-10);
      end
        R=vertcat(R,roll_on(aux));
        B=vertcat(B,u(i)/(sum(u)+1e-10));
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
  guess=qstar;
  M=1e8;
  of=inf;
  %tol=5;
  iter=0;
  l=length(guess);
  while iter<iter_max%of>tol
      
      
      
      aux=guess;
      
      for i=1:l
          
          aux2=guess;
          aux2(i)=aux2(i)+rand*5;
          aux2=recov_matrix(aux2,n);
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
      Progress
      %clc
      %fprintf('%g',iter/10000);
  end
  
  
  %objaux_star=sum(abs(aux_star'-qa'))+sum(abs(R*aux_star'-B))*M
 % objaux_star=sum(abs(aux_star'-qstar'))+sum(abs(R*aux_star'-B))*M;
  %objaux_star=sum((aux_star'-qstar')*(aux_star - qstar))+sum(abs(R*aux(k,:)'-B))*M
  disp 'stuff done!'
  SP=recov_matrix(aux_star,n);
  
  for i=1:n
      SP(i,i)=0;
  end
  sss=sum(SP');
  for i=1:n
      for j=1:n
      SP(i,j)=SP(i,j)/(sss(i)+1e-15);
      end
  end
  H1=SP;
  for i=1:n
    for j=1:n
       SP(i,j)=SP(i,j)*v(i);
    end
  end
    H=SP;
  output=RAS(SP,u,v,100);
end
      