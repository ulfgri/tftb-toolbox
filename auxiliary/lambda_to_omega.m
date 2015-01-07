function omega = lambda_to_omega(lambda)
%function omega = lambda_to_omega(lambda)
%
% lambda_to_omega: converts a vector of wavelengths in micrometer
%                  into angular frequencies in rad/s^-1
%
% Input:
% lambda :  vector with wavelengths in micrometer
%
% Output:
% omega :   vector with angular frequencies

% Ulf Griesmann, December 2104

   omega = 2*pi * sol() ./ lambda;

end
