function Rmerit = tf_rmin2(x,d,nk,lambda,theta,pol,didx,mfpar)
%function Rmerit = tf_rmin2(x,d,nk,lambda,theta,pol,didx,mfpar)
%
% Standard merit function for layer thickness optimization: 
% returns reflectance at the specified wavelengths 
% and/or angles of incidence for optimization.
%
% x :      vector with film thicknesses that are varied
% d :      vector of all film thicknesses
% nk :     matrix of refractive indices for layers, one
%          column per wavelength.
% lambda : vector of wavelengths at which to optimize
% theta :  vector of angles of incidence in degrees
% pol :    polarization, 'r', 's', or 'u'
% didx :   indices of film thicknesses for optimization
% mfpar :  not needed for this function
% Rmerit : a vector of reflectances at wavelengths lambda or angles theta

% Initial version, Ulf Griesmann, December 2013

% check input
if nargin < 7
   error('tf_rmerit :  7 input arguments required.');
end
if iscolumn(lambda), lambda = lambda'; end

% pre-allocate
R = zeros(length(theta), length(lambda));

% calculate layer thicknesses in lambda units and reflectance
d(didx) = x;
for t = 1:length(theta)
   for k = 1:length(lambda)
      dl = d ./ lambda(k);
      R(t,k) = tf_int(dl, nk(:,k), theta(t), pol);
   end
end

% vector of reflectances
Rmerit = R(:);

return
