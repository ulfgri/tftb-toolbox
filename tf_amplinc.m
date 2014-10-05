function [r, t] = tf_amplinc(d, nk, theta, pol)
%function [r, t] = tf_amplinc(d, nk, theta, pol)
%
% tf_ampl :  calculate the incremental amplitudes of light waves 
%            reflected and transmitted by a stack of thin material
%            layers for each layer of the stack as it is built up.
%
% Input:
% d :        vector with layer thicknesses in units of wavelength
% nk :       vector with refractive indices for each layer
% theta  :   (Optional) angle of incidence at first interface in
%            degrees. Default is 0.
% pol :      polarization state; either 's' or 'p'.
%
% Output:
% r :        vector of amplitudes of reflected waves, s- or p-polarized,
% t :        vector of amplitude of transmitted waves, s- or p-polarized
%
% Reference:
%   S. Larouche and L. Martinu, "OpenFilters: open-source software 
%   for the design, optimization, and synthesis of optical
%   filters", Appl. Opt. 47(13), C219-C230 (2008)

% Initial version, Ulf Griesmann, October 2013

% check arguments
if nargin < 4
   error('tf_amplinc :  must have 4 arguments.');
end
if length(d) ~= length(nk)
   error('tf_amplinc :  number of thicknesses ~= number of indices.');
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
   error('tf_amplinc :  unknown polarization state.');
end

% get characteristic matrices for layers
M = tf_charmat(d, nk, theta, pol);

% calculate reflectance for each added layer
nm = size(M,3);
nm = nm+1;        % add matrix for no layer
M(:,:,nm) = eye(2);
r = complex(zeros(1,nm));
t = complex(zeros(1,nm));
Mq = eye(2);      % initialize M up to layer q      
for k = nm:-1:1   % assemble stack from substrate up
   Mq = M(:,:,k) * Mq;
   D =  eta_in*Mq(1,1) + eta_ex*Mq(2,2) + ...
        eta_in*eta_ex*Mq(1,2) + Mq(2,1);
   r(nm-k+1) = (eta_in*Mq(1,1) - eta_ex*Mq(2,2) + ...
                eta_in*eta_ex*Mq(1,2) - Mq(2,1)) / D;
   t(nm-k+1) = 2*eta_in / D;
end

return
