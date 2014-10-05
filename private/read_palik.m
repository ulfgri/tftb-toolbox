function [nk, lambda] = read_palik(name);
%function [nk, lambda] = read_palik(name);
% 
% read_palik :  read refractive index data from the palik
%               collection. 

% read binary index file if present
bname = [name, 'b'];
if nkb_file_exists(bname)
  
   [nk, lambda] = read_nkb(bname);
   
else

   % pre-allocate arrays
   nall = 2048;
   lambda = zeros(nall,1);
   n = zeros(nall,1);
   k = zeros(nall,1);

   % counter
   nval = 0;

   % open file
   fd = fopen(name, 'r');
   if fd < 0
      error(sprintf('read_palik: failed to open file --> %s\n', name));
   end

   % read all lines up to column number
   while 1
      lin = fgets(fd);
      if lin(1:2) == ';N';
         break;
      end
   end

   % read number of columns in file
   flds = string_to_cells(lin);
   ncol = str2num(flds{2});

   % read and discard last comment line
   lin = fgets(fd);

   % read and scan lines with data
   while ~feof(fd)
  
      % read a line of text
      lin = fgets(fd);
      
      % convert
      nval = nval + 1;
      val = sscanf(lin, '%f');
  
      % use eV in 1st colum to calculate wavelength
      lambda(nval) = 1.23984187 / val(1);  % eV --> um
  
      % index from n,k columns
      n(nval) = val(4);
      k(nval) = val(5);
      
   end

   fclose(fd);

   % truncate arrays to needed size
   lambda = lambda(1:nval);
   n = n(1:nval);
   k = k(1:nval);

   % replace missing data with NaN
   n(n==-0.0001) = NaN;
   n(n==-0.0)    = NaN;
   k(k==-0.0001) = NaN;

   % complex index
   nk = complex(n, -k);

   % write binary file
   write_nkb(bname, lambda, nk);

end

return

function [flds] = string_to_cells(str)
%function [flds] = string_to_cells(str)
%
% string_to_cell : takes a string argument and returns all white
%     space delimited substrings (fields) of the string as a cell 
%     array of strings.
%
% str   :     input string
% flds  :     cell array of substrings

flds = {};

while ~isempty(str),
   [tok,str] = strtok(str);
   flds{end+1} = tok;
end

return