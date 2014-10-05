function [ar] = make_arc(xa, xb, C, ns);
%function [ar] = make_arc(xa, xb, C, ns);
%
% generate an arc between two cartesian points
%
% xa :  start point (Cartesian coordinates)
% xb :  end point (Cartesian coordinates)
% C  :  center of arc
% ns :  number of segments
% ar :  ns+1 x 2 matrix of vertex points on the arc
%

    % transform points to polar coordinates
    xsa = xa - C;
    [aa,r] = cart2pol(xsa(1), xsa(2));
    if aa < 0
        aa = aa + 2*pi;
    end
    xsb = xb - C;
    [ab,r] = cart2pol(xsb(1), xsb(2));
    if ab < 0
        ab = ab + 2*pi;
    end

    % generate vertices in polar coord and transform back
    if ab == aa
        da = 2*pi / ns;
        A = (aa:da:aa+2*pi)';
    else
        da = (ab - aa) / ns;
        A = (aa:da:ab)';
    end
    R = r * ones(ns+1,1);
    [x,y] = pol2cart(A,R);

    % shift back
    ar = bsxfun(@plus, [x,y], C);

end
