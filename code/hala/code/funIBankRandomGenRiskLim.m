% ad varargin - 1: cap (capital)

function [pi_nowe,p_nowe,luka_uj_nowa,luka_dod_nowa,p_big_nowe,nrs_uj,nrs_dod,prz,ijk,MAXNRS] = funIBankRandomGenRiskLim(luka_ujemna,luka_dodatnia,btype,bcntr,map,maprow,mapcol,large_exp_indiv,large_exp_aggr) %,varargin)

%domino_globals;

% narg = length(varargin);
% 
nb = size(luka_ujemna);
% 
% if narg == 1
%     cap = varargin{1};
% else
cap = -4*min(luka_ujemna)*ones(nb(1,1),1); % no Large Exposure constraint implying technical assumption that capital=very large number
% end;

CONST_RANDOM_MATCHING = 100000; %Random parts of negative gaps is matched CONST_RANDOM_MATCHING times

CONST_MIN_IBANK_EXPOSURE = 0.01;
CONST_MAX_IBANK_EXPOSURE = 1.0;

CONST_RAW_BANKS = 1000000;

%domino_globals;

Rozmiar = nb(1,1);

nr_luka_uj = find(luka_ujemna<0);
nr_luka_dod = find(luka_dodatnia>0);

pi_nowe = sparse(zeros(Rozmiar));
p_big_nowe = sparse(zeros(Rozmiar));
luka_uj_nowa = sparse(luka_ujemna);
luka_dod_nowa = sparse(luka_dodatnia);

nrs_uj = [];
nrs_dod = [];

prz = [];

%Random parts of negative gaps is matched CONST_RANDOM_MATCHING times...

rand_mat = min(max(rand(CONST_RANDOM_MATCHING,1),CONST_MIN_IBANK_EXPOSURE),CONST_MAX_IBANK_EXPOSURE);

nr_raw = [draw_nr_v(nr_luka_uj,CONST_RAW_BANKS) draw_nr_v(nr_luka_dod,CONST_RAW_BANKS)]; 
type_bank = [bcntr(nr_raw(:,1),1) btype(nr_raw(:,2),1)];
row = funFindStrSort(maprow,type_bank(:,2)); %!!! the flow is asumed to go from 1 col of nr_raw to the second col of nr_raw, but the prob is not on flows but on placements (reverse direction)
col = funFindStrSort(mapcol',type_bank(:,1));

idx = sub2ind(size(map),max(1,row),max(1,col)); 

nrs = [nr_raw map(idx)];

prob_edge = rand(CONST_RAW_BANKS,1);

kept_edges = find(prob_edge<nrs(:,3));

nrs = nrs(kept_edges,1:2);
snrs = size(nrs);

MAXNRS = snrs(1,1);

ijk = 1;
ifsaturated = 0;
while (ifsaturated==0&ijk<CONST_RANDOM_MATCHING&ijk<MAXNRS)
    nr_uj = nrs(ijk,1);
    nr_dod = nrs(ijk,2);
    
    if nr_uj~=nr_dod
        
        ibflow = min(-rand_mat(ijk,1)*luka_uj_nowa(nr_uj,1),luka_dod_nowa(nr_dod,1));
        flows_aux = p_big_nowe(:,nr_dod);
        flows_aux(nr_uj,1) = flows_aux(nr_uj,1) + ibflow;
        above10prcExp = sum(flows_aux(find(flows_aux>0.1*cap(nr_dod,1)),1));
        
        if p_big_nowe(nr_uj,nr_dod) + ibflow <= large_exp_indiv*cap(nr_dod,1) & above10prcExp<=large_exp_aggr*cap(nr_dod,1)  %http://www.capital-requirements-directive.com/Title5_Chapter2_Section5.htm
            p_big_nowe(nr_uj,nr_dod) = p_big_nowe(nr_uj,nr_dod) + ibflow;
            luka_uj_curr = luka_uj_nowa(nr_uj,1)+ibflow;
            luka_dod_curr = luka_dod_nowa(nr_dod,1)-ibflow;
            
            prz = [prz;ibflow];
            
            luka_uj_nowa(nr_uj,1) = luka_uj_curr;
            luka_dod_nowa(nr_dod,1) = luka_dod_curr;
            
            if isempty(nr_luka_dod)|isempty(nr_luka_uj)
                ifsaturated = 1;
            end;
            
            nrs_uj = [nrs_uj;nr_uj];
            nrs_dod = [nrs_dod;nr_dod];
            
        end;
        
    end;
    
    ijk = ijk + 1;
    
end

p_nowe = sparse(p_big_nowe*ones(Rozmiar,1));
p_nowe_aux = p_nowe;
for ii = 1:Rozmiar
    if p_nowe_aux(ii,1)==0
        p_nowe_aux(ii,1)=1; %to avoid dividing by 0!
    end;
end;
            
pi_nowe = p_big_nowe./repmat(p_nowe_aux,[1 Rozmiar]);
   