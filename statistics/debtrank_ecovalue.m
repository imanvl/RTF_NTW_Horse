function R_ = debtrank_ecovalue(A,E,v)
%DebtRank algorithsm
%A ... Matrix of bank's IB exposures
%E ... Vector of bank's equity
%R ... Vector with DebtRank of banks
%v ... Vector of bank's economic value

%A=A'; %this version uses assets matrix, not liabilities

W_ = W(max(0,A),E);
v_ = v/sum(v);
R_ = zeros(size(E));

for m = 1:size(E,1)
    S = zeros(size(E));
    S(m) = 1;
    
    R_(m) = R(W_,v_,S);
end

end
