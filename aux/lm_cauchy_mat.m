function rin = lm_cauchy_mat(p, lambda)
%
% used to fit a Cauchy model with MATLAB lsqnonlin
%
   par.A = p(1);
   par.B = p(2:end);
   rin = n_cauchy(lambda, par);

end
