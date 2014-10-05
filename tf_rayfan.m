function [R, T, A] = tf_rayfan(stack, lambda, theta, pol)
%function [R, T, A] = tf_rayfan(stack, lambda, theta, pol)
%
% tf_rayfan :  calculates the response of a multilayer stack 
%              for a range of angles of incidence.
%
% Input:
% stack :   a structure array with a material stack definition
%              stack(k).d :  layer thickness in um
%              stack(k).n :  refractive index, function handle, or
%                            directly specified constant index
% lambda :  a vector with wavelengths
% theta :   a vector with angles of incidence on the first layer 
%           interface in degrees.
% pol :     polarization; either 's', 'p', or 'u'. 
%           Default is 'u' - unpolarized.
%
% Output:
% R :       length(theta) x length(lambda) matrix with reflectance 
%           at input angles and wavelengths
% T :       length(theta) x length(lambda) matrix with transmittance 
%           at input angles and wavelengths
% A :       length(theta) x length(lambda) matrix with absorbance 
%           at input angles and wavelengths

% Initial version, Ulf Griesmann, February 2013

% check input
if nargin < 4, pol = 'u'; end
if nargin < 3
   error('tf_rayfan :  three input arguments required.');
end

% pre-allocate output arrays
R = zeros(length(theta),length(lambda));
T = zeros(length(theta),length(lambda));
A = zeros(length(theta),length(lambda));

% calculate optical constants at wavelengths
nk = evalnk(stack, lambda); 

% compute all thicknesses in units of lambda
d = [stack.d];
if isrow(d), d = d'; end
d = bsxfun(@rdivide, d, lambda);

% calculate intensities
for t = 1:length(theta)
   for l = 1:length(lambda)
      [R(t,l), T(t,l)] = tf_int(d(:,l), nk(:,l), theta(t), pol);
   end
end

A = 1 - R - T;
         
return
