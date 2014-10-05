function tf_stack(stack, lambda)
%function tf_stack(stack, lambda)
%
% tf_stack : displays the properties of a thin film stack
%            at a wavelength lambda
%
% stack :    film stack definition
%               stack.d : stack thickness
%               stack.n : a refractive index value, a function
%                         handle, or a refractive index table.
% lambda :   (Optional) vector with wavelengths in um at which 
%            the stack is evaluated. Default is 0.532 um

% Initial version, Ulf Griesmann, February 2013

% check argments
if nargin < 2, lambda = []; end
if isempty(lambda), lambda = 0.532; end
if ~isrow(lambda), lambda = lambda'; end

% layer thicknesses
d = [stack.d];

% refractive indices
nk = evalnk(stack, lambda);

% material names
mname = getnames(stack);

% display it all
for l = 1:length(lambda)

   fprintf('\n');
   fprintf('Layer #      d / um  opt.d/lam           n           k  Material (Coll)\n');
   fprintf('-------  ----------  ---------  ----------  ----------  ---------------\n');
   for k = 1:length(stack)
      fprintf('%7d  %10.4f  %9.3f  %10.4f  %10.4g  %s\n', ...
              k, d(k), d(k)*real(nk(k,l))/lambda(l), ...
              real(nk(k,l)), -imag(nk(k,l)), mname{k} );
   end
   fprintf('lambda = %.5f um\n', lambda(l));
   fprintf('sum(d) = %.4f um\n\n', sum(d(2:end-1)) );
   
end

return
