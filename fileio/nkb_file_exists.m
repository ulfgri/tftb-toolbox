function [ex] = nkb_file_exists(fname)
%
% checks if a binary refractive index file exists
%

    fd = fopen(fname, 'r');

    if fd == -1
        ex =  0;
    else
        fclose(fd);
        ex =  1;
    end

end
