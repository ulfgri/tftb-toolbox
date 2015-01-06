function write_nkb(fname, lambda, nk)
%function write_nkb(fname, lambda, nk)
%
% write_nkb :  write a binary refractive index data file
%
% fname :  file name with extension .nkb
% lambda : vector with wavelengths
% nk :     complex vector with refractive index data

    % check file name and create file
    if ~strcmp(fname(end-3:end), '.nkb')
       error('write_nkb :  file name extension must be .nkb');
     end
     fd = fopen(fname, 'wb');

     % store data
     nval = length(lambda);
     fwrite(fd, nval, 'int32');
     fwrite(fd, lambda, 'single');
     fwrite(fd, real(nk), 'single');
     fwrite(fd, imag(nk), 'single');
     
     % close file
     fclose(fd);

end

