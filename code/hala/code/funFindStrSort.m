%cellofstr always vertical cell
function [n] = funFindStrSort(cellofstr,listofstr)

sl = size(listofstr);
sc = size(cellofstr);

output = zeros(sl(1,1),2);

[sortlist,pos_l] = sort(listofstr);
[sortcell,pos_c] = sort(cellofstr);

output(:,1)=pos_l;

[v d] = version;

j = 1;
for i = 1:sc(1,1)
    if strcmp(v(end-5:end-2),'2014')
        [ism,maxpos]=ismember(sortcell(i,1),sortlist,'legacy');
    else
        [ism,maxpos]=ismember(sortcell(i,1),sortlist);
    end
    output(j:maxpos,2)=pos_c(i,1);
    if maxpos>0
        j = maxpos+1;
    end;
end;

[sorted,pos_type] = sort(output(:,1));

n = output(pos_type,2);
