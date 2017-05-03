function dist=jsdiv(P,Q)
% This function complete the Jensen Shannon divergence between the vectors
% P and Q. JS(P,Q) = (KL(P,Q) + KL(Q,P))/2, where KL(P,Q) is the
% Kulbeck-Leibler distance between objects P and Q

M=log(P./Q); 
M(isnan(M))=0;
M(isinf(M))=0;

N = log(Q./P);
N(isnan(N))=0;
N(isinf(N))=0;

dist = 0.5*sum(P.*M) + 0.5*sum(Q.*N); 
end