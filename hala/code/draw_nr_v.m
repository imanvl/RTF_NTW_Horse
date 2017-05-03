function nr = draw_nr_v(numery,sv)

[sn1,sn2] = size(numery);

if (sn1==0)
    nr = 0;
else
    nr_pom = min(floor(sn1*rand(sv,1))+1,sn1);
    nr = numery(nr_pom,1);
end;