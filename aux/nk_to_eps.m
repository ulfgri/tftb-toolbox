function eps12 = nk_to_eps(nk)
%function eps12 = nk_to_eps(nk)
%
% nk_to_eps: convert the complex refractive index into dielectric
%            function eps = eps1 + i*eps2
%
% Input:
% nk :    complex refractive index n - i*k
%
% Output:
% eps12 : dielectric functions

% Ulf Griesmann, December 2014

    eps12 = conj( nk.^2 ); % Note: we define k > 0

end
