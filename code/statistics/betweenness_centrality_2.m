% For unweighted graphs, the algorithm can be implemented as described
% in Algorithm 1. Note that the centrality scores need to be divided by two
% if the graph is undirected, since all shortest paths are considered
% twice. The modifications necessary for weighted graphs are straightforward.

function CB=betweenness_centrality_2(A,G)

n=length(A(:,1));
CB=zeros(n,1);

for s=1:n
   
    if sum(A(s,:))~=0
    
       S=0; %empty stack
       P=zeros(n);%cada columna es una lista
       sigma=zeros(1,n); 
       sigma(s)=1;
       d=-1*ones(1,n); 
       d(s)=0;
 
       Q=0; %empty queue
       Q=push_cola(Q,s);
       
       while sum(Q)~=0   
             [Q,v]=pop_cola(Q);
             S=push_stack(S,v);
             vec=vecinos(A,v); 
             
             
             l=1;
             for w=1:length(vec)
             %w found for the first time?
                 if d(vec(1,w))<0
                     Q=push_cola(Q,vec(1,w));
                     d(vec(1,w))=d(v)+1;
                 end
              %shortest path to w via v?  
                 if d(vec(1,w))==d(v)+1
                     sigma(vec(1,w))=sigma(vec(1,w))+sigma(v);
                     P(l,vec(1,w))=v;
                     l=l+1;
                 end
              end
        end
        delta=zeros(1,n);

        while sum(S)~=0
            [S,w]=pop_stack(S);
            
               for v=1:length(P(:,w))
                   if P(v,w)~=0
                       delta(P(v,w))=delta(P(v,w))+(sigma(P(v,w))/sigma(w))*(1+delta(w));
                       if w~=s
                            CB(w)=CB(w)+delta(w);
                       end
                   end
               end
            
        end
     
        
   end
end


%CB(:,2)=(G.etiqueta)';
end



