function tf_plotGD(stack, lambda, theta, pol, type)
%function tf_plotGD(stack, lambda, theta, pol, type)
%
% tf_plotGD :  plot group delay (GD) and group delay 
%              dispersion (GDD) as a function of wavelength.
%
% Input:
% stack :   a structure array with a material stack definition
%              stack(k).d :  layer thickness in um
%              stack(k).n :  refractive index table, function
%                            handle, or directly specified constant
%                            index
% lambda :  vector with wavelengths
% theta :   the angle of incidence on the first layer interface 
%           in degrees.
% pol :     polarization; either 's' or 'p'.
% type :    type of plot; either 'r' (reflection), 't'
%           (transmission), or 'b' (both).

% Initial version, Ulf Griesmann, January 2014

% parameters
lwidth = 2;   % plot line width
tfsize = 16;  % title font size
lfsize = 14;  % label/legend font size
if is_octave
   msize = 12;   % marker size for plotting
else
   msize = 24;
end

% check arguments
if nargin < 5
   error('tf_plotGD :  function requires 5 input arguments.');
end

% calculate GD, GDD
gdr = [];
gdt = [];
gddr = [];
gddt = [];

switch type
  
 case 'r'
    [gdr,~,gddr] = tf_gd(stack,lambda,theta,pol);
  
 case 't'
    [~,gdt,~,gddt] = tf_gd(stack,lambda,theta,pol);
  
 case 'b'
    [gdr,gdt,gddr,gddt] = tf_gd(stack,lambda,theta,pol);
  
 otherwise
    error('tf_plotGD: invalid ''type'' argument.');
  
end

% plot them
if pol == 's'
   tpol = 's-pol';
elseif pol == 'p'
   tpol = 'p-pol';
else
   error('tf_plotGD: polarization must be ''s'' or ''p''.');
end

opts.xlabel = 'Wavelength / um';
opts.grid = 1;
if ~isempty(gdr)
   opts.rlabel = 'GD / fs';
   opts.title = ['Reflection Group Delay (',tpol,')'];
   tf_plot(lambda, gdr, [], [], opts, [], 1);
end
if ~isempty(gdt)
   opts.rlabel = 'GD / fs';
   opts.title = ['Transmission Group Delay (',tpol,')'];
   tf_plot(lambda, gdt, [], [], opts, [], 1);
end
if ~isempty(gddr)
   opts.rlabel = 'GDD / fs^2';
   opts.title = ['Reflection Group Delay Dispersion (',tpol,')'];
   tf_plot(lambda, gddr, [], [], opts, [], 1);
end
if ~isempty(gddt)
   opts.rlabel = 'GDD / fs^2';
   opts.title = ['Transmission Group Delay Dispersion (',tpol,')'];
   tf_plot(lambda, gddt, [], [], opts, [], 1);
end

return
