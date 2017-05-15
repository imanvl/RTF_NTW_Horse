%stack parado
function [S2,v]=pop_stack(S)

if S(1,1)~=0
    v=S(1,1);
    n=length(S);
            if n==1
                S2=0;
            else
                S2=zeros(n-1,1);
                for i=2:n
                    S2(i-1,1)=S(i,1);
                end
            end
    
else S2=S;
    v=0;
end