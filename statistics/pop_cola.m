%colas acostadas
function [Q2,v]=pop_cola(Q)

if Q(1,1)~=0
    n=length(Q);
    v=Q(1,1);
        if n==1
            Q2=0;
        else
            Q2=zeros(1,n-1);
            for i=2:n
                Q2(1,i-1)=Q(1,i);
            end
        end
else Q2=Q;
    v=0;
end
