function [Sopt] = tf_optimize_lm(S,lambda,theta,pol,mfun,didx,mfpar,obj,itmax,opt)
%function [Sopt] = tf_optimize_lm(S,lambda,theta,pol,mfun,didx,mfpar,obj,itmax,opt)
%
% tf_optimize_lm :  Layer optimization with Levenberg-Marquardt algorithm.  
%                   Adjusts thicknesses of a set of layers in 
%                   a thin film stack such that a merit function 
%                   matches a user-defined objective in a minimum
%                   least-squares sense using an unconstrained or 
%                   constrained Levenberg-Marquardt algorithm 
%                   (default is unconstrained). Requires LEVMAR.
%
% Input:
% S :        a structure array with a material stack definition
%               S(k).d :  layer thickness in um; initial values
%                         must be supplied for all thicknesses.
%               S(k).n :  refractive index table, function handle,
%                         or directly specified constant index
% lambda : a vector with wavelengths at which the film stack
%          is optimized.
% theta :  (Optional) a vector with angles of incidence in degrees
%          for which the film stack is optimized. Default is 0.
% pol :    (Optional) polarization of the light; 's', 'p', or
%          'u'. Default is 'u' (unpolarized).
% mfun :   a vector valued function handle with a merit function
%
%              merit = mfun(x,d,nk,lambda,theta,pol,didx,mfpar)
%
%          where
%                 x :      vector with thicknesses to be optimized
%                          x = d(didx)
%                 d :      vector of layer thicknesses
%                 nk :     refractive indices at wavelengths lambda
%                 lambda : vector with wavelengths
%                 theta :  vector with angles
%                 pol :    polarization
%                 didx :   indices of layers that are optimized
%                 mfpar :  structure with additional parameters
%                 obj :    a vector with targets for the merit function.
%                 merit :  a vector with a merit value for each x(k).
%          See optim/tf_rmin2.m for an example.
% didx :   (Optional) indices of layers that will be optimized.
%          Default is [2:length(S)-1].
% mfpar :  (Optional) A structure with additional parameters for
%          the merit function.
% obj :    (Optional) a vector of target values for the
%           merit function. Default is zeros(length(didx)).
% itmax :  (Optional) Maximum number of iterations. Default is 500.
% opt :    (Optional) structure with options for the 'levmar'
%          function that control the minimization. 
%              opt.init_mu :     initial mu scale factor
%              opt.thresh_grad : threshold for |gradient|
%              opt.thresh_res :  threshold for |residuum|
%              opt.diff_delta :  step size for jacobian calculation
%              opt.dscl   :      gradient scaling factor
%              opt.method :      minimization algorithm. Either
%                                'unc' for unconstrained
%                                minimization or 'con' for
%                                constrained minimization in which
%                                layer thicknesses are constrained
%                                to be > 0. Default is 'unc'.
%
%          Type 'help levmar' for more information.
%
% Output:
% Sopt :   Film stack with optimized layer thicknesses.
%

% Initial version, Ulf Griesmann, September 2013
% User defined merit functions, Ulf Griesmann, October 2013

% check arguments
if nargin < 10, opt = []; end
if nargin < 9, itmax = []; end
if nargin < 8, obj = []; end
if nargin < 7, mfpar = []; end
if nargin < 6, didx = []; end
if nargin < 5
   error('at least 5 arguments are required.');
end

if isempty(itmax), itmax = 600; end
if isempty(didx), didx = [2:length(S)-1]; end
if isempty(obj), obj = zeros(length(didx)); end
if isempty(theta), theta = 0; end
if isempty(pol), pol = 'u'; end
if iscolumn(lambda), lambda = lambda'; end
if isrow(obj), obj = obj'; end

% check options
[opts, lmov] = lm_opts_check(opt);

% compute all refractive indices at wavelengths of interest
nk = evalnk(S, lambda);

% vector of film thicknesses
d = zeros(length(S), 1);
d(2:length(S)-1) = [S(2:length(S)-1).d];
d0 = d(didx);  % initial thicknesses

% minimize the merit function
if strcmp(opts.method, 'con')
  
   lb = zeros(length(d0), 1);          % thickness >= 0
   ub = 9999*ones(length(d0), 1);      % no upper bound
   ds = opts.dscl*ones(length(d0), 1); % scaling factors

   [ret, dopt, info] = levmar(mfun, [], d0, obj, itmax, lmov, ...
                              'bc', lb, ub, ds, ...
                              d,nk,lambda,theta,pol,didx,mfpar);
   
elseif strcmp(opts.method, 'unc')

   [ret, dopt, info] = levmar(mfun, [], d0, obj, itmax, lmov, 'unc', ...
                              d,nk,lambda,theta,pol,didx,mfpar);   
end

% display optimized parameters
fprintf('\n');
switch info(7)
 case 1
    fprintf('  >>> levmar succeeded: stopped by small gradient J^T e\n');
 case 2
    fprintf('  >>> levmar succeeded: stopped by small Dp\n');
 case 3
    fprintf('  >>> levmar failed: reached maximum of %d iterations\n', itmax);
 case 4
    fprintf('  >>> levmar failed: singular matrix in levmar; increase mu\n');
 case 5
    fprintf('  >>> levmar failed: no further error reduction is possible; increase mu\n');
 case 6
    fprintf('  >>> levmar succeeded: stopped by small ||e||_2\n');
 case 7
    fprintf('  >>> levmar failed: stopped by invalid func values (NaN or Inf)\n');
end
fprintf('      Iterations : %d\n', info(6));
var = (mfun(dopt,d,nk,lambda,theta,pol,didx,mfpar)-obj).^2;
fres = sqrt( sum(var) );
fprintf('      RMS residuum : %g\n', fres);
tf_disp_d(dopt, didx, S);

% return optimized film stack
Sopt = S;
for k = 1:length(didx)
   Sopt(didx(k)).d = dopt(k);
end

return
