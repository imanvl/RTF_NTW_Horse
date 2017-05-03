function [R,s,h] = R(W,v,S)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

h = zeros(size(v));
s = zeros(size(v));
s(S == 1) = 1;
h(S == 1) = 1;

while any(s == 1)
    h = min(1,h + W(s == 1,:)' * h(s == 1));
    s(s == 1) = 2;
    s(h > 0 & s ~= 2) = 1;
end

R = sum(h .* v) - sum(h(S == 1) .* v(S == 1));
h(S == 1) = 0;
s = zeros(size(v));
s(h == 1 & S ~= 1) = 1;

end
