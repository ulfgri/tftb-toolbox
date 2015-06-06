function [R, T, A] = tf_spectrum_sub(fstack, bstack, lambda, theta, pol)
%function [R, T, A] = tf_spectrum_sub(fstack, bstack, lambda, theta, pol)
%
% tf_spectrum_sub :  calculates the response of a multilayer stack 
%                    at the specified wavelengths including
%                    incoherent substrate effects.
%
% Input:
% fstack :  a structure array with a material stack definition for
%           the stack on the front of the substrate
%              fstack(k).d :  layer thickness in um
%              fstack(k).n :  refractive index table, function
%                             handle, or directly specified constant
%                             index
%           fstack(end).d is the substrate thickness (> coherence length)
% bstack :  a structure array that defines the material stack on
%           the back of the substrate. 
%           bstack(1).d is the substrate thickness, must be same as
%           fstack(end).
% lambda :  Sampling wavelengths
% theta :   the angle of incidence on the first layer interface in degrees.
% pol :     polarization; either 's', 'p', or 'u'. Default is 'u' - unpolarized.
%
% Output:
% R :       A ROW vector with reflected intensity at input wavelengths
% T :       A ROW vector transmitted intensity at input wavelengths
% A :       A ROW vector absorbed intensity at input wavelengths
%
% Reference:
% + S. Larouche and L. Martinu, "OpenFilters: open-source software 
%   for the design, optimization, and synthesis of optical
%   filters", Appl. Opt. 47(13), C219-C230 (2008)

% Initial version, Ulf Griesmann, January 2014

    % check input
    if nargin < 5, pol = 'u'; end
    if nargin < 4
       error('tf_spectrum_sub :  4 input arguments required.');
    end
    if iscolumn(lambda), lambda = lambda'; end

    % pre-allocate arrays
    R = zeros(size(lambda));
    T = zeros(size(lambda));
    A = zeros(size(lambda));

    % compute front thicknesses in units of lambda
    df = [fstack.d];
    if isrow(df), df = df'; end
    df = bsxfun(@rdivide, df, lambda);

    % compute front indices
    nkf = evalnk(fstack, lambda); 

    % compute back thicknesses in units of lambda
    db = [bstack.d];
    if isrow(db), db = db'; end
    db = bsxfun(@rdivide, db, lambda);

    % compute all back indices
    nkb = evalnk(bstack, lambda); 

    % calculate reflectance/transmittance for lambda(l)
    for l = 1:length(lambda)
       [R(l), T(l)] = tf_int_sub(df(:,l),nkf(:,l),db(:,l),nkb(:,l),theta, pol);
    end

    A = 1 - R - T;

end
