function rin = lm_cauchy_oct(lambda, p)
%
% used to fit a Cauchy model with Octave leasqr
%
   par.A = p(1);
   par.B = p(2:end);
   rin = n_cauchy(lambda, par);

end
