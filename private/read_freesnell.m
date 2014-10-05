function [nk, lambda] = read_freesnell(name);
%function [nk, lambda] = read_freesnell(name);
% 
% read_freesnell :  read refractive index data from the freesnell 
%      collection. Following a number of comment lines, the files 
%      contain a line in which the first token is the unit. The
%      first data column is either energy or wavelength followed 
%      by two colums with the real and imaginary part of the 
%      refractive index.

% read binary index file if present
bname = [name, 'b'];
if nkb_file_exists(bname)
  
   [nk, lambda] = read_nkb(bname);
   
else

   % pre-allocate arrays
   nall = 256;
   lambda = zeros(nall,1);
   nk = complex(zeros(nall,1),zeros(nall,1));

   % counter
   nval = 0;

   % open file
   fd = fopen(name, 'r');
   if fd < 0
      error(sprintf('read_freesnell: failed to open file --> %s\n', name));
   end

   % read comment lines
   while 1
      line = fgets(fd);
      if line(1) ~= ';'
         break
      end
   end

   % extract the unit
   unit = strtok(line);

   % read and scan lines
   while ~feof(fd)
  
      % read a line of text
      line = fgets(fd);
      val = sscanf(line, '%f');
      nval = nval + 1;
      lambda(nval) = val(1);
      nk(nval) = complex(val(2), -val(3));
  
   end

   fclose(fd);

   % cut arrays to size
   lambda = lambda(1:nval);
   nk = nk(1:nval);

   % convert to micrometer if necessary
   if strcmp(unit, 'eV')
      lambda = 1.23984187 ./ lambda;
      lambda = lambda(end:-1:1);
      nk = nk(end:-1:1);
   end

   % write binary file
   write_nkb(bname, lambda, nk);
   
end
   
return
