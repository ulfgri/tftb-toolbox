function sx = getBasis(sp,x)
%function sx = getBasis(sp,x)
%
% Get basis B sampled at points x

    x = x(:);
    if sp.outOfRange
        x = max(min(x,sp.knots(end)-1e-10),sp.knots(1)+1e-10);
    end
    spord = order(sp);
    [~,thebins] = histc(x,sp.knots);
    firstknot = max(min(thebins-spord,length(sp.weights)),1);
    lastknot = min(thebins+1,length(sp.weights)+1);

    sx = evalBin(x,firstknot,lastknot,sp.knots,sp.weights,spord);

end
