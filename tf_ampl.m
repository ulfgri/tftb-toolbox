function [r, t] = tf_ampl(d, nk, theta, pol)
%function [r, t] = tf_ampl(d, nk, theta, pol)
%
% tf_ampl :  calculate the amplitudes of light waves reflected and
%            transmitted by a stack of thin material layers.
%
% Input:
% d :        vector with layer thicknesses in units of wavelength
% nk :       complex vector with refractive indices for each layer
% theta  :   (Optional) angle of incidence at first interface in
%            degrees. Default is 0.
% pol :      polarization state; either 's' or 'p'.
%
% Output:
% r :        amplitude of reflected waves, s- or p-polarized
% t :        amplitude of transmitted waves, s- or p-polarized
%
% Reference:
% + S. Larouche and L. Martinu, "OpenFilters: open-source software 
%   for the design, optimization, and synthesis of optical
%   filters", Appl. Opt. 47(13), C219-C230 (2008)

% Initial version, Ulf Griesmann, October 2013

    % check arguments
    if nargin < 4
        error('tf_ampl :  must have 4 arguments.');
    end
    if length(d) ~= length(nk)
        error('tf_ampl :  number of thicknesses ~= number of indices.');
    end
    if isempty(theta), theta = 0; end

    % pseudo-indices for entrance and exit materials
    alpha2 = (nk(1) * sin(pi*theta/180))^2;  % Snell constant ^2
    if pol == 's'
        eta_in = sqrt(nk(1)^2 - alpha2);
        eta_ex = sqrt(nk(end)^2 - alpha2);
    elseif pol == 'p'
        eta_in = nk(1)^2 / sqrt(nk(1)^2 - alpha2);
        eta_ex = nk(end)^2 / sqrt(nk(end)^2 - alpha2);
    else
        error('tf_ampl :  unknown polarization state.');
    end

    % get characteristic matrices for layers
    M = tf_charmat(d, nk, theta, pol);

    % characteristic matrix Mq for the whole stack
    Mq = M(:,:,1);
    for k = 2:size(M,3)
        Mq = Mq * M(:,:,k);
    end
    D =  eta_in*Mq(1,1) + eta_ex*Mq(2,2) + eta_in*eta_ex*Mq(1,2) + Mq(2,1);
    r = (eta_in*Mq(1,1) - eta_ex*Mq(2,2) + eta_in*eta_ex*Mq(1,2) - Mq(2,1)) / D;
    t =  2*eta_in / D;

end
