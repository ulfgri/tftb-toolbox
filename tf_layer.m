function L = tf_layer(ri, d, lambda)
%function L = tf_layer(ri, d, lambda)
%
% tf_layer :  a function to conveniently define a layer
%             structure that is part of a thin film stack.
%
% Input:
% ri :    the refractive index of the layer; a refractive 
%         index value, a function handle, or a refractive 
%         index table returned by 'tf_readnk'.
% d :     (Optional) the thickness of the layer in um or, when
%         the wavelength argument 'lambda' is present, the optical
%         thickness as a fraction of the specified wavelength. When
%         the argument is omitted, the layer thickness is set to 0.
% lambda: (Optional) a wavelength in the same units as the
%         thickness. When this argument is present, the argument
%         'd' is the optical layer thickness as fraction of the wavelength.
%
% Output:
% L :     a structure
%           L.d :  the layer thickness in um
%           L.n :  the refractive index of the layer material
%
% Example:
%         ri = tf_readnk('hfo2','sopra');
%         S(1) = tf_layer(ri, 0.25, 0.633); % lambda/4 layer
%         S(2) = tf_layer(ri, 0.3);         % 300 nm thick layer

% Initial version, Ulf Griesmann, December 2013

% check arguments
if nargin < 3, lambda = []; end
if nargin < 2, d = 0; end
if nargin < 1
   error('tf_layer: function requires at least one argument.');
end
if length(lambda) > 1
   error('tf_layer: argument ''lambda'' must be a scalar.');
end

% create structure
if isempty(lambda)
   L.d = d;
else % calculate thickness from opical thickness
  if isa(ri, 'function_handle')
      nk = ri(lambda);
   elseif isstruct(ri)
      nk = tf_nk(ri, lambda);
   else
      nk = ri;
   end
   L.d = d * lambda / real(nk);
end
L.n = ri;

return

