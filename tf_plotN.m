function tf_plotN(stack, lambda, blunit)
%function tf_plotN(stack, lambda, blunit)
%
% tf_plotN : plot the refractive index profile
%            of a thin film stack. This is useful
%            for the visualization of dielectric filters.
%
% Input:
% stack :   a structure array with a material stack definition
%              stack(k).d :  layer thickness in um
%              stack(k).n :  refractive index table, function
%                            handle, or directly specified constant
%                            index
% lambda :  wavelength at which to evaluate the stack.
% blunit :  if == 1, the thickness is plotted in units of
%           wavelength, if == 0 the thickness is the physical
%           thickness of the layer stack. Default is 0.


% Initial version, Ulf Griesmann, October 2013

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
if nargin < 3, blunit = 0; end
if nargin < 2
   error('tf_plotN: two arguments required.');
end
if ~isscalar(lambda)
   error('tf_plotN: argument ''lambda'' must be scalar.')
end

% stack thickness
ds = cumsum([stack.d]);
ds = ds(1:end-1);       % ignore thickness of exit layer
if blunit
   ds = ds / lambda;
end

% index at wavelength
n = real(evalnk(stack,lambda));
n = n(2:end);           % ignore entry layer index

% bar plot
figure;
stairs(ds,n, 'Linewidth',lwidth);
hold on

nmax = 1.1*max(n);
nmin = 0.9*min(n);
for k=2:length(ds)
   plot([ds(k),ds(k)],[nmin,nmax],'k', 'Linewidth',1);
end
plot(ds(end),n(end),'.g', 'Markersize',msize);

if blunit
   xlabel('Distance from entry interface (wavelength units)', ...
          'Fontsize',lfsize);
else
   xlabel('Distance from entry interface / um', ...
          'Fontsize',lfsize);
end
ylabel(sprintf('Refractive index n @ %.4f um', lambda), ...
       'Fontsize',lfsize);

return
