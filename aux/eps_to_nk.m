function nk = eps_to_nk(epsilon)
%function nk = eps_to_nk(epsilon)
%
% eps_to_nk: convert the dielectric function 
%            epsilon = epsilon1 + i*epsilon2
%            into the refractive index n - i*k
%
% Input:
% epsilon : dielectric function(s)
%
% Output:
% nk :    complex refractive index n - i*k

% Ulf Griesmann, December 2014

    nk = complex(  sqrt(0.5*(abs(epsilon) + real(epsilon))), ...
                  -sqrt(0.5*(abs(epsilon) - real(epsilon))) );

end
