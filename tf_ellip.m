function [Psi, Delta] = tf_ellip(stack, lambda, theta, bunwrap)
%function [Psi, Delta] = tf_ellip(stack, lambda, theta, bunwrap)
%
% tf_ellip :  calculates the ellipsometric response of a 
%             multilayer stack  at the specified wavelengths.
%
% Input:
% stack :   a structure array with a material stack definition
%              stack(k).d :  layer thickness in um
%              stack(k).n :  refractive index table, function
%                            handle, or directly specified constant
%                            index
% lambda :  Sampling wavelengths
% theta :   the angle of incidence on the first layer interface in
%           degrees.
% bunwrap : (Optional) controls unwrapping of Psi, Delta
%           angles. When bunwrap ~= 0, angles will be
%           unwrapped. Default is 0 (no unwrapping). 
%
% Output:
% Psi :    Psi(lambda) in DEGREES
% Delta :  Delta(lambda) in DEGREES
%

% Initial version, Ulf Griesmann, October 2013

% check input
if nargin < 4, bunwrap = []; end
if nargin < 3
   error('tf_ellip :  three input arguments required.');
end
if isempty(bunwrap), bunwrap = 0; end;
if iscolumn(lambda), lambda = lambda'; end

% pre-allocate arrays
Psi = zeros(size(lambda));
Delta = zeros(size(lambda));

% compute all thicknesses in units of lambda
d = zeros(length(stack), length(lambda));
for l = 1:length(lambda)  
   d(2:length(stack)-1, l) = [stack(2:length(stack)-1).d] / lambda(l);
end

% compute all indices
nk = evalnk(stack, lambda); 

% calculate Psi, Delta for all lambda
for l = 1:length(lambda)
    [Psi(l), Delta(l)] = tf_psi(d(:,l), nk(:,l), theta);
end

% unwrap and convert to degrees
if bunwrap
   Psi   = unwrap(Psi);
   Delta = unwrap(Delta);
end
Psi   = 180 * Psi / pi;
Delta = 180 * Delta / pi;

return
