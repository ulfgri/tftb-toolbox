function [nk, lambda] = read_nkb(fname)
%function [nk, lambda] = read_nkb(fname)
%
% read_nkb :  read a binary refractive index data file
%
% fname :  file name with file extension .nkb
% nk :     complex refractive index
% lambda : wavelength in um

    % open file
    fd = fopen(fname, 'rb');

    % read number of wavelengths and index values
    nval = fread(fd, 1, 'int32');
    
    % read data
    lambda = fread(fd, nval, 'single');
    n = fread(fd, nval, 'single');
    k = fread(fd, nval, 'single');

    % close file
    fclose(fd);

    nk = complex(n,k);

end
