function tf_plotnk(ri, range, ttl, bnew)
%function tf_plotnk(ri, range, ttl, bnew)
%
% tf_plotnk :  plot real and imaginary parts of one or more refractive
%              index spectra as function of wavelength.
%
% Input:
% ri :      EITHER a structure (or cell array with structures) with 
%           refractive index data as a function of wavelength 
%           in micrometer
%              ri.nk :     refractive index
%              ri.lambda : wavelengths in micrometer
%           OR a function handle with a refractive index
%           function. In this case a range argument must
%           also be supplied.
% range :   (Optional) a 1x2 vector with lower and upper bound of the
%           wavelength range to be plotted. MUST be provided if 
%           a function handle is used to describe a refractive index.
% ttl :     (Optional) string with title of the plot
% bnew :    (Optional) if ~= 0, a new plotting window is opened. 
%           Default is 1.
%

% constants
lwidth = 2;   % plot line width
tfsize = 16;  % title font size
lfsize = 14;  % label/legend font size

% check arguments
if nargin < 4, bnew = []; end
if nargin < 3, ttl = []; end
if nargin < 2, range = []; end
if nargin < 1
   error('tf_plotnk :  two arguments required.');
end
if isempty(bnew), bnew = 1; end
if ~iscell(ri), ri = {ri}; end

% colors
ncol = 'crm';
kcol = 'gbk';

% make new plot window
if bnew
   figure
end

for k = 1:length(ri)
  
   % check if we have a function handle
   if isa(ri{k}, 'function_handle')
      if isempty(range)
         error('tf_plotnk :  range argument required for function handle.');
      end
      refi.lambda = [range(1):(range(2)-range(1))/256:range(2)];
      refi.nk = ri{k}(refi.lambda);
      refi.name = func2str(ri{k});
      ri{k} = refi;
      
   % get data within range
   elseif ~isempty(range)
      idx = find(ri{k}.lambda > range(1) & ri{k}.lambda < range(2));
      if isempty(idx)
         error('tf_plotnk :  no index data in wavelength range.');
      end
      ri{k}.lambda = ri{k}.lambda(idx);
      ri{k}.nk = ri{k}.nk(idx);
   end

   % plot the real part of the refractive index
   subplot(1,2,1);
   ci = 1 + mod(k, length(ncol));
   if ri{k}.lambda(end)/ri{k}.lambda(1) > 20  % log x scale
      semilogx(ri{k}.lambda, real(ri{k}.nk), ncol(ci), 'Linewidth',lwidth);
   else
      plot(ri{k}.lambda, real(ri{k}.nk), ncol(ci), 'Linewidth',lwidth);
   end
   xlabel('Wavelength / um', 'Fontsize',lfsize);
   ylabel('Refractive index n', 'Fontsize',lfsize);
   if length(ri) > 1 && k==1
      hold on
   end

   % plot the imaginary part of the index
   subplot(1,2,2);
   if ri{k}.lambda(end)/ri{k}.lambda(1) > 20  % log x scale
      loglog(ri{k}.lambda, -imag(ri{k}.nk), kcol(ci), 'Linewidth',lwidth);
   else
      semilogy(ri{k}.lambda, -imag(ri{k}.nk), kcol(ci), 'Linewidth',lwidth);
   end
   xlabel('Wavelength / um', 'Fontsize',lfsize);
   ylabel('Extinction coefficient k', 'Fontsize',lfsize);
   if length(ri) > 1 && k==1
      hold on
   end
   
end

% plot title
if ~isempty(ttl)
   subplot(1,2,1);
   title(ttl, 'Fontsize',tfsize);
   subplot(1,2,2);
   title('   ', 'Fontsize',tfsize);
end

% legends
leg = cellfun(@(x)x.name, ri, 'UniformOutput',0);
for k = 1:length(leg)
   leg{k} = esc_underscore(leg{k});
end
subplot(1,2,1);
L = legend(leg);
set(L, 'Fontsize',lfsize);
subplot(1,2,2);
L = legend(leg);
set(L, 'Fontsize',lfsize);

return


function sout = esc_underscore(sinp)
%
% place '\' before underscores
%
idx = 1;
for k = 1:length(sinp)
   if sinp(k) == '_'
      sout(idx) = '\';
      idx = idx+1;
   end
   sout(idx) = sinp(k);
   idx = idx+1;
end

return