% ad varargin - 1: cap (capital)

function [X_rel,l_sim,X] = funIBankRandomGenV3(tl,ta,btype,bcntr,map,maprow,mapcol,varargin)

domino_globals;

narg = length(varargin);

nb = size(tl);

if narg == 1
    cap = varargin{1};
else
    cap = -4*min(tl)*ones(nb(1,1),1); % no Large Exposure constraint implying technical assumption that capital=very large number
end;

CONST_RANDOM_MATCHING = 5000; %Random parts of negative gaps is matched CONST_RANDOM_MATCHING times

CONST_MIN_IBANK_EXPOSURE = 0.02;
CONST_MAX_IBANK_EXPOSURE = 0.1;

CONST_RAW_BANKS = 25000;

domino_globals;

nr_gap_neg = find(tl<0);
nr_gap_pos = find(ta>0);

X_rel = sparse(zeros(Rozmiar));
X = sparse(zeros(Rozmiar));
gap_neg_nowa = sparse(tl);
gap_pos_nowa = sparse(ta);

nrs_uj = [];
nrs_dod = [];

prz = [];

%Random parts of negative gaps is matched CONST_RANDOM_MATCHING times...

rand_mat = min(max(rand(CONST_RANDOM_MATCHING,1),CONST_MIN_IBANK_EXPOSURE),CONST_MAX_IBANK_EXPOSURE);

nr_raw = [draw_nr_v(nr_gap_neg,CONST_RAW_BANKS) draw_nr_v(nr_gap_pos,CONST_RAW_BANKS)]; 
type_bank = [bcntr(nr_raw(:,1),1) btype(nr_raw(:,2),1)];
row = funFindStrSort(maprow,type_bank(:,2)); %!!! the flow is asumed to go from 1 col of nr_raw to the second col of nr_raw, but the prob is not on flows but on placements (reverse direction)
col = funFindStrSort(mapcol',type_bank(:,1));

idx = sub2ind(size(map),row,col); 

nrs = [nr_raw map(idx)];

prob_edge = rand(CONST_RAW_BANKS,1);

kept_edges = find(prob_edge<nrs(:,3));

nrs = nrs(kept_edges,1:2);
snrs = size(nrs);

MAXNRS = snrs(1,1);

ijk = 1;
ifsaturated = 0;
while (ifsaturated==0&ijk<CONST_RANDOM_MATCHING&ijk<MAXNRS)
    nr_neg = nrs(ijk,1);
    nr_pos = nrs(ijk,2);
    
    if nr_neg~=nr_pos
        
        ibflow = min(-rand_mat(ijk,1)*gap_neg_nowa(nr_neg,1),gap_pos_nowa(nr_pos,1));
        flows_aux = X(:,nr_pos);
        flows_aux(nr_neg,1) = flows_aux(nr_neg,1) + ibflow;
        above10prcExp = sum(flows_aux(find(flows_aux>0.1*cap),1));
        
        if X(nr_neg,nr_pos) + ibflow <= 0.25*cap(nr_neg,1) & above10prcExp<=8*cap(nr_neg,1)  %http://www.capital-requirements-directive.com/Title5_Chapter2_Section5.htm
            X(nr_neg,nr_pos) = X(nr_neg,nr_pos) + ibflow;
            gap_neg_curr = gap_neg_nowa(nr_neg,1)+ibflow;
            gap_pos_curr = gap_pos_nowa(nr_pos,1)-ibflow;
            
            prz = [prz;ibflow];
            
            gap_neg_nowa(nr_neg,1) = gap_neg_curr;
            gap_pos_nowa(nr_pos,1) = gap_pos_curr;
            
            if isempty(nr_gap_pos)|isempty(nr_gap_neg)
                ifsaturated = 1;
            end;
            
            nrs_uj = [nrs_uj;nr_neg];
            nrs_dod = [nrs_dod;nr_pos];
            
        end;
        
    end;
    
    ijk = ijk + 1;
    
end

l_sim = sparse(X*ones(Rozmiar,1));
l_sim_aux = l_sim;
for ii = 1:Rozmiar
    if l_sim_aux(ii,1)==0
        l_sim_aux(ii,1)=1; %to avoid dividing by 0!
    end;
end;
            
X_rel = X./repmat(l_sim_aux,[1 Rozmiar]);
   