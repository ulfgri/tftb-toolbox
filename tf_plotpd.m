function tf_plotpd(L, P, D, xtext, xrange, bnew)
%function tf_plotpd(L, P, D, xtext, xrange, bnew)
%
% tf_plotpd :  plot ellipsometric Psi(lambda) and Delta(lambda)
%
% Input:
% L :       a vector with wavelengths
% P :       Psi(lambda)
% D :       Delta(lambda)
% xtext :   (Optional) a string with a label for the abscissa. 
%           Default is 'Lambda / um'.
% xrange :  (Optional) a 1x2 vector with lower and upper bound of the
%           independent variable to be plotted
% bnew :    (Optional) create a new figure if > 0. Default is 0.
%

% constants
lwidth = 2;  % plot line width
tfsize = 16;  % title font size
lfsize = 14;  % label/legend font size

% check arguments
if nargin < 6, bnew = []; end
if nargin < 5, xrange = []; end
if nargin < 4, xtext = 'Lambda / um'; end
if nargin < 3
   error('tf_plotpd :  at least three arguments required.');
end
if isempty(bnew), bnew = 0; end

% get data within range
if ~isempty(xrange)
   idx = find(L > xrange(1) & L < xrange(2));
   L = L(idx);
   P = P(idx);
   D = D(idx);
end

% make new plot window
if bnew
   figure
end

% plot Psi
subplot(1,2,1);
plot(L, P, 'r', 'Linewidth',lwidth);
xlabel(xtext, 'Fontsize',lfsize);
ylabel('Psi (deg)', 'Fontsize',lfsize);

% plot Delta
subplot(1,2,2);
plot(L, D, 'b', 'Linewidth',lwidth);
xlabel(xtext, 'Fontsize',lfsize);
ylabel('Delta (deg)', 'Fontsize',lfsize);

return
