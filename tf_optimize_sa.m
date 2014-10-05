function [Sopt] = tf_optimize_sa(S,lambda,theta,pol,mfun,didx,mfpar,obj,mthresh,itmax,opt)
%function [Sopt] = tf_optimize_sa(S,lambda,theta,pol,mfun,didx,mfpar,obj,mthresh,itmax,opt)
%
% tf_optimize_sa : Layer optimization with Simulated Annealing.
%                  Adjusts thicknesses of a set of layers in a thin film
%                  stack such that a merit is minimized. The function
%                  uses a global adaptive simulated annealing
%                  algorithm. Based on the ASA adaptive simulated
%                  annealing library by L. Ingber.
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
% mfun :   a scalar valued function handle with a merit function
%          (same as for 'tf_optimize'):
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
% obj :    (Optional) a target value for the merit
%          function. Default is 0.
% mthresh: (Optional) A threshold value for the merit
%          minimization. Function terminates when merit < mthresh
%          Default is 1e-4.
% itmax :  (Optional) Maximum number of iterations. Default is 500.
% opt :    (Optional) structure with options for the 'devec3'
%          function that control the minimization. 
%              opt.xv :      length(didx) x 2 matrix with lower and
%                            upper limits for initial population.
%                            Default is [0,[S.d]].
%              opt.np :      number of population members; default
%                            is 20*length(didx).
%              opt.f :       step size factor F in interfal [0,2]; default
%                            is 0.005.
%              opt.cr :      crossover probability; default is 0.6.
%              opt.strategy: strategy, see 'devec3'; default is 7.
%              opt.refresh:  print info every 'refresh' iterations;
%                            default is -1 (no info)
%
% Output:
% Sopt :   Film stack with optimized layer thicknesses.
%
% Reference:
% Adaptive simulated annealing by Lester Ingber:
% http://www.ingber.com/#ASA

% Initial version, Ulf Griesmann, February 2014

% check arguments
if nargin < 11, opt = []; end
if nargin < 10, itmax = []; end
if nargin < 9, mthresh = []; end
if nargin < 8, obj = []; end
if nargin < 7, mfpar = []; end
if nargin < 6, didx = []; end
if nargin < 5
   error('at least 5 arguments are required.');
end

if isempty(itmax), itmax = 300; end
if isempty(didx), didx = [2:length(S)-1]; end
if isempty(obj), obj = 0; end
if isempty(theta), theta = 0; end
if isempty(pol), pol = 'u'; end
if isempty(mthresh), mthresh = 1e-4; end
if iscolumn(lambda), lambda = lambda'; end

% compute all refractive indices at wavelengths of interest
nk = evalnk(S, lambda);

% vector of film thicknesses
d = zeros(length(S), 1);
d(2:length(S)-1) = [S(2:length(S)-1).d];
d0 = d(didx);  % thickness limit guesses

% check devec3 options
opts = de_opts_check(opt, d0);

% find a minimum of the merit function
[dopt, merit, iter] = ...
       devec3p(@(x)mfun(x,d,nk,lambda,theta,pol,didx,mfpar,obj), ...
               mthresh,length(didx),opts.xv(:,1),opts.xv(:,2), ...
               opts.np,itmax,opts.f,opts.cr,opts.strategy,opts.refresh);

% display optimized parameters
fprintf('\n');
if iter == itmax
    fprintf(sprintf('  >>> Reached maximum number %d of iterations\n',iter));
else
    fprintf(sprintf('  >>> Merit below threshold %f\n', mthresh));
end
fprintf('      Iterations : %d\n', iter);
fprintf('      Merit function : %g\n', merit);
disp_d(dopt, didx, S);

% return optimized film stack
Sopt = S;
for k = 1:length(didx)
   Sopt(didx(k)).d = dopt(k);
end

return


function disp_d(d, didx, S)
% 
% display optimized film thicknesses
%
fprintf('\n');
fprintf('  layer #    thickness / um    material\n');
fprintf('  -------    ----------------  --------\n');
for k = 1:length(d)
   if isa(S(didx(k)).n, 'function_handle')
      mname = func2str(S(didx(k)).n);
   elseif isstruct(S(didx(k)).n)
      mname = S(didx(k)).n.name;
   else
      mname = 'undefined';
   end
   fprintf('  %-7d    %.4f            %s\n', didx(k), d(k), mname);
end
fprintf('\n');

return
