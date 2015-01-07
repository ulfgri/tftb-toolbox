function [flds] = str_flds(str)
%function [flds] = str_flds(str)
%
% str_flds : takes a string argument and returns all white
%            space delimited substrings (fields) of the string as
%            a cell array of strings.
%
% str   :     input string
% flds  :     cell array of substrings

% Version: 1.0
% Author: Ulf Griesmann; NIST; Aug 2002
% Review: Ulf Griesmann; NIST; Aug 2002
% Status: OK

    flds = {};

    % remove trailing and leading blanks
    rem = str_deb(str);

    % retrieve all tokens from the string
    while ~isempty(rem)
        [tok,rem] = strtok(rem);
        flds{end+1} = tok;
    end
    
end
