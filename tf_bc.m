function [B,C,eta_ex] = tf_bc(d, nk, theta, pol)
%function [B,C,eta_ex] = tf_bc(d, nk, theta, pol)
%
% tf_bc :  calculate the functions B and C for a stack 
%          of thin material layers.
%
% Input:
% d :        vector with layer thicknesses in units of wavelength
% nk :       vector with refractive indices for each layer
% theta  :   (Optional) angle of incidence at first interface in
%            degrees. Default is 0.
% pol :      polarization state; either 's' or 'p'.
%
% Output:
% B,C :      functions B, C of the thin film stack
% eta_ex :   pseudo-index of the exit medium
%
% Reference:
%   H. A. Macleod, "Thin Film Optical Filters, 2n Ed.", McGraw-Hill,
%   New York (1989), p.43

% Initial version, Ulf Griesmann, November 2013

    % check arguments
    if nargin < 4
        error('tf_bc :  must have 4 arguments.');
    end
    if length(d) ~= length(nk)
        error('tf_bc :  number of thicknesses ~= number of indices.');
    end
    if isempty(theta), theta = 0; end

    % pseudo-index for substrate material
    [~, eta_ex] = eta_sp(nk, theta, pol);

    % get characteristic matrices for layers
    M = tf_charmat(d, nk, theta, pol);

    % characteristic matrix Mq for the whole stack
    Mq = M(:,:,1);
    for k = 2:size(M,3)
        Mq = Mq * M(:,:,k);
    end

    % calculate B,C
    bc = Mq * [1;eta_ex];
    B = bc(1);
    C = bc(2);

end
