function spord = order(sp)
%function spord = order(sp)
%
% Returns the order of the spline sp

    spord = length(sp.knots)-length(sp.weights)-1;
    
end
