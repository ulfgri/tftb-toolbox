function tf_plotY(stack, lambda, theta, pol, nila)
%function tf_plotY(stack, lambda, theta, pol, nila)
%
% tf_plotY :  plot the admittance diagram for a thin film stack. 
%             The admittances for each of the layers
%             are marked with dots. The admittance of the substrate
%             is marked with a green dot, the admittance of the 
%             final, assembled stack is marked with a red dot.
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

% Initial version, Ulf Griesmann, November 2013

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
   error('tf_plotY :  function requires 4 arguments.');
end
if isempty(nila), nila = 100; end
if ~isscalar(lambda)
   error('tf_plotY :  lambda must be scalar.');
end

% compute thicknesses in units of lambda
d = [stack.d] / lambda;

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

% calculate admittances
Y = tf_admitinc(d,nk,theta,pol);
Yi = tf_admitinc(di,ni,theta,pol);

% plot them
figure
axis('square');
hold on

plot([min(real(Yi)),max(real(Yi))],[0,0], 'k');
plot(real(Yi),imag(Yi),'b', 'Linewidth',lwidth);

plot(real(Y(1)), imag(Y(1)), '.g','Markersize',msize);
plot(real(Y(2:end-1)), imag(Y(2:end-1)), '.b','Markersize',msize);
plot(real(Y(end)), imag(Y(end)), '.r','Markersize',msize);

grid on

xlabel('Re(Y)', 'Fontsize',lfsize);
ylabel('Im(Y)', 'Fontsize',lfsize);
if pol == 's'
  title(sprintf('Admittance (s-pol) @ %.4f um', lambda), ...
        'Fontsize',tfsize);
elseif pol == 'p'
  title(sprintf('Admittance (p-pol) @ %.4f um', lambda), ...
        'Fontsize',tfsize);
else
  error('polarization must be s or p.');
end

return
