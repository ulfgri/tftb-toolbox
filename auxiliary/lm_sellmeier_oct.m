function rin = lm_sellmeier_oct(lambda, p)
%
% used to fit a Sellmeier model with Octave leasqr
%
   nt = length(p)/2; % number of Sellmeier terms
   par.A = p(1:nt);
   par.B = p(nt+1:2*nt);
   rin = n_sellmeier(lambda, par);

end

