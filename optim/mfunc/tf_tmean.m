function Tmean = tf_tmean(d,nk,lambda,theta,pol,mfpar)
%function Tmean = tf_tmean(d,nk,lambda,theta,pol,mfpar)
%
% Returns the mean transmittance at the specified wavelengths 
% and angles of incidence for optimization.
%
% d :      vector of all film thicknesses in um
% nk :     vector of complex refractive indices of layers,
%          one column per wavelength.
% lambda : vector of wavelengths at which to optimize
% theta :  angle of incidence in degrees
% pol :    polarization, 'r', 's', or 'u'
% didx :   indices of film thicknesses for optimization
% mfpar :  not needed for this function
% Tmean :  average transmittance at wavelengths lambda

% Initial version, Ulf Griesmann, December 2013

% check input
if nargin < 5
   error('tf_tmean :  5 input arguments required.');
end
if iscolumn(lambda), lambda = lambda'; end

% pre-allocate
T = zeros(length(theta), length(lambda));

% calculate layer thicknesses in lambda units and reflectance
for t = 1:length(theta)
   for k = 1:length(lambda)
      dl = d ./ lambda(k);
      [~,T(t,k)] = tf_int(dl, nk(:,k), theta(t), pol);
   end
end

% average reflectance
Tmean = mean( mean(T) );

return
