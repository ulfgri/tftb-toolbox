function [Y] = tf_admitinc(d, nk, theta, pol)
%function [Y] = tf_admitinc(d, nk, theta, pol)
%
% tf_admitinc :  calculate the incremental admittance of a stack 
%                of thin material layers beginning at the substrate.
%
% Input:
% d :        vector with layer thicknesses in units of wavelength
% nk :       vector with refractive indices for each layer
% theta  :   (Optional) angle of incidence at first interface in
%            degrees. Default is 0.
% pol :      polarization state; either 's' or 'p'.
%
% Output:
% Y :        vector with transmittances, s- or p-polarized
%
% Reference:
%   H. A. Macleod, "Thin Film Optical Filters, 4th Ed.", CRC Press,
%   Boca Raton (2010)

% Initial version, Ulf Griesmann, November 2013

[B,C] = tf_bcinc(d, nk, theta, pol);
Y = C ./ B;

return
