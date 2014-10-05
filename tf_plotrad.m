function tf_plotrad(stack, lambda, theta, pol, radtype, nila)
%function tf_plotrad(stack, lambda, theta, pol, radtype, nila)
%
% tf_plotrad :  plot the Reflectance Amplitude Diagram (or
%               circle diagram) for a thin film stack. The 
%               reflectance amplitudes at each of the layer
%               interfaces are marked with blue dots. The 
%               amplitude of the substrate (where the coating 
%               fabrication starts) is marked with a green dot, 
%               the amplitude at the top of the final layer (where 
%               the fabrication ends) is marked with a red dot.
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
% radtype : (Optional) 'r' for a reflectance amplitude diagram, 't'
%           for a transmission amplitude diagram, 'b' for both.
%           Default is 'r' (reflectance amplitude).
% nila :    (Optional) number of intermediate layers between
%           interfaces for which the amplitudes are computed. 
%           Default is 100.

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
if nargin < 6, nila = []; end
if nargin < 5, radtype = []; end
if nargin < 4
   error('tf_plotrad :  function requires 4 arguments.');
end
if isempty(radtype), radtype = 'r'; end
if isempty(nila), nila = 100; end
if ~isscalar(lambda)
   error('tf_plotrad :  lambda must be scalar.');
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

% calculate reflectance and transmittance amplitudes
[r,t]   = tf_amplinc(d, nk,theta,pol);
[ri,ti] = tf_amplinc(di,ni,theta,pol);

% plot them
uc = make_arc([1,0],[1,0],[0,0],256); % unit circle

if radtype == 'b'
   numpl = 2;
else
   numpl = 1;
end
curpl = 0;

figure
axis('square');

if radtype == 'r' || radtype == 'b'
   curpl = curpl + 1;
   subplot(1,numpl,curpl);
   hold on
   
   plot(uc(:,1),uc(:,2),'k', 'Linewidth',lwidth);
   plot([-1,1],[0,0], 'k');
   plot([0,0],[-1,1], 'k');
   
   plot(real(ri),imag(ri),'b', 'Linewidth',lwidth);
   
   plot(real(r(1)), imag(r(1)), '.g','Markersize',msize);
   plot(real(r(2:end-1)), imag(r(2:end-1)), '.b','Markersize',msize);
   plot(real(r(end)), imag(r(end)), '.r','Markersize',msize);

   grid on
   
   xlabel('Re(r)', 'Fontsize',lfsize);
   ylabel('Im(r)', 'Fontsize',lfsize);
   if pol == 's'
      title(sprintf('Reflectance amplitude (s-pol @ %.4f um)',lambda), ...
            'Fontsize',tfsize);
   elseif pol == 'p'
      title(sprintf('Reflectance amplitude (p-pol @ %.4f um)',lambda), ...
            'Fontsize',tfsize);
   else
      error('polarization must be s or p.');
   end
end

if radtype == 't' || radtype == 'b'
   curpl = curpl + 1;
   subplot(1,numpl,curpl);
   hold on
   
   plot(uc(:,1),uc(:,2),'k', 'Linewidth',lwidth);
   plot([-1,1],[0,0], 'k');
   plot([0,0],[-1,1], 'k');
   
   plot(real(ti),imag(ti),'b', 'Linewidth',lwidth);
   
   plot(real(t(1)), imag(t(1)), '.g','Markersize',msize);
   plot(real(t(2:end-1)), imag(t(2:end-1)), '.b','Markersize',msize);
   plot(real(t(end)), imag(t(end)), '.r','Markersize',msize);

   grid on
   
   xlabel('Re(t)', 'Fontsize',lfsize);
   ylabel('Im(t)', 'Fontsize',lfsize);
   if pol == 's'
      title(sprintf('Transmittance amplitude (s-pol @ %.4f um)',lambda), ...
            'Fontsize',tfsize);
   elseif pol == 'p'
      title(sprintf('Transmittance amplitude (p-pol @ %.4f um)',lambda), ...
            'Fontsize',tfsize);
   else
      error('polarization must be s or p.');
   end
end
  
return
