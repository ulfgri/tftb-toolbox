function [so,li] = tf_insert(si, layer, pos, d, n)
%function [so,li] = tf_insert(si, layer, pos, d, n)
%
% tf_insert :  insert a new material layer in a thin film stack
%              at a specified position
%
% Input:
% si :       a structure array with a material stack definition
%              si(k).d :  layer thickness in um
%              si(k).n :  refractive index table, function
%                         handle, or directly specified constant index
% layer :    layer index at which to insert the new material
% pos :      position within the layer at which to insert the
%            new material in um. If layer == 1, the new layer will be
%            the new entrance layer of the stack, if layer == end, the new
%            will become the first layer on the substrate.
% d :        thickness of the new layer
% n :        complex refractive index of the new layer defined by a
%            refractive index table, function handle, or directly specified 
%            constant index.
%
% Output:
% so :       a structure array with the new material stack.
% li :       layer index of the new layer in the output stack

% initial version, Ulf Griesmann, November 2013

% check arguments
if nargin < 5
   error('tf_insert: function requires 5 input arguments.');
end
if pos < 0
   error('tf_insert: argument pos must be positive.');
end

% make sure input stack is a row
if ~isrow(si), si = si'; end

% length of input stack
lsi = length(si);
if layer > lsi
   error('tf_insert: specified film stack layer index does not exist.');
end

% insert at entry
if layer == 1
   so(1) = si(1);
   so(3:lsi+1) = si(2:lsi);
   so(2).d = d;
   so(2).n = n;
   li = 1;

% insert layer at exit
elseif layer == lsi
   so = si(1:lsi-1);
   so(lsi).d = d;
   so(lsi).n = n;
   so(lsi+1) = si(lsi);
   li = lsi;

% insert it within the stack
else
   
   % copy layers at entrance
   so = si(1:layer-1);
   
   if pos == 0
      so(layer).d = d;
      so(layer).n = n;
      so(layer+1) = si(layer);
      li = layer;
      
   elseif pos == si(layer).d
      so(layer) = si(layer);
      so(layer+1).d = d;
      so(layer+1).n = n;
      li = layer+1;
      
   elseif pos > si(layer).d
       error(sprintf('tf_insert: position larger than thickness of layer %d.\n', layer) );
     
   else
      so(layer).d = pos;
      so(layer).n = si(layer).n;
      so(layer+1).d = d;
      so(layer+1).n = n;
      so(layer+2).d = si(layer).d - pos;
      so(layer+2).n = si(layer).n;
      li = layer+1;
   end

   % copy layers at substrate
   so = [so, si(layer+1:lsi)];
   
end

return
