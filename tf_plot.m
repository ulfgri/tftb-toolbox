function tf_plot(X, R, T, A, opts, xrange, blin, bnew)
%function tf_plot(X, R, T, A, opts, xrange, blin, bnew)
%
% tf_plot :  plot function such as reflectance, transmittance, 
%            and absorbance against an independent variable.
%
% Input:
% X :       a vector with samples from an independent variable
% R :       a vector with samples or a cell array of
%           vectors. By default assumes reflectance samples.
% T :       (Optional) a vector with samples, or a
%           cell array with vectors. Assumes transmittance by default. 
% A :       (Optional) a vector with samples, or a cell
%           array of vectors. Assumes absorbance by default.
% opts :    (Optional) A structure with text strings that annotate
%           the plot and other options.
%                opts.xlabel :   string with label for the x axis
%                opts.rlabel :   string with label for the R axis
%                opts.tlabel :   string with label for the T axis
%                opts.alabel :   string with label for the A axis
%                opts.legend :   string or cell array of strings
%                                with legends for each data set.
%                opts.location : legend location, 'northeast' or 'southeast'
%                opts.title  :   string with a title for the plot
%                opts.grid   :   if ==1, plot a grid
% xrange :  (Optional) a 1x2 vector with lower and upper bound of the
%           independent variable to be plotted
% blin :    (Optional) scalar, if ~= 0, plots have a linear
%           y-axis. Alternatively, 'blin' can be a 1x2 vector
%           where blin(1) controls the y-axis of the reflectance
%           plot, blin(2) that of the transmittance plot.
%           Default is [0,0] (both logarithmic). 
% bnew :    if ~= 0, a new plotting window is opened. Default is 1.
%

% constants
lwidth = 2;   % plot line width
tfsize = 16;  % title font size
lfsize = 14;  % label/legend font size

% check arguments
if nargin < 8, bnew = []; end
if nargin < 7, blin = []; end
if nargin < 6, xrange = []; end
if nargin < 5, text = []; end
if nargin < 4, A = []; end
if nargin < 3, T = []; end
if nargin < 2
   error('tf_plot :  at least two arguments required.');
end
if isempty(bnew), bnew = 1; end

% make it backward compatible
if ischar(opts)
   txt = opts;
   opts = struct('xlabel',txt);
end
if ~isfield(opts,'rlabel'), opts.rlabel = 'R'; end
if ~isfield(opts,'tlabel'), opts.tlabel = 'T'; end
if ~isfield(opts,'alabel'), opts.alabel = 'A'; end
if ~isfield(opts,'grid'),   opts.grid = 0; end

% make arguments cell arrays
if ~iscell(R), R = {R}; end
if isempty(blin), blin = [0,0]; end
if length(blin) == 1
    blin = repmat(blin,1,2);
end
if length(blin) ~= 3
    error('tf_plot: argument ''blin'' must have length 1 or 2.');
end

% set up plot
nump = 3;
if isempty(T)
   nump = nump - 1;
else
   if ~iscell(T), T = {T}; end
end
if isempty(A)
   nump = nump - 1;
else
   if ~iscell(A), A = {A}; end
end

% get data within range
if ~isempty(xrange)
   idx = find(X > xrange(1) & X < xrange(2));
   X = X(idx);
   for k = 1:length(R)
       R{k} = R{k}(idx);
   end
   if ~isempty(T) 
       for k = 1:length(T)
           T{k} = T{k}(idx); 
       end
   end
   if ~isempty(A)
       for k = 1:length(A)
           A{k} = A{k}(idx); 
       end
   end
end

% make new plot window
if bnew
   figure
end

% colors
pcol = 'krbgcm';

% plot data sets
for k = 1:length(R)
  
   % plot reflectance
   ci = 1 + mod(k, length(pcol));
   curp = 1;
   subplot(1,nump,curp);
   if blin(1)
     plot(X, R{k}, pcol(ci), 'Linewidth',lwidth);
   else
     semilogy(X, R{k}, pcol(ci), 'Linewidth',lwidth);
   end
   if ~isempty(opts)
      if isfield(opts,'xlabel')
         xlabel(opts.xlabel, 'Fontsize',lfsize); 
      end
   end
   ylabel(opts.rlabel, 'Fontsize',lfsize);
   if length(R) > 1 && k == 1
      hold on
   end
   if opts.grid
      grid on
   end

   % plot transmittance
   if ~isempty(T)
      ci = 1 + mod(k+1, length(pcol));
      curp = curp + 1;
      subplot(1,nump,curp);
      if blin(2)
         plot(X, T{k}, pcol(ci), 'Linewidth',lwidth);
      else
         semilogy(X, T{k}, pcol(ci), 'Linewidth',lwidth);
      end
      if ~isempty(opts)
         if isfield(opts,'xlabel') 
            xlabel(opts.xlabel, 'Fontsize',lfsize); 
         end
      end
      ylabel(opts.tlabel, 'Fontsize',lfsize);
      if length(T) > 1 && k == 1
          hold on
      end
      if opts.grid
         grid on
      end
   end

   % plot absorbance
   if ~isempty(A)
      ci = 1 + mod(k+2, length(pcol));
      curp = curp + 1;
      subplot(1,nump,curp);
      plot(X, A{k}, pcol(ci), 'Linewidth',lwidth);
      if ~isempty(opts)
         if isfield(opts,'xlabel') 
            xlabel(opts.xlabel, 'Fontsize',lfsize); 
         end
      end
      ylabel(opts.alabel, 'Fontsize',lfsize);
      if length(A) > 1 && k == 1
          hold on
      end
      if opts.grid
         grid on
      end
   end

end

% title
if isfield(opts,'title')
   curp = 1;
   subplot(1,nump,curp);
   title(opts.title, 'Fontsize',tfsize);
   if ~isempty(T)
      curp = curp + 1;
      subplot(1,nump,curp);
      title('         ', 'Fontsize',tfsize);
   end
   if ~isempty(A)
      curp = curp + 1;
      subplot(1,nump,curp);
      title('         ', 'Fontsize',tfsize);
   end
end

% legends
if isfield(opts,'legend')
   if ~isfield(opts,'location')
       opts.location = 'northeast';
   end
   curp = 1;
   subplot(1,nump,curp);
   L = legend(opts.legend);
   set(L, 'Fontsize',lfsize, 'Location',opts.location);
   if ~isempty(T)
      curp = curp + 1;
      subplot(1,nump,curp);
      L = legend(opts.legend);
      set(L, 'Fontsize',lfsize, 'Location',opts.location);
   end
   if ~isempty(A)
      curp = curp + 1;
      subplot(1,nump,curp);
      L = legend(opts.legend);
      set(L, 'Fontsize',lfsize, 'Location',opts.location);
   end
end

return
