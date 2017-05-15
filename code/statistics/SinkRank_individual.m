function sr=SinkRank_individual(P2,cont)

alpha=1e-4;

P3=alpha*P2(1:cont,1:cont)+(1-alpha)/cont;

Id=eye(cont);

Q=(Id-P3)\Id;%Matriz fundamental

sr=sum(sum(Q))/(cont);

end