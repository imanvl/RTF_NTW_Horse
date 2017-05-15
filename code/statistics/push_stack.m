%stack parado
function S2=push_stack(S,v)

% if S(1,1)~=0
%    n=length(S);
%    Q(1,n+1)=v;
% 
% else Q(1,1)=v;
%     
%end

if S(1,1)~=0
    n=length(S);
    
    for i=1:n
        S2(i+1,1)=S(i,1);
    end
    S2(1,1)=v;
        
else S2(1,1)=v; 
    
end