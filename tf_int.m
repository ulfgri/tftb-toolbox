function [R,T] = tf_int(d, nk, theta, pol)
%function [R,T] = tf_int(d, nk, theta, pol)
%
% tf_int :  calculates reflectances and transmittances 
%           from amplitudes
%
% Input:
% d :      layer thicknesses in units of wavelength
% nk :     layer indices
% theta :  angle of incidence on first interface in 
%          degrees
% pol :    polarization state, either 's', 'p', or 
%          'u' (unpolarized)
%
% Output:
% R : reflectance
% T : transmittance

% Initial version, Ulf Griesmann, October 2013

    % check arguments
    if nargin ~= 4
        error('tf_int :  4 input arguments required.');
    end

    % factors for transmitted waves
    alpha2 = (nk(1) * sin(pi*theta/180))^2; % Snell invariant
    if pol == 's' || pol == 'u'
       eta_in_s = sqrt(nk(1)^2 - alpha2);
       eta_ex_s = sqrt(nk(end)^2 - alpha2);
       tf_s = real(eta_ex_s)/real(eta_in_s);
    end
    if pol == 'p' || pol == 'u'
       eta_in_p = nk(1)^2 / sqrt(nk(1)^2 - alpha2);
       eta_ex_p = nk(end)^2 / sqrt(nk(end)^2 - alpha2);
       tf_p = real(eta_ex_p)/real(eta_in_p);
    end
    
    % calculate intensities
    switch pol
      
     case 'u'
         [r, t] = tf_ampl(d, nk, theta, 's');
         Rs = r*conj(r);
         Ts = tf_s * (t*conj(t));
      
         [r, t] = tf_ampl(d, nk, theta, 'p');
         Rp = r*conj(r);
         Tp = tf_p * (t*conj(t));
         
         R = 0.5 * (Rs + Rp);
         T = 0.5 * (Ts + Tp);
         
     case 's'
         [r, t] = tf_ampl(d, nk, theta, 's');
         R = r*conj(r);
         T = tf_s * (t*conj(t));
      
     case 'p'
         [r, t] = tf_ampl(d, nk, theta, 'p');
         R = r*conj(r);
         T = tf_p * (t*conj(t));
      
     otherwise
         error(sprintf('tf_int :  unknown polarization state: %s.',pol));
    end

end
