function [Sopt] = tf_ellip_fit(S, theta, lambda, tanpsi, didx, itmax, tol)
%function [Sopt] = tf_ellip_fit(S, theta, lambda, tanpsi, didx, itmax, tol)
%
% tf_ellip_fit :  adjusts the layer thickness(es) of a
%                 material stack such that the ellipsometric
%                 function Psi(lambda) matches measured
%                 ellipsometric data.
%
% Input:
% S :        a structure array with a material stack definition
%               S(k).d :  layer thickness in um; initial values
%                         must be supplied for all thicknesses.
%               S(k).n :  refractive index table, function handle,
%                         or directly specified constant index
% theta :  the angle of incidence for the ellipsometric measurement. 
% lambda : a vector with wavelengths in micrometer at which the 
%          film stack was measured with the ellipsometer.
% tanpsi : a vector with the measured ellipsometric
%          tan(Psi(lambda)) = |rho|.
% didx :   (Optional) a vector with the layer indices that are
%          varied during the optimization. Default is [2:length(S)-1].
% itmax :  (Optional) Maximum number of iterations. Default is 500.
% tol :    (Optional) Specifies the tolerance for the stopping
%          critera. Default is 1e-5.
%
% Output:
% Sopt :   a structure array with a material stack having optimized
%          layer thicknesses that fit the ellipsometric measurements.
%
% NOTE: In MATLAB this function requires the MATLAB optimization toolbox.

% Initial version, Ulf Griesmann, December 2014

    % check arguments
    if nargin < 7, tol = []; end
    if nargin < 6, itmax = []; end
    if nargin < 5, didx = []; end
    if nargin < 4
        error('tf_fit_ellip: at least four input arguments required.');
    end
    if isempty(tol), tol = 1e-5; end
    if isempty(itmax), itmax = 500; end
    if isempty(didx), didx = [2:length(S)-1]; end

    % compute all refractive indices at wavelengths of interest
    nk = evalnk(S, lambda);

    % vector of film thicknesses
    d = zeros(length(S), 1);
    d(2:length(S)-1) = [S(2:length(S)-1).d];
    d0 = d(didx);  % initial thicknesses

    % find a minimum of the merit function
    lb = zeros(size(d0)); % thickness >= 0
    ub = Inf(size(d0));   % no upper bound

    % find thicknesses
    if is_octave()
        [dopt, merit, info, iter] = ...
            sqp(d0, @(x)tf_rho_chi2(x,d,nk,theta,lambda,tanpsi,didx), ...
                [], [], lb, ub, itmax, tol);
    else
        opts = optimset('fmincon'); % requires the MATLAB Optimization Toolbox
        opts.MaxIter = itmax;
        opts.Algorithm = 'sqp';
        opts.Display = 'none';
        opts.TolX = tol;
        [dopt, merit, info, output] = ...
             fmincon(@(x)tf_rho_chi2(x,d,nk,theta,lambda,tanpsi,didx), d0, ...
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

end
