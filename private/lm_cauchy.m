function rin = lm_cauchy(p, lambda)
%
% used to fit a Cauchy model with levmar
%
par.A = p(1);
par.B = p(2:end);
rin = n_cauchy(lambda, par);

return
