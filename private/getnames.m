function [can] = getnames(stack)
%function [can] = getnames(stack)
%
% getnames :  get all material names from a stack
%
% stack :  thin film material stack
% can :    cell array with material names

% Initial version, November 2013, Ulf Griesmann

can = cell(1,length(stack));

for k = 1:length(stack)
   rid = stack(k).n;
   if isa(rid, 'function_handle')
      can{k} = [func2str(rid), ' (function)'];;
   elseif isstruct(rid)
      if isfield(rid, 'name')
         can{k} = rid.name;
      else
         can{k} = 'undefined';
      end
   else
      can{k} = 'constant';
   end   
end

return
