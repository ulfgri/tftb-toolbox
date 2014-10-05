function Rmean = tf_rmean(d,nk,lambda,theta,pol,mfpar)
%function Rmean = tf_rmean(d,nk,lambda,theta,pol,mfpar)
%
% Returns the mean reflectance at the specified wavelengths 
% and angles of incidence for optimization.
%
% d :      vector of all film thicknesses in length units
% nk :     matrix of complex refractive indices of layers,
%          one column per wavelength.
% lambda : vector of wavelengths in the same length units
% theta :  vector of angle of incidences in degrees
% pol :    polarization, 'r', 's', or 'u'
% mfpar :  not needed for this function
% Rmean :  average reflectance at wavelengths lambda

% Initial version, Ulf Griesmann, December 2013

% check input
if nargin < 5
   error('tf_rmean :  5 input arguments required.');
end
if iscolumn(lambda), lambda = lambda'; end

% pre-allocate
R = zeros(length(theta), length(lambda));

% calculate layer thicknesses in lambda units and reflectance
for t = 1:length(theta)
   for k = 1:length(lambda)
      dl = d ./ lambda(k);
      R(t,k) = tf_int(dl, nk(:,k), theta(t), pol);
   end
end

% average reflectance
Rmean = mean( mean(R) );

return
