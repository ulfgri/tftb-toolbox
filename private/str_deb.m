function [s] = str_deb(s)
% function [s] = str_deb(s)
%
% str_deb: Remove trailing and leading blanks

% Version 1.0
% Author: Johannes Soons; NIST; Dec 2001 
% Review: Johannes Soons; NIST; Feb 2011 
% Status: OK

    s = deblank(s(end:-1:1));  % strip leading blanks
    s = deblank(s(end:-1:1));  % strip trailing blanks
 
end
    
