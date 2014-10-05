function tf_plotE(stack, lambda, theta, pol, nila)
%function tf_plotE(stack, lambda, theta, pol, nila)
%
% tf_plotE : plot the electrical field strength |E| 
%            in a thin film stack relative to the
%            strength of the irradiating field at the
%            entrance of the stack.
%
% Input:
% stack :   a structure array with a material stack definition
%              stack(k).d :  layer thickness in um
%              stack(k).n :  refractive index table, function
%                            handle, or directly specified constant
%                            index
% lambda :  wavelength
% theta :   the angle of incidence on the first layer interface in degrees.
% pol :     polarization; either 's' or 'p'.
% nila :    (Optional) number of intermediate layers between
%           interfaces for which the admittances are computed. 
%           Default is 100.

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
if nargin < 5, nila = []; end
if nargin < 4
   error('tf_plotE :  function requires 4 arguments.');
end
if isempty(nila), nila = 100; end
if ~isscalar(lambda)
   error('tf_plotE :  lambda must be scalar.');
end

% compute thicknesses in units of lambda
d = [stack.d]/lambda;

% compute indices at wavelength
nk = evalnk(stack, lambda);

% build stack with intermediate layers
di(1) = 0;  ni(1) = nk(1);
for k = 2:length(d)-1
   dd = d(k) / nila;
   di = [di;repmat(dd,nila,1)];
   ni = [ni;repmat(nk(k),nila,1)];
end
di(end+1) = d(end);
ni(end+1) = nk(end);

% calculate field strength
E = tf_efield(di,ni,theta,pol);

% distance in stack
ds = cumsum(di*lambda);
ds = ds(1:end-1);

% plot them
figure
hold on
plot(ds, E, 'b', 'Linewidth',lwidth);
dc = cumsum(d*lambda);
Em = max(E);
for k=2:length(dc)
   plot([dc(k),dc(k)],[0,Em],'k', 'Linewidth',1);
end
xlabel('Distance from entry interface / um', 'Fontsize',lfsize);
ylabel('Rel. |E|', 'Fontsize',lfsize);
if pol == 's'
  title(sprintf('Electric Field |E| (s-pol) @ %.4f um', lambda), ...
        'Fontsize',tfsize);
elseif pol == 'p'
  title(sprintf('Electric Field |E| (p-pol) @ %.4f um', lambda), ...
        'Fontsize',tfsize);
else
  error('polarization must be s or p.');
end

return
