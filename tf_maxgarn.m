function [reff] = tf_maxgarn(lambda, rmat, rinc, q)
%function [reff] = tf_maxgarn(lambda, rmat, rinc, q)
%
% tf_maxgarn : calculates the effective refractive index of an
%              isotropic granular composite material consisting of
%              metal inclusions in a dielectric matrix, which can be
%              described with the Maxwell Garnet effective medium
%              model.
%
% Input:
% lambda :  vector with wavelengths at which the effective 
%           refractive index is calculated
% rmat :    a refractive index structure, a function handle, or a
%           constant with the refractive index of the matrix
%           material.
% rinc :    a refractive index structure, a function handle, or a
%           constant with the refractive index of the metallic
%           inclusion.
% q :       parameter describing the admixture of metallic
%           inclusions as fraction of volume; 0 <= q <= 1; 
%           q==0 means glass matrix only 
%
% Output:
% reff :    refractive index structure with the effective index.
%
% References:
% + J. C. Maxwell Garnett, “Colours in Metal Glasses and in Metallic
%   Films”, Phil. Trans. Roy. Soc. London 203A, 385 (1904).
% + O. S. Heavens, "Optical Properties of Solids", 
%   Dover Publications, Mineola, NY, 1991

% Initial version, Ulf Griesmann, November 2013

% check arguments
if nargin < 4
    error('tf_maxgarn: missing input arguments.');
end

% indices of matrix and inclusion at wavelengths
if isstruct(rmat)
   nkm = tf_nk(rmat, lambda);
   mnam = rmat.name;
elseif isa(rmat, 'function_handle')
   nkm = rmat(lambda);
   mnam = func2str(rmat);
else
   nkm = rmat;
   mnam = 'constant';
end

if isstruct(rinc)
   nki = tf_nk(rinc, lambda);
   inam = rinc.name;
elseif isa(rinc, 'function_handle')
   nki = rinc(lambda);
   inam = func2str(rinc);
else
   nki = rinc;
   inam = 'constant';
end

% structure for effective index
reff.nk = conj(sqrt( nkm.^2 .* (nki.^2 + 2*nkm.^2 + 2*q*(nkm.^2 - nki.^2)) ./ ...
                               (nki.^2 + 2*nkm.^2 +   q*(nki.^2 - nkm.^2)) ) );
reff.lambda = lambda;
reff.name = sprintf('%s+%s\n(q=%f)', mnam, inam, q);

return
