function ri = tf_ellip_sub(lambda, tanpsi, cosdel, theta, rien, name)
%function ri = tf_ellip_sub(lambda, tanpsi, cosdel, theta, rien, name)
%
% tf_ellip_sub: calculates the complex refractive index
%               of a material from spectroscopic ellipsometry
%               measurements at a single interface between 
%               a substrate and an entry medium.
%
% Input:
% lambda :  vector with wavelengths in micrometer
% tanpsi :  tan(Psi(lambda))
% cosdel :  cos(Delta(lambda))
% theta :   angle of incidence in degrees
% rien :    (Optional) refractive index structure (see output argument 
%           ri) with the refractive index of the entry medium. 
%           Can be a constant. Default is standard air. 
% name :    (Optional) string with an identifier for the refractive
%           index. Default is 'Substrate'.
%
% Output:
% ri :      a structure with refractive index data as a 
%           function of wavelength in micrometer
%              ri.nk :     complex refractive index
%              ri.lambda : wavelengths in micrometer
%              ri.name :   identifier

% Ulf Griesmann, December 2014

    % check arguments
    if nargin < 6, name = []; end
    if nargin < 5, rien = []; end
    if nargin < 4
        error('tf_ellip_sub: at least 4 arguments are required.');
    end
    if isempty(name), name = 'Substrate'; end
    if isempty(rien), rien = @n_air; end
    
    tanpsi = tanpsi(:); % make column vectors
    cosdel = cosdel(:);
    lambda = lambda(:);
    
    % evaluate entrance index at lambda
    nk = tf_nk(rien, lambda);
    epse = nk_to_eps(nk);
    
    % calculate rho from ellipsometry data
    rho = tanpsi .* exp(i * unwrap(acos(cosdel)));
    
    % calculate dielectric function eps
    rr = ((1 - rho) ./ (1 + rho)).^2;
    epss = epse .* sind(theta)^2 .* (1 + tand(theta)^2 * rr);
    
    % convert to refractive index
    nk = eps_to_nk(epss);
    
    % return results
    ri.nk = nk;
    ri.lambda = lambda;
    ri.name = name;
    
end
    