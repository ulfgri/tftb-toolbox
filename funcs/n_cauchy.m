function [nval] = n_cauchy(lambda, par)
%function [nval] = n_cauchy(lambda, par)
%
% n_cauchy :  evaluates a Cauchy model for the refractive
%             index at specified wavelengths.
%
%             Cauchy model:
%                n = A + sum_k( B(k) / lambda^(2*k) )
%
% Input:
% lambda :   a vector of wavelengths.
% par :      parameter of the Cauchy model
%               par.A
%               par.B
%
% Output:
% nval :     a vector with refractive indices at 
%            the wavelengths lambda.

% Initial version, Ulf Griesmann, November 2013

% check arguments
if nargin < 2
   error('n_cauchy :  missing arguments.');
end

% evaluate Cauchy formula
ilam2 = 1./lambda.^2;
lc = length(par.B);
P = par.B(lc)*ilam2;
for k = lc-1:-1:1
   P = (P + par.B(k)) .* ilam2;
end
nval = par.A + P;

return
