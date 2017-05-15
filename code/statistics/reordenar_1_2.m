function [P2,abs2]=reordenar_1_2(P2,abs2, cont,n,k)

v1=abs2(1:cont,1);

dos=find(v1==k);

v2=abs2(cont+1:end,1);

ceros=find(v2==0);

clear v1 v2

for i=1:length(dos)

    Id=eye(n);

    aux0=Id(cont+ceros(i),:);

    aux2=Id(dos(i),:);

    Id(dos(i),:)=aux0;

    Id(cont+ceros(i),:)=aux2;

    P2=(Id*P2)*Id;

    abs2=Id*abs2;

end

end