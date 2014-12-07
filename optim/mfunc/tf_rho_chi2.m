function chi2 = tf_rho_chi2(x,d,nk,theta,lambda,tanpsi,didx)
%function chi2 = tf_rho_chi2(x,d,nk,theta,lambda,tanpsi,didx)
%
% Merit function for calculation of film thicknesses from
% ellipsometric data when the optical constants of all 
% materials are known.
%
% x :      vector with film thicknesses that are varied
% d :      vector of all film thicknesses
% nk :     matrix of refractive indices for layers, one
%          column per ellipsometric measurement wavelength.
% theta :  measurement angle of incidence in degrees
% lambda : vector of ellipsometric measurement wavelengths
% tanpsi : ellipsometric measurements of tan(Psi)
% didx :   indices of film thicknesses for optimization
% chi2 :   sum of squares of differences between tan(Phi)
%          measurements and the calculated |rho|.

% Initial version, Ulf Griesmann, December 2014

    % check arguments
    if nargin < 7
        error('tf_rho_chi2: 7 input arguments required.');
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
    
    % compare with measurement
    chi2 = sum((rho - tanpsi).^2);

end

