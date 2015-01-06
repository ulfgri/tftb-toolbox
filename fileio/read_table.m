function [mdat] = read_table(fname)
% function [mdat] = read_table(fname)
%
% read_table: Read tabulated data from an ascii text file.  The data is assumed
%             to be organized into columns with preceding or intermediate comment
%             lines.  Empty lines and lines beginning with a comment character
%             (';') are ignored. 
%
% fname  : file name
% mdat   : matrix with numerical data

[fid,message] = fopen(fname,'rt');
if fid < 0 
   error([' Cannot open file ',fname,' (',message,')']); 
end

mdat = [];

while ~feof(fid),
   sline = fgetl(fid);
   if ~isempty(sline),
      if sline(1) ~= ';'
          mdat = [mdat; sscanf(sline,'%f')'];
      end
   end
end
fclose(fid);

return
