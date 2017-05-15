function M_bara= baracode(Assets, Liabilities, Density, Ensemble)
u = Assets;
v = Liabilities';
M_bara=hybrid_fct3(1,u,v);
