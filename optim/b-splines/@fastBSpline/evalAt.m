function spx = evalAt(sp,x)
%function spx = evalAt(sp,x)
%
% evaluate spline at x
%
% spx = evalAt(sp,x) - Evaluate the spline at x
% x can be a vector or N-D matrix. size(Sx) == size(x)
   
    sz = size(x);
    x = x(:);
    
    spord = order(sp);
    if sp.outOfRange
        x = max(min(x,sp.knots(end)-1e-10),sp.knots(1)+1e-10);
    end
    
    [~,thebins] = histc(x,sp.knots);
    firstknot = max(min(thebins-spord,length(sp.weights)),1);
    lastknot = min(thebins+1,length(sp.weights)+1);

    spx = evalBSpline(x,firstknot,lastknot,sp.knots,sp.weights,spord);
    spx = reshape(spx,sz);

end
