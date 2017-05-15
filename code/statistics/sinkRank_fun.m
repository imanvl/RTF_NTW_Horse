function SR=sinkRank_fun(W)

%Create a transition matrix, P
m=length(W);
P=zeros(m);
for i=1:m
    P(i,:)=W(i,:)*(1/sum(W(i,:)));
end

%Encontrar los estados absorbentes (v?rtices que tienen 1 en su rengl?n) y
%los estados inalcanzables (los bancos que no recibieron ning?n pago y tienen NaN)
%se crear? un vector con entradas 0, 1 o 2 se?alando el tipo de v?rtice
n=length(W(:,1));
absorbentes=zeros(n,2);%los v?rtices no absorbentes tienen 0
cont_abs=0;
cont_inalc=0;
for i=1:n
    if max(P(i,:))==1
        absorbentes(i,1)=1;%los v?rtices absorbentes tienen 1
        cont_abs=cont_abs+1;
    elseif isnan(P(i,1))
        absorbentes(i,1)=2;%los v?rtices inalcanzables tienen 2
        cont_inalc=cont_inalc+1;
    end
end

absorbentes(:,2)=-1;%poner las etiquetas en la segunda columna para no perderlos
cont=n-cont_abs-cont_inalc;

P2=P;
P2(isnan(P2))=0;%cambiar los NaN por ceros
abs2=absorbentes;
%reordenar la matriz de transici?n y la de etiquetas, poniendo los
%inalcanzables al final
[P2,abs2]=reordenar_1_2(P2,abs2, cont,n,2);
%despu?s poner los absorbentes al final
[P2,abs2]=reordenar_1_2(P2,abs2, cont,n,1);
%ya se puede calcular el SinkRank de los absorbentes actuales
sr=SinkRank_individual(P2,cont);
unos=find(abs2(:,1)==1);
for i=1:length(unos)
    abs2(unos(i),3)=sr;
end
%a los v?rtices desconectados se les pondr? un SinkRank infinito
dos=find(abs2(:,1)==2);
for i=1:length(dos)
    abs2(dos(i),3)=inf;
end
clear dos unos
%Para calcular el SinkRank de los nodos que no son absorbentes se asume que
%s? lo son, poni?ndolos al final de la matriz P2 y calcul?ndolo nuevamente
for i=1:cont
    P3=reordenar_0(P2,i,cont);
    sr=SinkRank_individual(P3,cont-1);
    clear P3
    abs2(i,3)=sr;
end
SR=abs2(:,3);%la tercer columna tiene los SinkRanks de cada v?rtice
end