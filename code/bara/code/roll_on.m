% function to roll on constraint matrices
function output=roll_on(input)

szmat=size(input);
aux=0;

for i=1:szmat(1)
        aux=horzcat(aux,input(i,1:szmat(2)));
end

output=aux(2:end);