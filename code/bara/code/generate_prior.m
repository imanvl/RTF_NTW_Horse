% function that transforms any exposure matrix into a feasible prior, i.e.,
% \sum_i s_ij=1
function output=generate_prior(input)

szinput=size(input);
n=szinput(1);
tot=sum(input);
output=zeros(n,n);

for i=1:n
    for j=1:n
      output(i,j)=input(i,j)/tot(j);
    end
end
      