function tf_plotrgb(rgb, titles, swsize)
%function tf_plotrgb(rgb, titles, swsize)
%
% tf_plotrgb :  plot several color swatches
%               for a set of RGB triplets.
%
% Input:
% rgb :    a n x 3 matrix with RGB triples,
%          one per row.
% titles : (Optional) an m x n cell array of 
%          strings with titles. The color swatches
%          will be arranged in an m x n matrix.
% swsize : (Optional) a 1x2 vector with the color
%          swatch size. Default is [100,100].

% Initial version, Ulf Griesmann, October 2013

% constants
tfsize = 16;  % title font size

if nargin < 3, swsize = []; end
if nargin < 2, titles = []; end

if isempty(swsize), swsize = [100,100]; end

if ~isempty(titles)
   [M,N] = size(titles);
else
   M = 1;
   N = size(rgb,1);
end
if M*N ~= size(rgb,1)
   error('array of titles does not match number of rgb values.');
end

% display swatches
for m = 1:M
   for n=1:N
      k = (m-1)*N + n;
      sw(1,1,:) = uint16(65535*rgb(k,:));
      swr = repmat(sw, swsize);
      subplot(M,N,k);
      imshow(swr);
      title(titles{m,n}, 'Fontsize',tfsize);
   end
end

return
