function nk = eps_to_nk(eps12)
%function nk = eps_to_nk(eps12)
%
% eps_to_nk: convert the dielectric function eps = eps1 + i*eps2
%            into the refractive index n - i*k
%
% Input:
% eps12 : dielectric functions
%
% Output:
% nk :    complex refractive index n - i*k

% Ulf Griesmann, December 2014

    nk = complex(  sqrt(0.5*(abs(eps12) + real(eps12))), ...
                  -sqrt(0.5*(abs(eps12) - real(eps12))) );

end
