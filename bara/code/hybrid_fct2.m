function output=hybrid_fct2(g)
global H sss H1 qstar ql  iter iter_max u v paramci paramhat
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
[paramhat,paramci] = copulafit('Gumbel', [x y]);%, 'Options', options);
j = -log(xx);
k = -log(yy);
paramhat;
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

bilateral_estimates=RAS(B,u,v,1);
%Qa=generate_prior(bilateral_estimates);
%Qa=generate_prior(A);
%qa=simp_matrix(roll_on(Qa));      %simp_matrix removes the diag from the matrix. roll_on function vectorizes a matrix. So, size of qa is 25 - 5 where 
                                  %5 is the number of elements in the diagonal
if g==1
    output=bilateral_estimates;
else
 %   Progress
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
%Qa=generate_prior(bilateral_estimates);
%Qa=generate_prior(A);
%qa=simp_matrix(roll_on(Qa));      %simp_matrix removes the diag from the matrix. roll_on function vectorizes a matrix. So, size of qa is 25 - 5 where 
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


[paramhat,paramci] = copulafit('Clayton', [x y]);%, 'Options', options);

q = -1/(paramhat);
q1 = xx.^(-paramhat);
q2 = yy.^(-paramhat);
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

output=RAS(L,u,v,0.1);

end
      