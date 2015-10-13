function [eta_in,eta_ex] = eta_sp(nk, theta, pol)
%function [eta_in,eta_ex] = eta_sp(nk, theta, pol)
%
% eta_sp: calulate pseudo-indices for the input
%         and exit spaces of a thin film stack
%
% INPUT
% nk :     layer refractive indices
% theta :  angle of incidence on first interface in 
%          degrees
% pol :    polarization state, either 's', 'p', or 
%          'u' (unpolarized)
%
% OUTPUT
% eta_in : pseudo-index of the input space
% eta_ex : pseudo_index of the exit space

    alpha2 = (nk(1) * sin(pi*theta/180))^2; % Snell invariant

    if pol == 's'
       eta_in = sqrt(nk(1)^2 - alpha2);
       eta_ex = sqrt(nk(end)^2 - alpha2);

    elseif pol == 'p'
       eta_in = nk(1)^2 / sqrt(nk(1)^2 - alpha2);
       eta_ex = nk(end)^2 / sqrt(nk(end)^2 - alpha2);
       
    else
       error(sprintf('eta_sp : unknown polarization state: %s.',pol));
    end
    
end

