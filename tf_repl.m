function ostack = tf_repl(istack, nrep)
%function ostack = tf_repl(istack, nrep)
%
% tf_repl :  assists with building multilayer structures that
%            contain repeated layer sequences, e.g. (HL)^n structures.
%
% Input:
% istack :  a structure array with a material stack definition
%              istack(k).d :  layer thickness in um
%              istack(k).n :  index structure or function handle
% nrep :    number of repetitions
%
% Output:
% ostack :  a row structure array with a repeated material stack 
%

% Initial version, Ulf Griesmann, February 2013

% check arguments
if nargin < 2
   error('tf_repl :  two input arguments required.');
end
if iscolumn(istack), istack = istack'; end

% copy input stack
ostack = [];
for k = 1:nrep
   ostack = [ostack, istack];
end

return
