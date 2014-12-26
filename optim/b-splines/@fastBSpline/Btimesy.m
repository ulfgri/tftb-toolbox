function d = Btimesy(sp,x,y)
%function d = Btimesy(sp,x,y)
%
% Computes the product sp.getBasis(x)'*y.
%
% This product is frequently needed in fitting models; for 
% example, if E is an error function, r is the output of the 
% spline evaluated at x, and y = dE/dr, then the derivative 
% dE/dw is given by sp.Btimesy(x,y) by the chain rule. 
%
% This product can be computed efficiently in C without actually 
% forming the B matrix in memory. 
            
    %Sanity check
    x = x(:);
    y = y(:);
    if length(x) ~= length(y)
        error('length(x) and length(y) must be equal');
    end
    
    [~,thebins] = histc(x,sp.knots);
    firstknot = max(min(thebins-sp.order,length(sp.weights)),1);
    lastknot = min(thebins+1,length(sp.weights)+1);
    
    d = evalBinTimesY(x,firstknot,lastknot,sp.knots,sp.weights,sp.order,y);
        
end
