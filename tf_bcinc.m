function [B,C] = tf_bcinc(d, nk, theta, pol)
%function [B,C] = tf_bcinc(d, nk, theta, pol)
%
% tf_bcinc :  calculate the incremental B, C of a stack 
%             of thin material layers beginning at the substrate.
%
% Input:
% d :        vector with layer thicknesses in units of wavelength
% nk :       vector with refractive indices for each layer
% theta  :   (Optional) angle of incidence at first interface in
%            degrees. Default is 0.
% pol :      polarization state; either 's' or 'p'.
%
% Output:
% B,C :      vectors with functions B and C, s- or p-polarized light
%
% Reference:
%   H. A. Macleod, "Thin Film Optical Filters, 2n Ed.", McGraw-Hill,
%   New York (1989), p.43

% Initial version, Ulf Griesmann, November 2013

    % check arguments
    if nargin < 4
        error('tf_bcinc :  must have 4 arguments.');
    end
    if length(d) ~= length(nk)
        error('tf_bcinc :  number of thicknesses ~= number of indices.');
    end
    if isempty(theta), theta = 0; end

    % pseudo-index for substrate material
    [~, eta_ex] = eta_sp(nk, theta, pol);

    % get characteristic matrices for layers
    M = tf_charmat(d, nk, theta, pol);

    % calculate B,C for each added layer
    nm = size(M,3);
    nm = nm+1;        % add matrix for no layer
    M(:,:,nm) = eye(2);
    B = complex(zeros(1,nm));
    C = complex(zeros(1,nm));
    Mq = eye(2);      % initialize M up to layer q      
    for k = nm:-1:1   % assemble stack from substrate up
        Mq = M(:,:,k) * Mq;
        BC = Mq * [1;eta_ex];
        B(nm-k+1) = BC(1);
        C(nm-k+1) = BC(2);
    end

end
