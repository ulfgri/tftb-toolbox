function alpha = k_to_alpha(ri)
%function alpha = k_to_alpha(k)
%
% k_to_alpha: convert an extinction coefficient into an 
%             attenuation coefficient:
%             
%                      4*pi
%             alpha = ------ * k
%                     lambda
%
% and
%
%             I(z) = I0 * exp(-alpha*z)
%
% Input:
% ri :     a refractive index structure
%             ri.lambda : a vector of wavelengths in micrometer
%             ri.nk :     complex refractive index of a material
%                         at the wavelengths lambda
%
% Output:
% alpha :  absorption coefficient

% Ulf Griesmann, December 2014

    if length(ri.nk) ~= length(ri.lambda)
        error('#nk must be equal to #wavelengths.');
    end
    alpha = 4*pi * imag(ri.nk) ./ lambda;

end
