function [gdr, gdt, gddr, gddt] = tf_gd(stack, lambda, theta, pol)
%function [gdr, gdt, gddr, gddt] = tf_gd(stack, lambda, theta, pol)
%
% tf_gd :  calculate group delay (GD) and group delay
%          dispersion (GDD) for a thin film stack.
%
% Input:
% stack :   a structure array with a material stack definition
%              stack(k).d :  layer thickness in um
%              stack(k).n :  refractive index table, function
%                            handle, or directly specified 
%                            constant index
% lambda :  vector with wavelengths in micro-meter
% theta :   the angle of incidence on the first layer interface in degrees.
% pol :     polarization; either 's' or 'p'.
%
% Output:
% gdr, gdt: vectors with the group delay in fs (femto-seconds) for the 
%           reflected and transmitted fields. 
% gddr,
% gddt :    vectors with  the group delay dispersion as for the
%           reflected and transmitted fields. Unit is fs^2.
%
% Reference:
% + S. Larouche and L. Martinu, "OpenFilters: open-source software 
%   for the design, optimization, and synthesis of optical
%   filters", Appl. Opt. 47(13), C219-C230 (2008)

% Initial version, Ulf Griesmann, December 2013

% vacuum speed of light
cvac = 299792458e6; % um / s 

% check arguments
if nargin < 4
   error('tf_gd :  function requires 4 arguments.');
end

% calculate phases
[phir, phit] = tf_phase(stack, lambda, theta, pol, 1);

% calculate group delay
gdr = GD(phir, lambda, cvac);
gdt = GD(phit, lambda, cvac);

% group delay dispersion
if nargout > 2, gddr = GDD(phir, lambda, cvac); end
if nargout > 3, gddt = GDD(phit, lambda, cvac); end
  
return


function [gd] = GD(phi, lambda, cvac)
%
% group delay
%

% 7-tap kernel for 1st derivative
% (calculated with the Whittaker-Shannon interpolation formula)
D1 = [0.166666666666667,-0.25,0.5,0,-0.5,0.25,-0.166666666666667];

% calculate GD
dl = (lambda(end)-lambda(1))/(length(lambda)-1);
gd = 1e15 * conv(phi,D1,'same') .* lambda.^2 / (2*pi*cvac*dl);

% eliminate edge effects
gd(1:3) = 0;
gd(end-2:end) = 0;

return


function [gdd] = GDD(phi, lambda, cvac)
%
% group delay dispersion
%

% 7-tap kernels for 1st and 2nd derivatives
D1 = [0.166666666666667,-0.25,0.5,0,-0.5,0.25,-0.166666666666667];
D2 = [0.1374315281463841,-0.0144248508080250,-0.1791843500853839, ...
      0.1123553454940496,-0.1791843500853839,-0.0144248508080250, ...
      0.1374315281463841];

% calculate gdd
dl = (lambda(end)-lambda(1))/(length(lambda)-1);
gdd = -1e30 * (conv(phi,D1,'same') .* lambda.^3 / (2*pi^2*cvac^2*dl) + ...
               conv(phi,D2,'same') .* lambda.^4 / (2*pi^2*cvac^2*dl^2) );

% eliminate edge effects
gdd(1:3) = 0;
gdd(end-2:end) = 0;

return
