function [M] = tf_charmat(d, nk, theta, pol);
%function [M] = tf_charmat(d, nk, theta, pol);
%
% tf_charmat : calculate the characteristic matrices for a 
%              stack of thin films.
%
% Input:
% d :        vector with layer thicknesses in units of wavelength
% nk :       vector with refractive indices for each layer
%
% theta  :   (Optional) angle of incidence at first interface in
%            degrees. Default is 0.
% pol :      polarization state; either 's' or 'p'.
%
% Output:
% M :        a 2 x 2 x q  array for a stack of q = length(nk)-2 
%            material layers. M(:,:,1) is the entrance layer.
%
% Reference:
%   S. Larouche and L. Martinu, "OpenFilters: open-source software 
%   for the design, optimization, and synthesis of optical
%   filters", Appl. Opt. 47(13), C219-C230 (2008)

% Initial version, Ulf Griesmann, October 2013

    % check arguments
    if nargin ~= 4
       error('tf_charmat :  must have 4 arguments.');
    end
    if length(d) ~= length(nk)
       error('tf_charmat :  number of thicknesses ~= number of indices.');
    end
    if isrow(d), d = d'; end
    if isempty(theta), theta = 0; end

    % Snell invariant
    alpha2 = (nk(1) * sin(pi*theta/180))^2;
    
    % check if there is only one interface (no layers)
    if length(d) == 2
       M = eye(2);
       return
    end

    % pseudo-index eta and phase phi shift for each layer
    N = nk(2:end-1);                         % actual layers
    eta_s = sqrt(N.^2 - alpha2);
    if pol == 's'
       eta = eta_s;
    else
       eta = N.^2 ./ eta_s;
    end
    phi = 2*pi * d(2:end-1) .* eta_s;

    % stack of characteristic matrices for each layer
    M = complex(zeros(2,2,length(phi)));
    cosphi = cos(phi);
    sinphi = sin(phi);
    M(1,1,:) = cosphi;
    M(2,2,:) = cosphi;
    M(1,2,:) = i*sinphi./eta;
    M(2,1,:) = i*sinphi.*eta;
    
end
