function sp = pspline(knots,order,xi,yi,lambda)
%function sp = pspline(knots,order,xi,yi,lambda)
%
% Like lsqspline but with a smoothness penalty of strength lambda 
% on the weights of the spline. Returns a fastBSpline object.
% 
% Requires SuiteSparse on Octave 

    xi = xi(:);
    yi = yi(:);
    sp = fastBSpline(knots,ones(length(knots)-order-1,1));
    sp = set(sp, 'outOfRange',1);
    
    B = getBasis(sp,xi);
    e = ones(size(B,2),1);
    D = spdiags([-e 2*e -e], -1:1, size(B,2), size(B,2));
    w = [B;lambda*D]\[yi;zeros(size(B,2),1)];
    sp = fastBSpline(knots,w);
    sp = set(sp, 'outOfRange',1);

end
