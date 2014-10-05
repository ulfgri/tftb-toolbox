function [mlist] = tf_searchnk(collection, lambda, N, K, verbose)
%function [mlist] = tf_searchnk(collection, lambda, N, K, verbose)
%
% tf_searchnk :  search through a collection of refractive
%                index spectra and find materials matching
%                the specified refractive index.
%
% Input:
% collection :  a string with the name of a collection (directory)
%               of refractive index data, or a cell array with the
%               names of collections to be searched. 
% lambda :      vector with wavelengths in um.
% N :           (Optional) 1x2 vector with the range of the
%               refractive index n. The function searches for
%               indices N(1) < n < N(2). If [], any index is matched.
% K :           (Optional) 1x2 vector specifying a range for the 
%               extinction coefficient k (K(1) < k < K(2)). If
%               omitted or [], any extinction coefficient is matched.
% verbose :     (Optional) sets the verbosity of the output
%                 == 0 :  only matching material names are displayed.
%                 == 1 :  matching material names are displayed and
%                         n, k at the search wavelengths. (default)
%                 == 2 :  as in 1, but also displays warnings when
%                         the wavelength is out of range for a material.
% Output:
% mlist :       a cell array with names of materials with matching
%               index.

% Initial version, November 2013, Ulf Griesmann

% check arguments
if nargin < 5, verbose = 1; end
if nargin < 4, K = []; end
if nargin < 3
    error('at least 3 input arguments required.');
end

if isempty(N) && isempty(K)
   error('tf_searchnk: N and K cannot both be empty matrices.');
end
if isempty(N), N = [0,Inf]; end
if isempty(K), K = [0,Inf]; end
if isrow(lambda), lambda = lambda'; end
if ischar(collection), collection = {collection}; end
if length(N) ~= 2
   error('tf_searchnk: argument N must have length 2.');
end
if length(K) ~= 2
   error('tf_searchnk: argument K must have length 2.');
end

% store current directory
cdir = pwd();

% go to collection
for c = 1:length(collection)
  
   nk_dir = [tf_rootdir(), 'nk/', collection{c}];
   cd(nk_dir);

   % check if table or function collection
   if strcmp(collection{c}, 'analytic')
  
      nk_nam = dir('*.m');
      nk_nam = {nk_nam.name};
      nk_nam = cellfun(@(x)x(1:end-2), nk_nam, 'UniformOutput',0);
   
   else

      % create file list and check them
      nk_nam = dir('*.nk');
      nk_nam = {nk_nam.name};
      nk_nam = cellfun(@(x)x(1:end-3), nk_nam, 'UniformOutput',0);

   end

   % back to original directory
   cd(cdir);
   
   % search through files
   search_collection(collection{c}, nk_nam, lambda, N, K, verbose);
   
end

return

% 
% search through all files in collection
%
function search_collection(collection, nk_nam, lambda, N, K, verbose)

fprintf('\n   >>> Searching collection --> %s\n\n', collection);

mlist = {};

for n = 1:length(nk_nam)

   % calculate indices at wavelengths
   if strcmp(collection, 'analytic')
      mfun = str2func(nk_nam{n});
      nk = mfun(lambda);
   else
      ri = tf_readnk(nk_nam{n}, collection);
      try
         nk = tf_nk(ri, lambda);
      catch
         if verbose == 2
            fprintf('   wavelength(s) out of range for: %s\n\n', nk_nam{n});
         end
         continue
      end
   end
   if isrow(nk), nk = nk'; end

   % find matching indices
   idxn =  real(nk) >= N(1) &  real(nk) <= N(2);
   idxk = -imag(nk) >= K(1) & -imag(nk) <= K(2);
   idx = idxn & idxk;
   if ~any(idx)
       continue
   end
   
   % display matches
   mlist{end+1} = nk_nam{n};
   fprintf('   %s\n', nk_nam{n});
   if verbose
      fprintf('      %8.4f :  %7.4f %gi \n', ...
              [lambda(idx), real(nk(idx)), imag(nk(idx))]');
   end
   fprintf('\n');
end

fprintf('   Searched %d materials from collection ''%s'' (%d matches)\n\n', ...
        length(nk_nam), collection, length(mlist));

return
