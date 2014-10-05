function [Y] = tf_admit(d, nk, theta, pol)
%function [Y] = tf_admit(d, nk, theta, pol)
%
% tf_admit :  calculate the admittance of a stack 
%             of thin material layers.
%
% Input:
% d :        vector with layer thicknesses in units of wavelength
% nk :       vector with refractive indices for each layer
% theta  :   (Optional) angle of incidence at first interface in
%            degrees. Default is 0.
% pol :      polarization state; either 's' or 'p'.
%
% Output:
% Y :        total admittance of the thin film stack
%
% Reference:
%   H. A. Macleod, "Thin Film Optical Filters, 4th Ed.", CRC Press,
%   Boca Raton (2010)

% Initial version, Ulf Griesmann, November 2013

% calculate admittance
[B,C] = tf_bc(d, nk, theta, pol);
Y = C / B;

return
