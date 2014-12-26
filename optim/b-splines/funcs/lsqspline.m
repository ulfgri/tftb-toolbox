function sp = lsqspline(knots,spord,xi,yi)
%function sp = lsqspline(knots,spord,xi,yi)
%
% Fit the weights of the spline with given knots and order based 
% on a least-squares fit of the data yi corresponding to xi.
% Returns a fastBSpline object.

    xi = xi(:);
    yi = yi(:);
    sp = fastBSpline(knots,ones(length(knots)-spord-1,1));
    sp = set(sp, 'outOfRange',1);

    B = getBasis(sp,xi);
    w = B\yi;
    sp = fastBSpline(knots,w);
    sp = set(sp, 'outOfRange',1);

end
