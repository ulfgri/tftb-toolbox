function [nke,de,arho,ccn,cck] = tf_ellip_model(S,theta,lambda,tanpsi,midx,nc,didx,itmax,tol)
%function [nke,de,arho,ccn,cck] = tf_ellip_model(S,theta,lambda,tanpsi,midx,nc,didx,itmax,tol)
%
% tf_ellip_model :  Calculates refractive index n(lambda) and extinction
%                   coefficient k(lambda) of a thin film material, and the 
%                   thickness of the film, from measured ellipsometric tan(Psi) 
%                   data. Refrative index and extinction coefficient are modeled
%                   with a Chebychev polynomial. The polynomial coefficients are
%                   adjusted such that the resulting tan(Psi) matches the 
%                   experimental data in a least-squares sense.
%                   This approach to refractive index modeling is useful when
%                   refractive index and extinction coefficient vary smoothly 
%                   with the wavelength and the physical parameters describing the 
%                   interaction of light with the material are unknown.
%
% NOTE: output arho and input tanpsi are plotted against wavelength lambda when
% no output arguments are present.
%
% Input:
% S :        a structure array with a material stack definition
%               S(k).d :  layer thickness in um; initial values
%                         must be supplied for all thicknesses.
%               S(k).n :  refractive index table, function handle,
%                         or directly specified constant index
% theta :  the angle of incidence for the ellipsometric measurement. 
% lambda : a vector with equidistant wavelengths in micrometer at which the 
%          film stack was measured with the ellipsometer.
% tanpsi : a vector with the measured ellipsometric
%          tan(Psi(lambda)) = |rho|.
% midx :   index of the layer that is modeled with a Chebychev polynomial.
% nc :     (Optional) number of Chebychev polynomial terms. Default is 20.
% didx :   (Optional) the index of the layer that is varied. Default is midx.
%          Set to 0 if the thickness is to remain unchanged.
% itmax :  (Optional) Maximum number of iterations. Default is 100.
% tol :    (Optional) Specifies the tolerance for the stopping
%          criteria. Default is 1e-5.
%
% Output:
% nke :    the estimated complex refractive index of the film material at 
%          the input wavelengths lambda.
% de :     a vector with layer optimal thicknesses if ~isempty(didx)
% arho :   least squares solution for tan(Psi(lambda)) = |rho|
% ccn :    coefficients of the Chebychev polynomial describing n(lambda)
% cck :    coefficients of the Chebychev polynomial describing k(lambda)

% initial version, Ulf Griesmann, December 2014

    % check arguments
    if nargin < 9, tol = []; end
    if nargin < 8, itmax = []; end
    if nargin < 7, didx = []; end
    if nargin < 6, nc = []; end
    if nargin < 5
        error('tf_ellip_model: function requires at least five input arguments.');
    end
    if length(lambda) ~= length(tanpsi)
        error('tf_ellip_model: length of lambda and tanpsi must be identical.');
    end
    if isrow(tanpsi), tanpsi = tanpsi'; end
    if isempty(nc), nc = 20; end
    if isempty(tol), tol = 1e-5; end
    if isempty(itmax), itmax = 100; end
    if isempty(didx), didx = midx; end
    
    % refractive indices at wavelengths of interest
    nk = evalnk(S, lambda); 

    % Chebychev coefficients of initial refractive index
    ldom = [lambda(1),lambda(end)];  % wavelength domain
    ccn0 = chebychev_estim(lambda,  real(nk(midx,:)), [1:nc], ldom);
    cck0 = chebychev_estim(lambda, -imag(nk(midx,:)), [1:nc], ldom);

    % column vector with initial parameters
    d = [S.d];
    P0 = [d(didx);ccn0(:);cck0(:)];
    
    % find refractive index model
    if is_octave
      
        if exist('leasqr') ~= 2
            error('tf_ellip_model: must install/load package ''optim''.');
        end
        [arho,Popt,flag,iter] = leasqr(lambda,tanpsi,P0, ...
                                       @(L,X)tf_nkmodel_oct(L,X,d,nk,theta,midx,nc,didx), ...
                                       tol,itmax);
        res = arho - tanpsi;
      
    else

        if exist('lsqcurvefit') ~= 2 % use optimization toolbox
            error('tf_ellip_model: ''lsqcurvefit'' from MATLAB optimization toolbox required.');
        end
        opts.MaxIter = itmax;
        opts.TolX = tol;
        [Popt,~,res,flag,out] = lsqcurvefit(@(X,L)tf_nkmodel_mat(X,L,d,nk,theta,midx,nc,didx), ...
                                            P0,lambda,tanpsi,[],[],opts);
        iter = out.iterations;
        arho = tf_nkmodel_mat(Popt,lambda,d,nk,theta,midx,nc,didx);
        
    end
    
    % display fit quality
    fprintf('\n');
    if flag == 1, fprintf('>> nk model fit successful.\n'); end
    if flag == 0, fprintf('>> nk model fit failed to find a solution.\n'); end
    fprintf('   Iterations :   %d\n', iter);
    fprintf('   RMS residuum : %g\n', sqrt( sum(res.^2))/length(res) );
    fprintf('\n');

    % return results
    nd = 0;
    if didx, nd = length(didx); end
    de = Popt(1:nd);
    ccn = Popt(1+nd:nd+nc);
    cck = Popt(nd+nc+1:end);
    ldom = [lambda(1),lambda(end)];
    nke = complex( chebychev_eval(lambda, ccn, ldom), ...
                  -chebychev_eval(lambda, cck, ldom) );
    
    % plot fit and input data
    lwidth = 2;   % plot line width
    lfsize = 14;  % label/legend font size
    tfsize = 16;  % title font size

    plot(lambda, tanpsi, 'b', 'LineWidth',lwidth);
    hold on
    grid on
    plot(lambda, arho, 'r', 'LineWidth',lwidth);
    xlabel('Wavelength / um', 'FontSize',lfsize);
    ylabel('tan(Psi)', 'FontSize',lfsize);
    legend('Measurement','Model');
    title('Refractive index model fit', 'FontSize',tfsize);

end
