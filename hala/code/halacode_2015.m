function [M_hala,neg_gap,pos_gap,jj,mm] = halacode(Assets, Liabilities, Density, Ensemble)

CONSTPROB = 1/length(Assets);

Assets = Assets';

sA = size(Assets);

btype = cell(sA(1,1),1);
bcntr = cell(sA(1,1),1);
for ii = 1:sA(1,1)
    btype{ii,1} = ['b' num2str(ii)];
    bcntr{ii,1} = 'p';
end;

map = CONSTPROB*ones(sA(1,1),1);
maprow = btype;
mapcol = {'p'};

[pi_new,p_new,neg_gap,pos_gap,M_hala,nrs_neg,nrs_pos,xx,jj,mm] = funIBankRandomGenRiskLim(-Liabilities,Assets,btype,bcntr,map,maprow,mapcol,1000.0,1000.0); %,E);

M_hala = full(M_hala);

diff_a = sum(sum(M_hala,2)-Assets);
diff_l = sum(sum(M_hala)-Liabilities');
display(['Difference between asset and liability marginals are ' num2str(diff_a) ' and ' num2str(diff_l) ' respectively']);