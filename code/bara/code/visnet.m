% script that enables network visualization based on an adjacency matrix
n=110;
A=randi(2,n,n)-ones(n,n);

for i=1:n
A(i,i)=0;
end

% 1. get marginals
u=sum(A);
v=sum(A');
      
% 2. get position indices
      [s,s1]=sort(u,'descend');
      for i=1:length(u)
      ord(s1(i))=i;
      end

% 3. get quantiles
  q=quantile(u',[0.25 0.75]);
             
% 4. Create sets to be aglomerated in the "rings"
  
  % largest element to be put at the center of the plot
             for i=1:length(u)
  if (ord(i)==1)
             LE=i;
             break;
             end
             end
             
   % first quartile
             firstq=0;
             for i=1:length(u)
             if (u(i)<=q(1))
             firstq=[firstq i];
             end
             end
             firstq=firstq(2:end);
   
             % last quartile
             lastq=0;
             for i=1:length(u)
             if (u(i)>q(1) && u(i)<u(LE))
             lastq=[lastq i];
             end
             end
             lastq=lastq(2:end);


%5. Define coordinates
             r=0.24;
             XY(LE,:)=[0.5 0.5];
             
             for i=1:length(lastq)
             XY(lastq(i),:)=[0.5+r*cos((i-1)*(2*pi)/length(lastq))+(-1)^(i)*0.005 0.5+r*sin((i-1)*(2*pi)/length(lastq))+(-1)^(i+1)*0.005];
end

             for i=1:length(firstq)
             XY(firstq(i),:)=[0.5+2*r*cos((i-1)*(2*pi)/length(firstq))+(-1)^(i)*0.005 0.5+2*r*sin((i-1)*(2*pi)/length(firstq))+(-1)^(i+1)*0.005];
             end

             Alowtri=A;
             
             for i=1:n
             for j=1:n
                if (j>i)
             Alowtri(i,j)=0;
end
end
end
             Alowtri;
             
             gplot(A,XY,'b-*')
axis([0 1 0 1])