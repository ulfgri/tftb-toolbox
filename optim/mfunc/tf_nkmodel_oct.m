function absrho = tf_nkmodel_oct(lambda,x,d,nk,theta,midx,nc,didx)
%function absrho = tf_nkmodel_oct(lambda,x,d,nk,theta,midx,nc,didx)
%
% Merit function for calculation of Chebychev polynomial model
% parameters from ellipsometric data. Octave version.
%
% lambda : vector of ellipsometric measurement wavelengths
% x :      vector with parameters (film thicknesses and 
%          Chebychev polynomial coefficients) to be varied.
% d :      vector of all film thicknesses
% nk :     matrix of refractive indices for layers, one
%          column per ellipsometric measurement wavelength.
% theta :  measurement angle of incidence in degrees
% midx :   index of layer that is modeled with a Chebychev polynomial
% nc :     number of Chebychev polynomial model coefficients
% didx :   indices of film thicknesses for optimization
% absrho : tan(Phi) == |rho| for the varied parameters

% Initial version, Ulf Griesmann, December 2014

    % check arguments
    if nargin < 8
        error('tf_nkmodel_oct: 8 input arguments required.');
    end

    % calculate rho at  each wavelength
    absrho = zeros(size(lambda));
    
    % update thickness(es)
    nd = 0;
    if didx
        nd = length(didx);
        d(didx) = x(1:nd);
    end
    
    % calculate refractive index of modeled layer from coefficients
    ldom = [lambda(1),lambda(end)];
    nk(midx,:) = complex( chebychev_eval(lambda, x(1+nd:nd+nc),  ldom), ...
                         -chebychev_eval(lambda, x(nd+nc+1:end), ldom) );
 
    for l = 1:length(lambda)
      
        % thickness in wavelength units
        dl = d / lambda(l);
      
        % calculate rho = tan(Psi)
        absrho(l) = abs(-tf_ampl(dl, nk(:,l), theta, 'p') / ...
                         tf_ampl(dl, nk(:,l), theta, 's'));
    end
end

