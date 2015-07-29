function [R,T] = tf_int_sub(df, nkf, db, nkb, theta, pol)
%function [R,T] = tf_int_sub(df, nkf, db, nkb, theta, pol)
%
% tf_int_sub : calculates reflectances and transmittances from
%              amplitudes for multilayers that are deposited on the
%              front and back of a substrate.
%
% Input:
% df :     front layer thicknesses in units of wavelength
% nkf :    front layer indices
% db :     back layer thicknesses in units of wavelength
% nkb :    back layer indices
% theta :  angle of incidence on first interface in degrees
% pol :    polarization state, either 's', 'p', or 
%          'u' (unpolarized)
%
% Output:
% R : reflectance
% T : transmittance
%
% Reference:
% + S. Larouche and L. Martinu, "OpenFilters: open-source software 
%   for the design, optimization, and synthesis of optical
%   filters", Appl. Opt. 47(13), C219-C230 (2008)

% Initial version, Ulf Griesmann, January 2014

    % check arguments
    if nargin ~= 6
       error('tf_int_sub :  6 input arguments required.');
    end

    % check substrate thickness & index
    if df(end) ~= db(1)
       error('tf_int_sub: df(exit) ~= db(entry).');
    else
       ds = df(end);   % substrate thickness
    end
    if nkf(end) ~= nkb(1)
       error('tf_int_sub: nkf(exit) ~= nkb(entry).');
    else
       nks = nkf(end); % substrate index
    end

    % angle in substrate material == AOI on back layers
    alpha = nkf(1) * sin(pi*theta/180);       % Snell invariant
    thetab = 180 * asin(alpha / nkb(1)) / pi; % degrees

    % geometric factor
    beta = imag(2*pi * ds * sqrt(nks^2 - alpha^2));

    % forward & backward reflectances and transmittances
    [Rf,Tf] = tf_int(df,nkf,theta, pol);
    [Rb,Tb] = tf_int(db,nkb,thetab,pol);

    % reverse reflectance and transmittance
    dfr  = df(end:-1:1);
    nkfr = nkf(end:-1:1);
    [Rfr,Tfr] = tf_int(dfr,nkfr,thetab,pol);

    % calculate overall reflectance and transmittance
    D = 1 - Rfr*Rb*exp(4*beta);
    R = Rf + Tf*Tfr*Rb*exp(4*beta) / D;
    T = Tf*Tb*exp(2*beta) / D;

end
