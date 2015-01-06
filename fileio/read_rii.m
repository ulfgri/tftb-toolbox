function [nk, lambda] = read_rii(name)
%function [nk, lambda] = read_rii(name)
% 
% read_litho :  read refractive index data from the rii collection.
%               The files all have the same format: the 1st column
%               is the wavelength in micrometer, the 2nd column is 
%               the index, and the third column the imaginary part
%               of the refractive index.

% read binary index file if present
bname = [name, 'b'];
if nkb_file_exists(bname)
  
   [nk, lambda] = read_nkb(bname);
   
else

   % pre-allocate arrays
   nall = 512;
   lambda = zeros(nall,1);
   nk = complex(zeros(nall,1),zeros(nall,1));

   % counter
   nval = 0;

   % open file
   fd = fopen(name, 'rt');
   if fd < 0
      error(sprintf('read_rii: failed to open file --> %s\n', name));
   end

   % read and scan lines
   while ~feof(fd)
     
      % read a line of text
      line = fgets(fd);
  
      % if not a comment, convert
      if line(1) ~= ';'
         nval = nval + 1;
         val = sscanf(line, '%f');
         lambda(nval) = val(1);
         nk(nval) = complex(val(2), -val(3));
      end
      
   end

   fclose(fd);

   lambda = lambda(1:nval);
   nk = nk(1:nval);

   % write binary file
   write_nkb(bname, lambda, nk);

end

return
