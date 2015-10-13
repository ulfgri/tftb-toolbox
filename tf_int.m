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

    % calculate intensities
    switch pol
      
     case 'u'
         [r, t] = tf_ampl(d, nk, theta, 's');
         Rs = r*conj(r);
         [eta_in,eta_ex] = eta_sp(nk, theta, 's');
         Ts = real(eta_ex) * (t*conj(t)) / real(eta_in);
      
         [r, t] = tf_ampl(d, nk, theta, 'p');
         Rp = r*conj(r);
         [eta_in,eta_ex] = eta_sp(nk, theta, 'p');
         Tp = real(eta_ex) * (t*conj(t)) / real(eta_in);
         
         R = 0.5 * (Rs + Rp);
         T = 0.5 * (Ts + Tp);
         
     case 's'
         [r, t] = tf_ampl(d, nk, theta, 's');
         R = r*conj(r);
         [eta_in,eta_ex] = eta_sp(nk, theta, 's');
         T = real(eta_ex) * (t*conj(t)) / real(eta_in);
      
     case 'p'
         [r, t] = tf_ampl(d, nk, theta, 'p');
         R = r*conj(r);
         [eta_in,eta_ex] = eta_sp(nk, theta, 'p');
         T = real(eta_ex) * (t*conj(t)) / real(eta_in);
      
     otherwise
         error(sprintf('tf_int :  unknown polarization state: %s.',pol));
    end

end
