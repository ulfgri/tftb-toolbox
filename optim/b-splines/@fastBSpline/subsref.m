function prop = subsref(sp, ins);
%function prop = subsref(sp, ins);
%
% subscript reference method for the fastBSpline class
% This method allows class properties to be addressed using
% structure field name indexing.
%
% sp :     a fastBSpline object
% ins :    an array index reference structure
% prop :   the index property

% Ulf Griesmann, NIST, December 2014

    switch ins.type
 
     case '.'
  
         switch ins.subs       
          case {'knots','weights','order','outOfRange'}
              prop = sp.(ins.subs);
          otherwise
              error('fastBSpline.subsref: unknown property.');
         end
     
     otherwise
         error('fastBSpline.subsref :  invalid indexing type.');
    
    end
end