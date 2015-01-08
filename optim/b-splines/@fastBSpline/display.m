function display(sp)
%function display(sp)
%
% display method for the fastBSpline class
%

    % print variable name
    fprintf('%s = \n\n', inputname(1));

    % print class variables
    fprintf('order   :  %d\n', sp.order);
    fprintf('knots   :  %d\n', length(sp.knots));
    fprintf('weights :  %d\n', length(sp.weights));
    switch sp.outOfRange
     case 0
         fprintf('ZERO outside range\n\n');
     case 1
         fprintf('CONST outside range\n\n');
     otherwise
         error('fastBSpline: invalid value for outOfRange.');
    end
    
end