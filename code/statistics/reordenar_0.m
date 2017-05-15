function P3=reordenar_0(P2,i,cont)

    Id=eye(length(P2));

    aux_i=Id(i,:);

    aux_cont=Id(cont,:);

    Id(i,:)=aux_cont;

    Id(cont,:)=aux_i;

    P3=(Id*P2)*Id;

end