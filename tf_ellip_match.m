function [R] = tf_ellip_match(S, theta, lambda, tanpsi, D, didx)
%function [R] = tf_ellip_match(S, theta, lambda, tanpsi, D, didx)
%
% tf_ellip_match :  Calculates (and plots) the rms of the difference of
%                   measured ellipsometric tan(Psi) data and calculated
%                   tan(Psi) as function of the thickness of a layer:
%
%                     R = sqrt(mean((|rho|_exp - |rho|_calc).^2))
%
%                   The main use of this function is to find initial
%                   values for layer thickness determinations with
%                   function tf_ellip_fit.
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
% D :      a vector with the desired layer thicknesses
% didx :   the index of the layer that is varied
%
% Output:
% R :      (Optional) R(D), the degree of agreement between calculated 
%          and measured tan(Psi) as function of layer thickness. If 
%          present, the data are not plotted.

% initial version, Ulf Griesmann, December 2014

    % check arguments
    if nargin < 6
        error('tf_ellip_match: function requires six arguments.');
    end
    if length(lambda) ~= length(tanpsi)
        error('tf_ellip_match: length of lambda and tanpsi must be identical.');
    end
    if isrow(tanpsi), tanpsi = tanpsi'; end
    
    % some constants
    lwidth = 2;   % plot line width
    lfsize = 14;  % label/legend font size

    % film thicknesses in units of lambda
    d = zeros(length(S), length(lambda));
    for l = 1:length(lambda)  
        d(2:length(S)-1, l) = [S(2:length(S)-1).d] / lambda(l);
    end

    % refractive indices at wavelengths of interest
    nk = evalnk(S, lambda); 

    % calculate R
    R = zeros(size(D));
    for k = 1:length(D)
      
        d(didx,:) = D(k) ./ lambda;
        
        psi = zeros(length(lambda),1);
        for l = 1:length(lambda)
            psi(l) = tf_psi(d(:,l), nk(:,l), theta);
        end
        
        R(k) = sqrt(sum((tanpsi - tan(psi)).^2) / length(tanpsi));
       
    end
    
    % plot if no output argument
    if ~nargout
      
        plot(D, R, 'b', 'LineWidth',lwidth);
        grid on
        xlabel(sprintf('Thickness of layer %d / nm',didx), ...
               'FontSize',lfsize);
        ylabel('RMS(rhoexp - rhocalc)', 'FontSize',lfsize);
        
    end
    
end
