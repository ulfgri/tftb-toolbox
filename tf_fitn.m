function [par, res] = tf_fitn(lambda, rin, type, par0, mit)
%function [par, res] = tf_fitn(lambda, rin, type, par0, mit)
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
   if isempty(mit), mit = 200; end
   type = lower(type);

   % call lsq function
   if strcmp(type, 'sellmeier')
  
      nt = length(par0.A);
      p0(1:nt) = par0.A;
      p0(nt+1:2*nt) = par0.B;
   
      if is_octave
        
         if exist('leasqr') ~= 2
            error('tf_fitn: must install/load package ''optim''.');
         end
         [rout,popt,flag,iter] = leasqr(lambda,rin,p0,@lm_sellmeier_oct,1e-6,mit);
         res = rin - rout;
      
      else

         if exist('lsqcurvefit') ~= 2 % use optimization toolbox
            error('tf_fitn: ''lsqcurvefit'' from MATLAB optimization toolbox required.');
         end
         [popt,~,res,flag,out] = lsqcurvefit(@lm_sellmeier_mat,p0,lambda,rin); 
         iter = out.iterations;
         
      end

      par.A = popt(1:nt);
      par.B = popt(nt+1:2*nt);
   
   elseif strcmp(type, 'cauchy')
  
      nt = length(par0.B);
      p0 = par0.A;
      p0(2:nt+1) = par0.B;

      if is_octave
      
         if exist('leasqr') ~= 2
           error('tf_fitn: must install/load package ''optim''.');
         end
         [rout,popt,flag,iter] = leasqr(lambda,rin,p0,@lm_cauchy_oct,1e-6,mit);
         res = rin - rout;
      
      else

         if exist('lsqcurvefit') ~= 2 % use optimization toolbox
            error('tf_fitn: ''lsqcurvefit'' from MATLAB optimization toolbox required.');
         end
         [popt,~,res,flag,out] = lsqcurvefit(@lm_cauchy_mat, p0, lambda, rin); 
         iter = out.iterations;

      end

      par.A = popt(1);
      par.B = popt(2:end);
   
   else
      error('tf_fitn: type argument must be ''sellmeier'' or ''cauchy''.');
   end

   % return results
   if flag == 1
      fprintf('\n   >>> Fit successful after %d iterations. RMS residuum = %f\n\n', ...
              iter, sqrt(sum(res.^2)) ); 
   else
      fprintf('\n   >>> Failure after %d iterations.\n\n', iter); 
   end

end
