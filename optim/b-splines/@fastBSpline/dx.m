function dsp = dx(sp)
%function dsp = dx(sp)
%
% dx :  derivative of a B-Spline
%
% Given a spline sp, dsp is another fastBSpline object such that 
% dsp(x) is the derivative of sp evaluated at x

    sp.weights = [0;sp.weights;0];
    sp.knots = sp.knots([1,1:end,end]');
    wp = protect(sp.order*diff(sp.weights) ./ ...
                 (sp.knots(sp.order + (2:length(sp.weights)))-sp.knots((2:length(sp.weights)))));
    dsp = fastBSpline(sp.knots(2:end-1),wp);

end
