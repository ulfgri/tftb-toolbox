function [ri] = tf_readnk(material, collection);
%function [ri] = tf_readnk(material, collection);
%
% tf_readnk :  read refractive index data and return them
%              as a function of wavelength in micrometer
%
% Input:
% material :    name of the material; must correspond to a
%               file with name '<material>' and extension .nk 
%               in one of the material collections. E.g. 'sio2' 
% collection :  name of a material collection, a subdirectory of 
%               database root directory.
%
% Output:
% ri :          a structure with the refractive index sampled
%               at a set of discrete wavelengths
%                 ri.lambda : wavelength nodes in micrometers
%                 ri.nk :     the complex refractive index at
%                             the wavelength nodes
%                 ri.name :   a string with the name of the
%                             material and the name of the 
%                             collection.
%

% Initial version, Ulf Griesmann, February 2013

% check arguments
if nargin < 2
   error('tf_readnk :  must have two arguments.');
end

% collection specific read function for nk data
read_nk_func = str2func(['read_', collection]);

% call read function
nk_name = [tf_rootdir(),'nk/',collection,'/',material,'.nk'];
[ri.nk, ri.lambda] = read_nk_func(nk_name);
ri.name = sprintf('%s (%s)', material, collection);

return
