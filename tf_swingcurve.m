function [R, T, A] = tf_swingcurve(stack, lambda, theta, nv, dv, pol)
%function [R, T, A] = tf_swingcurve(stack, lambda, theta, nv, dv, pol)
%
% tf_swingcurve :  calculates the response of a multilayer stack 
%                  as a function of the thickness of a specified layer.
%
% Input:
% stack :   a structure array with a material stack definition
%              stack(k).d :  layer thickness in um
%              stack(k).n :  refractive index table, function
%                            handle, or constant direct specified
%                            index
% lambda :  vector with wavelengths
% theta :   the angle of incidence on the first layer interface in degrees.
% nv :      number of the layer in the stack with variable thickness
% dv :      a vector with thickness values in um
% pol :     polarization; either 's', 'p', or 'u'. 
%           Default is 'u' - unpolarized.
%
% Output:
% R :       length(dv) x length(lambda) matrix with reflectance 
%           at input angles and wavelengths
% T :       length(dv) x length(lambda) matrix with transmittance 
%           at input angles and wavelengths
% A :       length(dv) x length(lambda) matrix with absorbance 
%           at input angles and wavelengths

% Initial version, Ulf Griesmann, February 2013

% check input
if nargin < 6, pol = 'u'; end
if nargin < 5
   error('tf_swingcurve :  five input arguments required.');
end
if ~isscalar(theta)
   error('tf_swingcurve: argument ''theta'' must be scalar.');
end

% pre-allocate output arrays
R = zeros(length(dv),length(lambda));
T = zeros(length(dv),length(lambda));
A = zeros(length(dv),length(lambda));

% calculate optical constants at wavelength of interest
nk = evalnk(stack, lambda); 

% compute all thicknesses in units of lambda
d = [stack.d];
if isrow(d), d = d'; end
d = bsxfun(@rdivide, d, lambda);

% loop over thicknesses
for k = 1:length(dv)
  
    % vary thickness of layer nv
    d(nv,:) = dv(k) ./ lambda;
  
    % calculate intensities
    for l = 1:length(lambda)
       [R(k,l), T(k,l)] = tf_int(d(:,l), nk(:,l), theta, pol);
    end
end

A = 1 - R - T;

return

