function spelm = fastBSpline(knots, weights)
%function spelm = fastBSpline(knots, weights)
%
% Constructor for the fastBSpline class, a fast, lightweight class
% that implements non-uniform B splines of any order.
%
% The fastBSpline class implements a lightweight set of B-spline
% features, including evaluation, differentiation, and parameter fitting. 
% The hard work is done by C code, resulting in up to 10x acceleration
% for evaluating splines and up to 50x acceleration when evaluating 
% of spline derivatives. 
%
% Nevertheless, fastBSplines are manipulated using an intuitive, high-
% level object-oriented interface, thus allowing C-level performance 
% without the messiness. 
%
% B splines are defined in terms of basis functions:
%
%    y(x) = sum_i B_i(x,knots)*weights_i
%
% B (the basis) is defined in terms of knots, a non-decreasing sequence 
% of values. Each basis function is a piecewise polynomial of order
% length(knots)-length(weights)-1. The most commonly used B-spline is
% the cubic B-spline. In that case there are 4 more knots than there
% are weights. Another commonly used B-spline is the linear B-spline,
% whose basis function are shaped like tents, and whose application
% results in piecewise linear interpolation. 
%
% The class offers two static functions to fit the weights of a spline: 
% lsqspline and pspline. It includes facilities for computing the basis 
% B and the derivatives of the spline at all points.
%
% Constructor:
%
% sp = fastBSpline(knots,weights);
%
% Example use:
%
% Fit a noisy measurement with a smoothness-penalized spline (p-spline)
%  x = (0:.5:10)';
%  y = sin(x*pi*.41-.9)+randn(size(x))*.2;
%  knots = [0,0,0,0:.5:10,10,10,10]; 
% Notice there are as many knots as observations
% 
% Because there are so many knots, this is an exact interpolant
%  sp1 = fastBSpline.lsqspline(knots,3,x,y);
% Fit penalized on the smoothness of the spline
%  sp2 = fastBSpline.pspline(knots,3,x,y,.7);
% 
% clf;
% rg = -2:.005:12;
% plot(x,y,'o',rg,sp1.evalAt(rg),rg,sp2.evalAt(rg));
% legend('measured','interpolant','smoothed');
% 
% fastBSpline properties:
%  outOfRange - Determines how the spline is extrapolated outside the
%               range of the knots
%               0 :  set to 0
%               1 :  constant (this is the default)
%  knots      - The knots of the spline
%  weights    - The weights of the spline
%
% fastBSpline Methods:
%  fastBSpline - Construct a B spline from weights at the knots
%  lsqspline   - Construct a least-squares spline from noisy measurements
%  pspline     - Construct a smoothness-penalized spline from noisy
%                measurements
%  evalAt      - Evaluate a spline at the given points
%  getBasis    - Get the values of the underlying basis at the given points
%  Btimesy     - Evaluate the product getBasis(x)'*y
%  dx          - Returns another fastBSpline object which computes the derivative of
%                the original spline
%
% Disclaimer: fastBSpline is not meant to replace Matlab's spline functions; 
%             it does not include any code from the Mathworks

    % check arguments
    if nargin < 2
        error('two input arguments are required.');
    end
    
    % initialize properties
    sp.knots = knots;
    sp.weights = weights;
    sp.outOfRange = 1;

    % create fastSPline object
    spelm = class(sp, 'fastBSpline');
    
end
    
  