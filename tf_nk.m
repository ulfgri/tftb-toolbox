function [nk] = tf_nk(ri, wlen);
%function [nk] = tf_nk(ri, wlen);
%
% tf_nk :  calculate the complex refractive index at a set of
%          wavelengths either via interpolation from a table of indices,
%          or by evaluating a function describing the refractive index..
%
% Input:
% ri :       EITHER a refractive index table
%               ri.lambda : wavelength nodes in micrometer
%               ri.nk :     refractive index at wavelength nodes
%               ri.name :   name of material
%            OR a function handle
%            OR a constant refractive index
% wlen :     vector with wavelengths in um at which to calculate the index
%
% Output:
% nk :       vector of complex refractive indices at wavelengths wlen
%

% Initial version, Ulf Griesmann, February 2013

    % check arguments
    if nargin < 2
        error('tf_nk :  two input arguments required.');
    end

    if isstruct(ri)
      
        % check if wavelength 
        if any(wlen < ri.lambda(1)) || any(wlen > ri.lambda(end))
            if isfield(ri, 'name')
                name = ri.name;
            else
                name = 'unknown';
            end
            error( sprintf('tf_nk : wavelength(s) outside range of nk(lambda) for material ''%s''.', name) );
        end

        nk = complex(interp1(ri.lambda, real(ri.nk), wlen, 'pchip'), ...
                     interp1(ri.lambda, imag(ri.nk), wlen, 'pchip'));
        
    elseif isa(ri, 'function_handle')

        nk = ri(wlen);
        
    else
      
        if ~isscalar(ri)
            error('tf_nk: constant argument is not a scalar.');
        end
        nk = repmat(ri, size(wlen));
        
    end
    
end

