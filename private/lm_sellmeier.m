function rin = lm_sellmeier(p, lambda, nt)
%
% used to fit a Sellmeier model with levmar
%
par.A = p(1:nt);
par.B = p(nt+1:2*nt);
rin = n_sellmeier(lambda, par);

return

