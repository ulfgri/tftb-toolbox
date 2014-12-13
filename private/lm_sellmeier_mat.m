function rin = lm_sellmeier_mat(p, lambda)
%
% used to fit a Sellmeier model with MATLAB lsqnonlin
%
   nt = length(p)/2; % number of Sellmeier terms
   par.A = p(1:nt);
   par.B = p(nt+1:2*nt);
   rin = n_sellmeier(lambda, par);

end

