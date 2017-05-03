% single prior function. Does the same that dwp, but with a single prior
% and without p_ij^gamma
function output=single_prior(x)
global Qa

aux=0;
qa=roll_on(simp_matrix(Qa));

output=sum(abs(x'-qa'));

%for i=1:length(x)
%    aux=aux+error_measure(x(i),qa(i))
%end

