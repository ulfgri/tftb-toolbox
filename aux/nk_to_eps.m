function epsilon = nk_to_eps(nk)
%function epsilon = nk_to_eps(nk)
%
% nk_to_eps: convert the complex refractive index into dielectric
%            function epsilon = epsilon1 + i*epsilon2
%
% Input:
% nk :    complex refractive index n - i*k
%
% Output:
% epsilon : dielectric function(s)

% Ulf Griesmann, December 2014

    epsilon = conj( nk.^2 ); % Note: we define k > 0

end
