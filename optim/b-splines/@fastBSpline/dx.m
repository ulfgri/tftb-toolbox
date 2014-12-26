function dsp = dx(sp)
%function dsp = dx(sp)
%
% dx :  derivative of a B-Spline
%
% Given a spline sp, dsp is another fastBSpline object such that 
% dsp(x) is the derivative of sp evaluated at x

    weights = [0;sp.weights;0];
    knots   = sp.knots([1,1:end,end]');
    spord   = length(knots)-length(weights)-1;

    wp = protect(spord*diff(weights) ./ ...
                 (knots(spord + (2:length(weights)))-knots((2:length(weights)))));
    
    dsp = fastBSpline(knots(2:end-1),wp);

end
