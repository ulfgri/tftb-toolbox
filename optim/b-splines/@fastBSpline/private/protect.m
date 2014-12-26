function x = protect(x)
    %Define 0/0 == 0
    x(isnan(x) | abs(x) == Inf) = 0;
end
