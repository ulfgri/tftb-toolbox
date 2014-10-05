function [R, T, A] = tf_rayfan_sub(fstack, bstack, lambda, theta, pol)
%function [R, T, A] = tf_rayfan_sub(fstack, bstack, lambda, theta, pol)
%
% tf_rayfan_sub :  calculates the response of a multilayer stack, 
%                  including substrate effects, for a range of
%                  angles of incidence.
%
% Input:
% fstack :  a structure array with a material stack definition
%              fstack(k).d :  layer thickness in um
%              fstack(k).n :  refractive index, function handle, or
%                             directly specified constant index
%           fstack(end).d is the substrate thickness (> coherence length)
% bstack :  a structure array that defines the material stack on
%           the back of the substrate. 
%           bstack(1).d is the substrate thickness, must be equal
%           to fstack(end).d
% lambda :  a fixed wavelength
% theta :   a vector with angles of incidence on the first layer 
%           interface in degrees.
% pol :     polarization; either 's', 'p', or 'u'. 
%           Default is 'u' - unpolarized.
%
% Output:
% R :       reflected intensity at input wavelengths
% T :       transmitted intensity at input wavelengths
% A :       absorbed intensity at input wavelengths
%
% Reference:
% + S. Larouche and L. Martinu, "OpenFilters: open-source software 
%   for the design, optimization, and synthesis of optical
%   filters", Appl. Opt. 47(13), C219-C230 (2008)

% Initial version, Ulf Griesmann, January 2014

% check input
if nargin < 5, pol = 'u'; end
if nargin < 4
   error('tf_rayfan_sub :  4 input arguments required.');
end
if ~isscalar(lambda)
   error('tf_rayfan :  wavelength must be a scalar.');
end

% pre-allocate arrays
R = zeros(size(theta));
T = zeros(size(theta));
A = zeros(size(theta));

% optical constants of front layers at wavelength
nkf = evalnk(fstack, lambda); 

% front layer thicknesses in wavelength units
df = zeros(1,length(fstack));
df(2:length(fstack)-1) = [fstack(2:length(fstack)-1).d] / lambda;

% optical constants of back layers at wavelength
nkb = evalnk(bstack, lambda); 

% back layer thicknesses in wavelength units
db = zeros(1,length(bstack));
db(2:length(bstack)-1) = [bstack(2:length(bstack)-1).d] / lambda;

% calculate intensities
for t = 1:length(theta)
    [R(t), T(t)] = tf_int_sub(df,nkf,db,nkb,theta(t),pol);
end

A = 1 - R - T;
         
return
