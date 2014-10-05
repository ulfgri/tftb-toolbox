function nk = evalnk(stack, lambda)
%function nk = evalnk(stack, lambda)
%
% evalnk :  calculate the complex refractive index
%           for a material stack at specific wavelengths.
%
% stack :   structure array with material stack definition
% lambda :  a vector of wavelengths
% nk :      a matrix of complex refractive indices. Each row 
%           vector contains the indices at the wavelengths lambda

% check arguments 
if iscolumn(lambda), lambda = lambda'; end

% pre-allocate output
nk = complex(zeros(length(stack), length(lambda)));

for k = 1:length(stack)
   if isa(stack(k).n, 'function_handle')
      nk(k,:) = stack(k).n( lambda );
   elseif isstruct(stack(k).n)
      nk(k,:) = tf_nk(stack(k).n, lambda);
   else
      nk(k,:) = repmat(stack(k).n, 1,length(lambda));
   end
end

return
