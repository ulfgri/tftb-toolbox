function Rmean = tf_rmin(x,d,nk,lambda,theta,pol,didx,mfpar,obj)
%function Rmean = tf_rmin(x,d,nk,lambda,theta,pol,didx,mfpar,obj)
%
% Standard merit function for layer thickness optimization: 
% returns the mean reflectance at the specified wavelengths 
% and angles of incidence for optimization.
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
% obj :    objective (target value) for the merit function
% Rmean :  average reflectance at wavelengths lambda

% Initial version, Ulf Griesmann, October 2013

% check input
if nargin < 9, obj = []; end
if nargin < 7
   error('tf_rmin :  7 input arguments required.');
end
if isempty(obj), obj = 0; end
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

% average reflectance
Rmean = mean( abs( mean(R) - obj) );

return
