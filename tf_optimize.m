function [Sopt] = tf_optimize(S,lambda,theta,pol,mfun,didx,mfpar,obj,itmax,tol)
%function [Sopt] = tf_optimize(S,lambda,theta,pol,mfun,didx,mfpar,obj,itmax,tol)
%
% tf_optimize :  Nonlinear optimization of layers.
%                Adjusts thicknesses of a set of layers in 
%                a thin film stack such that a merit function 
%                is minimized. The function uses the sequential
%                quadratic programming (SQP) algorithm to minimize
%                the merit function.
%
% Input:
% S :        a structure array with a material stack definition
%               S(k).d :  layer thickness in um; initial values
%                            must be supplied for all thicknesses.
%               S(k).n :  refractive index table, function handle,
%                         or directly specified constant index
% lambda : a vector with wavelengths at which the film stack
%          is optimized.
% theta :  (Optional) a vector with angles of incidence in degrees
%          for which the film stack is optimized. Default is 0.
% pol :    (Optional) polarization of the light; 's', 'p', or
%          'u'. Default is 'u' (unpolarized).
% mfun :   a scalar valued function handle with a merit function
%
%              merit = mfun(x,d,nk,lambda,theta,pol,didx,mfpar,obj)
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
%                 obj :    target value for the merit function
%                 merit :  a scalar merit value.
%          See optim/tf_rmin.m for an example.
% didx :   (Optional) indices of layers that will be optimized.
%          Default is [2:length(S)-1].
% mfpar :  (Optional) A structure with additional parameters for
%          the merit function. 
% obj :    (Optional) a scalar with the objective for the merit function. 
%          Default is 0.
% itmax :  (Optional) Maximum number of iterations. Default is 500.
% tol :    (Optional) Specifies the tolerance for the stopping
%          critera. Default is 1e-5.
%
% Output:
% Sopt :   Film stack with optimized layer thicknesses.
%
% NOTE: In MATLAB this function requires 'fmincon' from the MATLAB 
% optimization toolbox. 

% Initial version, Ulf Griesmann, September 2013
% User defined merit functions, Ulf Griesmann, October 2013

% check arguments
if nargin < 10, tol = []; end
if nargin < 9, itmax = []; end
if nargin < 8, obj = []; end
if nargin < 7, mfpar = []; end
if nargin < 6, didx = []; end
if nargin < 5
   error('tf_optimize: at least 5 input arguments are required.');
end

if isempty(tol), tol = 1e-5; end
if isempty(itmax), itmax = 500; end
if isempty(obj), obj = 0; end
if isempty(didx), didx = [2:length(S)-1]; end
if isempty(theta), theta = 0; end
if isempty(pol), pol = 'u'; end
if iscolumn(lambda), lambda = lambda'; end

% compute all refractive indices at wavelengths of interest
nk = evalnk(S, lambda);

% vector of film thicknesses
d = zeros(length(S), 1);
d(2:length(S)-1) = [S(2:length(S)-1).d];
d0 = d(didx);  % initial thicknesses

% find a minimum of the merit function
lb = zeros(length(d0),1); % thickness >= 0
ub = Inf(length(d0),1);   % no upper bound
if is_octave()
   [dopt, merit, info, iter] = ...
       sqp(d0, @(x)mfun(x,d,nk,lambda,theta,pol,didx,mfpar,obj), ...
           [], [], lb, ub, itmax, tol);
else
   opts = optimset('fmincon'); % requires the MATLAB Optimization Toolbox
   opts.MaxIter = itmax;
   opts.Algorithm = 'sqp';
   opts.Display = 'none';
   opts.TolX = tol;
   [dopt, merit, info, output] = ...
       fmincon(@(x)mfun(x,d,nk,lambda,theta,pol,didx,mfpar,obj), d0, ...
           [], [], [], [], lb, ub, [], opts);
   iter = output.iterations;
end

% display optimized parameters
fprintf('\n');
tf_disp_info(info, iter);
fprintf('  Iterations : %d\n', iter);
fprintf('  Merit function :  %g\n', merit);   
tf_disp_d(dopt, didx, S);

% return optimized film stack
Sopt = S;
for k = 1:length(didx)
   Sopt(didx(k)).d = dopt(k);
end

return
