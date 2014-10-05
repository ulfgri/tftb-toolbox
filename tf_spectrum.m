function [R, T, A] = tf_spectrum(stack, lambda, theta, pol)
%function [R, T, A] = tf_spectrum(stack, lambda, theta, pol)
%
% tf_spectrum :  calculates the response of a multilayer stack 
%                at the specified wavelengths.
%
% Input:
% stack :   a structure array with a material stack definition
%              stack(k).d :  layer thickness in um
%              stack(k).n :  refractive index table, function
%                            handle, or directly specified constant
%                            index
% lambda :  Sampling wavelengths
% theta :   the angle of incidence on the first layer interface in degrees.
% pol :     polarization; either 's', 'p', or 'u'. Default is 'u' - unpolarized.
%
% Output:
% R :       A ROW vector with reflectance at input wavelengths
% T :       A ROW vector transmittance at input wavelengths
% A :       A ROW vector absorbance at input wavelengths
%

% Initial version, Ulf Griesmann, February 2013

% check input
if nargin < 4, pol = 'u'; end
if nargin < 3
   error('tf_spectrum :  three input arguments required.');
end
if iscolumn(lambda), lambda = lambda'; end

% pre-allocate arrays
R = zeros(size(lambda));
T = zeros(size(lambda));
A = zeros(size(lambda));

% compute all thicknesses in units of lambda
d = [stack.d];
if isrow(d), d = d'; end
d = bsxfun(@rdivide, d, lambda);

% compute all indices
nk = evalnk(stack, lambda); 

% calculate intensities for lambda(l)
for l = 1:length(lambda)
    [R(l), T(l)] = tf_int(d(:,l), nk(:,l), theta, pol);
end

A = 1 - R - T;

return
