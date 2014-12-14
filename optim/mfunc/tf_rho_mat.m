function rho = tf_rho_mat(x,lambda,d,nk,theta,didx)
%function rho = tf_rho_mat(x,lambda,d,nk,theta,didx)
%
% Merit function for calculation of film thicknesses from
% ellipsometric data when the optical constants of all 
% materials are known. MATLAB version.
% 
%
% x :      vector with film thicknesses that are varied
% lambda : vector of ellipsometric measurement wavelengths
% d :      vector of all film thicknesses
% nk :     matrix of refractive indices for layers, one
%          column per ellipsometric measurement wavelength.
% theta :  measurement angle of incidence in degrees
% didx :   indices of film thicknesses for optimization
% rho :    tan(Phi) == |rho| for the varied thicknesses x.

% Initial version, Ulf Griesmann, December 2014

    % check arguments
    if nargin < 6
        error('tf_rho_mat: 6 input arguments required.');
    end

    % calculate rho for each wavelength
    rho = zeros(size(lambda));
    d(didx) = x;  % update thicknesses
 
    for l = 1:length(lambda)
      
        % thickness in wavelength units
        dl = d / lambda(l);
      
        % calculate rho = tan(Psi)
        rho(l) = abs(-tf_ampl(dl, nk(:,l), theta, 'p') / ...
                      tf_ampl(dl, nk(:,l), theta, 's'));
    end
end

