function [boctave] = is_octave()
%
% check if we are running on Octave
%
boctave = (exist('OCTAVE_VERSION') == 5);
return
