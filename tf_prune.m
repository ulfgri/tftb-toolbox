function [so] = tf_prune(si, drange)
%function [so] = tf_prune(si, drange)
%
% tf_prune :  remove layers with thickness outside a specified 
%             range. Entrance and exit layers are ignored.
%
% Input:
% si :       a structure array with a material stack definition
%              si(k).d :  layer thickness in um
%              si(k).n :  refractive index table, function
%                         handle, or directly specified constant index
% drange :   a scalar or a vector of lenth two with the minimum, 
%            in drange(1), and maximum, in drange(2), of the 
%            thickness range. The maximum of the range is optional, 
%            it is set to 'inf' when only the minimum is specified.
%
% Output:
% so :       a structure array with the pruned material stack.

% initial version, Ulf Griesmann, December 2013

% check arguments
if nargin < 2
   error('tf_prune: function requires 2 input arguments.');
end
if length(drange) < 2
   drange(2) = inf;
end
if ~isrow(si), si = si'; end

d = [si(2:end-1).d];
idx = find(d >= drange(1) & d <= drange(2)) + 1;
so = [si(1), si(idx), si(end)];

return
