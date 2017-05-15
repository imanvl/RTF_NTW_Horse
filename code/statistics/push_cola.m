%cola acostada
function Q=push_cola(Q,v)

% %for i=length(Q):-1:1
% i=length(Q);
%     if Q(1,i)==0
%         Q(1,i)=v;
%     else Q(1,i+1)=v;
%     end
% %end


if Q(1,1)~=0
   n=length(Q);
   Q(1,n+1)=v;
else Q(1,1)=v;
    
end