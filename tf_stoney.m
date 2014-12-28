function [s, us] = tf_stoney(Es, nus, ds, df, K, unc)
%function [s, us] = tf_stoney(Es, nus, ds, df, K, unc)
%
% tf_stoney :  calculates the stress, and its uncertainty, in a 
%              thin film coated on a substrate using Stoney's 
%              formula:
%
%                      Es * ds^2
%              s = ------------------ * K
%                  6 * df * (1 - nus)
%
% Input:
% Es :   Young's modulus of the substrate material in 
%        Pa (N/m^2).
% nus :  Poisson's ratio of the substrate material.
% ds :   thickness of the substrate material in m.
% df :   thickness of the film in m.
% K :    curvature (1/R) of the coated substrate in m^-1
% unc :  (Optional) a structure with uncertainties of the
%        input arguments:
%             unc.Es  : uncertainty of Es
%             unc.nus : uncertainty of nus
%             unc.ds  : uncertainty of ds
%             unc.df  : uncertainty of df
%             unc.K   : uncertainty of K
%
% Output:
% s :    thin film stress in N / m^2
% us :   uncertainty of the film stress if 'unc' was supplied.
%
% NOTE: Stoney's formula is only valid if df << ds << 1/K; film and
% substrate are homogenous, isotropic, and linearly elastic; principal
% curvatures are equal; stresses and curvatures are constant over
% the plate. Caveat emptor ...

% Initial version, Ulf Griesmann, November 15, 2013

    % check arguments
    if nargin < 6, unc = []; end
    if nargin < 5
       error('missing argument(s).');
    end

    if ~isempty(unc)
       if ~isfield(unc, 'Es'),  unc.Es = 0; end
       if ~isfield(unc, 'nus'), unc.nus = 0; end
       if ~isfield(unc, 'ds'),  unc.ds = 0; end
       if ~isfield(unc, 'df'),  unc.df = 0; end
       if ~isfield(unc, 'K'),   unc.K = 0; end
    end

    % calculate stress
    s = Es * ds^2 * K / (6 * df * (1-nus));

    % and its uncertainty (Gauss' formula)
    if isempty(unc)
       us = 0;
    else
       us = sqrt((ds^2 * K / (6 * df * (1-nus)))^2 * unc.Es^2 + ...
                 (2 * Es * ds * K / (6 * df * (1-nus)))^2 * unc.ds^2 + ...
                 (Es * ds^2 / (6 * df * (1-nus)))^2 * unc.K^2 + ...
                 (Es * ds^2 * K / (6 * df^2 * (1-nus)))^2 * unc.df^2 + ...
                 (Es * ds^2 * K / (6 * df * (1-nus)^2))^2 * unc.nus^2);
    end

end
