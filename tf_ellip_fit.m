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
% itmax :  (Optional) Maximum number of iterations. Default is 100.
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
    if isempty(itmax), itmax = 100; end
    if isempty(didx), didx = [2:length(S)-1]; end

    % refractive indices at wavelengths of interest
    nk = evalnk(S, lambda);

    % vector of film thicknesses
    d = zeros(length(S), 1);
    d(2:length(S)-1) = [S(2:length(S)-1).d];
    d0 = d(didx);  % initial thicknesses

    % find thicknesses
    if is_octave
      
        if exist('leasqr') ~= 2
            error('tf_ellip_fit: must install/load package ''optim''.');
        end
        [rhout,dopt,flag,iter] = leasqr(lambda,tanpsi,d0, ...
                                        @(L,X)tf_rho_oct(L,X,d,nk,theta,didx), ...
                                        tol,itmax);
        res = rhout - tanpsi;
      
    else

        if exist('lsqcurvefit') ~= 2 % use optimization toolbox
            error('tf_ellip_fit: ''lsqcurvefit'' from MATLAB optimization toolbox required.');
        end
        opts.MaxIter = itmax;
        opts.TolX = tol;
        [dopt,~,res,flag,out] = lsqcurvefit(@(X,L)tf_rho_mat(X,L,d,nk,theta,didx), ...
                                            d0,lambda,tanpsi,[],[],opts);
        iter = out.iterations;
        
    end

    % display optimized parameters
    fprintf('\n');
    if flag == 1, fprintf('>> Fit successful.\n'); end
    if flag == 0, fprintf('>> Failed to find a solution.\n'); end
    fprintf('   Iterations :   %d\n', iter);
    fprintf('   RMS residuum : %g\n', sqrt( sum(res.^2))/length(res) );
    tf_disp_d(dopt, didx, S);

    % return optimized film stack
    if nargout
        Sopt = S;
        for k = 1:length(didx)
            Sopt(didx(k)).d = dopt(k);
        end
    end
end
