function [] = checkNum(sp)
%function [] = checkNum(sp)
%
% Check whether number of weights is consistent with number of knots

    if length(sp.knots) <= length(sp.weights)
        error('length(knots) must be > than length(weights)');
    end

end
