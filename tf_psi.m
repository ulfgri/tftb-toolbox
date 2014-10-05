function [Psi,Delta] = tf_psi(d, nk, theta)
%function [Psi,Delta] = tf_psi(d, nk, theta)
%
% tf_psi :  calculates the ellipsometric functions
%           Psi and Delta for a thin film stack.
%
% Input:
% d :      layer thicknesses in units of wavelength
% nk :     layer refractive indices
% theta :  angle of incidence on first interface
%
% Output:
% Psi :   atan(Amplitude) in RADIANS
% Delta : Phase angle in RADIANS

% Initial version, Ulf Griesmann, February 2013

% check arguments
if nargin ~= 3
   error('tf_psi :  3 input arguments required.');
end

% calculate Psi, Delta
rho = -tf_ampl(d, nk, theta, 'p') / tf_ampl(d, nk, theta, 's');
Psi = atan(abs(rho));
Delta = angle(rho);

return

