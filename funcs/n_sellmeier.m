function [nval] = n_sellmeier(lambda, par)
%function [nval] = n_sellmeier(lambda, par)
%
% n_sellmeier :  evaluates a Sellmeier model for the refractive
%                index at specified wavelengths.
%
%                Sellmeier model:
%                   n^2 = 1 + sum_k( lambda^2 * A(k) / (lambda^2 - B(k)) )
%
% Input:
% lambda :   a vector of wavelengths.
% par :      parameter of the Sellmeier model
%               par.B  :  "oscillator strengths"
%               par.C  :  (resonance wavelengths).^2
%
% Output:
% nval :     a vector with refractive indices at 
%            the wavelengths lambda.
%
% Reference:
% B. Tatian, "Fitting refractive-index data with the Sellmeier
% dispersion formula", Appl. Opt. 23(24), 4477-4485, 1984


% Initial version, Ulf Griesmann, November 2013

% check arguments
if nargin < 2
   error('n_sellmeier :  missing arguments.');
end
if length(par.A) ~= length(par.B)
   error('n_sellmeier: inconsistent length of par.A and par.B.');
end

% evaluate Sellmeier formula
lam2 = lambda.^2;
n2 = ones(size(lambda));
for k=1:length(par.B)
   n2 = n2 + par.A(k)*lam2 ./ (lam2 - par.B(k));
end
nval = sqrt(n2);

return
