function v = v(A)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

A_ = sum(A,2);

v = A_ / sum(A_);

end
