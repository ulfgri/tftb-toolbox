function [E] = tf_efield(d, nk, theta, pol)
%function [E] = tf_efield(d, nk, theta, pol)
%
% tf_efield : calculate the electrical field strength |E| at
%             interfaces in a stack of thin material layers as 
%             a fraction of the electrical field strength of the 
%             irradiating field at the stack entry interface.
%
% Input:
% d :        vector with layer thicknesses in units of wavelength
% nk :       vector with refractive indices for each layer
% theta  :   (Optional) angle of incidence at first interface in
%            degrees. Default is 0.
% pol :      polarization state; either 's' or 'p'.
%
% Output:
% E :        vector with relative field strengths.
%
% Reference:
%   H. A. Macleod, "Thin Film Optical Filters, 2n Ed.", McGraw-Hill,
%   New York (1989)

% Initial version, Ulf Griesmann, January 2014

    % check arguments
    if nargin < 4
        error('tf_efield :  must have 4 arguments.');
    end
    if length(d) ~= length(nk)
        error('tf_efield :  number of thicknesses ~= number of indices.');
    end
    if isempty(theta), theta = 0; end
    
    % pseudo-index for entrance space material
    eta_in = eta_sp(nk, theta, pol);
    
    % get characteristic matrices for layers
    M = tf_charmat(d, nk, theta, pol);

    % calculate B,C for each layer
    nm = size(M,3);
    nm = nm+1;
    M(:,:,nm) = eye(2);        % add matrix for no layer
    M = circshift(M, [0,0,1]); % at the beginning
    E = complex(zeros(1,nm));
    Mq = eye(2);      % initialize Mq
    for k = 1:nm      % traverse stack from entrance
        Mq = M(:,:,k) * Mq;
        BC = Mq * [1;eta_in];
        E(k) = abs(BC(1));
    end

end
