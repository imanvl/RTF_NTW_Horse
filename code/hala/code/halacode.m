function M_hala = halacode(Assets, Liabilities, Density, Ensemble)

CONSTPROB = 1/length(Assets);

Assets = Assets';

sA = size(Assets);

btype = cell(sA(1,1),1);
bcntr = cell(sA(1,1),1);
for ii = 1:sA(1,1)
    btype{ii,1} = ['b' num2str(ii)];
    bcntr{ii,1} = ['p' num2str(ii)];
end;

map = CONSTPROB*ones(sA(1,1),sA(1,1));
maprow = btype;
mapcol = bcntr;


[~,~,~,~,M_hala,~,~,~,~,~] = funIBankRandomGenRiskLim(-Assets,Liabilities,btype,bcntr,map,maprow,mapcol,1000.0,1000.0); %,E);

M_hala = full(M_hala);

display(['Percentage of exposures allocated ' num2str(100 * sum(sum(M_hala,2))/sum(Assets))]);
