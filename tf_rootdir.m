function [rdir] = tf_rootdir;
%function [rdir] = tf_rootdir;
%
% tf_rootdir :  return the root directory of the thin film toolbox
%               

persistent tf_root;

if isempty(tf_root)
  
   ffn = which('tf_rootdir.m');
   if isempty(ffn)
      error('tf_rootdir: could not locate file tf_rootdir.m in search path');
   end
   tf_root = ffn(1:end-12);
   
end
  
rdir = tf_root;

return
