function [nk] = tf_nk(ri, wlen);
%function [nk] = tf_nk(ri, wlen);
%
% tf_nk :  calculate the complex refractive index at a set of
%          wavelengths via interpolation from a table of indices.
%
% Input:
% ri :       refractive index table
%               ri.lambda : wavelength nodes in micrometer
%               ri.nk :     refractive index at wavelength nodes
%               ri.name :   name of material
% wlen :     vector with wavelengths in um at which to calculate the index
%
% Output:
% nk :       vector of complex refractive indices at wavelengths lambda
%

% Initial version, Ulf Griesmann, February 2013

% check arguments
if nargin < 2
   error('tf_nk :  two input arguments required.');
end

% check if wavelength 
if any(wlen < ri.lambda(1)) || any(wlen > ri.lambda(end))
   if isfield(ri, 'name')
      name = ri.name;
   else
      name = 'unknown';
   end
   error( sprintf('tf_nk : wavelength(s) outside range of nk(lambda) for material ''%s''.', name) );
end

nk = complex(interp1(ri.lambda, real(ri.nk), wlen, 'pchip'), ...
             interp1(ri.lambda, imag(ri.nk), wlen, 'pchip'));
return

