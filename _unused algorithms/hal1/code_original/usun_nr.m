function nowe_numery = usun_nr(numery,nr)

nr_pom = find(numery~=nr);
nowe_numery = numery(nr_pom,1);