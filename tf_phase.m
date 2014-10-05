function [phir, phit] = tf_phase(stack, lambda, theta, pol, bunwrap)
%function [phir, phit] = tf_phase(stack, lambda, theta, pol, bunwrap)
%
% tf_phase :  calculates the phase of the amplitudes r and t
%             in the complex plane. 
%
% Input:
% stack :   a structure array with a material stack definition
%              stack(k).d :  layer thickness in um
%              stack(k).n :  refractive index table, function
%                            handle, or directly specified 
%                            constant index
% lambda :  vector with wavelengths
% theta :   the angle of incidence on the first layer interface in degrees.
% pol :     polarization; either 's' or 'p'.
% bunwrap : (Optional) determines if the phases are unwrapped. If
%           == 0 the phases will not be unwrapped. Default is 0
%           (no unwrapping). 
%
% Output:
% phir :    vector with the phase of the reflected amplitude
%           in radians.
% phit :    vector with the phase of the transmitted amplitude
%           in radians.
%
% Reference:
% + S. Larouche and L. Martinu, "OpenFilters: open-source software 
%   for the design, optimization, and synthesis of optical
%   filters", Appl. Opt. 47(13), C219-C230 (2008)

% Initial version, Ulf Griesmann, December 2013

% check arguments
if nargin < 5, bunwrap = []; end
if nargin < 4
   error('tf_phase :  function requires 4 arguments.');
end
if ~strcmp(pol, 's') & ~strcmp(pol, 'p')
   error('tf_phase :  polarization must be ''s'' or ''p''.');
end
if isempty(bunwrap), bunwrap = 0; end
if isempty(theta), theta = 0; end

% lambda must be a row vector
if ~isrow(lambda), lambda = lambda'; end

% thicknesses at all wavelengths (one column per wavelength)
d = [stack.d];
if isrow(d), d = d'; end
d = bsxfun(@rdivide, d, lambda);

% indices at all wavelengths (one column per wavelength)
nk = evalnk(stack, lambda);

% calculate amplitudes for reflection and transmission
r = zeros(1,length(lambda));
t = zeros(1,length(lambda));
for l = 1:length(lambda)
    [r(l), t(l)] = tf_ampl(d(:,l), nk(:,l), theta, pol);
end

% calculate phases
phir = angle(r);
phit = angle(t);
if bunwrap
   phir = unwrap(phir);
   phit = unwrap(phit);
end
  
return
