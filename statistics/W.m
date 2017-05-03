function W = W(A,E)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

W=min(1,A'./(ones(size(E))*E'));

end
