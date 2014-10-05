function [par, res] = tf_fitn(lambda, rin, type, par0, mit, opt)
%function [par, res] = tf_fitn(lambda, rin, type, par0, mit, opt)
%
% tf_fitn :  calculates the parameters of a Sellmeier or Cauchy 
%            refractive index dispersion model for a given set of 
%            experimental refractive index vs. wavelength data for
%            materials with negligible absorption.
%            
%            Sellmeier model:
%               n^2 = 1 + sum_k( lambda^2 * A(k) / (lambda^2 - B(k)) )
%                  A(k) are "oscillator strengths"
%                  B(k) are resonance wavelengths squared
%
%            Cauchy model:
%               n = A + sum_k( B(k) / lambda^(2*k) )
%
% Input:
% lambda :   a vector with wavelengths.
% rin :      a vector with (the real part of) the refractive index
%            of a material at the wavelengths lambda. Must have the same
%            shape as lambda.
% type :     a string with the type of model. Either 'sellmeier' or 'cauchy'.
% par0 :     initial values of the parameters 
%                  par0.A and par0.B
% mit :      (Optional) maximum number of iterations. Default is 500.
% opt :      (Optional) options vector for the 'levmar' function.
%
% Output:
% par :      a structure with the parameters of the model: 
%                  par.A and par.B.
% res :      residuum of model and data at wavelengths lambda.
%
% Reference:
% B. Tatian, "Fitting refractive-index data with the Sellmeier
% dispersion formula", Appl. Opt. 23(24), 4477-4485, 1984
%
% NOTE 1: REQUIRES THE LEVMAR FUNCTION.
% NOTE 2: Starting values for the B coefficients are typically one or two poles 
%         in the UV and one in the IR.

% Initial version, Ulf Griesmann, November 2013

% check parameters
if nargin < 6, opt = []; end
if nargin < 5, mit = []; end
if nargin < 4
   error('tf_fitn :  missing parameter(s).');
end
if isempty(mit), mit = 500; end
type = lower(type);

% call lsq function
if strcmp(type, 'sellmeier')
  
   nt = length(par0.A);
   p0(1:nt) = par0.A;
   p0(nt+1:2*nt) = par0.B;
   [ret, popt, info] = levmar(@lm_sellmeier, [], p0, rin, mit, opt, 'unc', lambda, nt);
   par.A = popt(1:nt);
   par.B = popt(nt+1:2*nt);
   res = rin - n_sellmeier(lambda, par);
   
elseif strcmp(type, 'cauchy')
  
   nt = length(par0.B);
   p0 = par0.A;
   p0(2:nt+1) = par0.B;
   [ret, popt, info] = levmar(@lm_cauchy, [], p0, rin, mit, opt, 'unc', lambda);
   par.A = popt(1);
   par.B = popt(2:end);
   res = rin - n_cauchy(lambda, par);
   
else
   error('tf_fitn :  unrecognized type argument.');
end

% return results
if ret < 0
   error('tf_fitn :  call to levmar returned an error.')
elseif ret == mit
   error('tf_fitn :  maximum number of iterations reached.');
else
   fprintf('\n   >>> fit successful after %d iterations.\n\n', ret); 
end

return
