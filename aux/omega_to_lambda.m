function lambda = omega_to_lambda(omega)
%function lambda = omega_to_lambda(omega)
%
% omega_to_lambda: converts a vector of angular frequencies in
%                  rad/s^-1 into wavelengths in micrometer
%
% Input:
% omega :   vector with angular frequencies
%
% Output:
% lambda :  vector with wavelengths in micrometer

% Ulf Griesmann, December 2104

   lambda = 2*pi * sol() ./ omega;

end
