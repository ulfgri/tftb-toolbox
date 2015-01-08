function spo = set(spi, varargin)
%function spo = set(spi, varargin)
%
% set B-Spline properties 'knots', 'weights',
% and 'outOfRange'
%
% set knots and weights of a B-Spline:
% sp = set(sp, 'knots',k, 'weights',w);

    if (length (varargin) < 2 || rem (length (varargin), 2) ~= 0)
        error ('fastBSpline.set :  expecting property/value pair(s).');
    end
    
    spo = spi;
    
    for idx = 1:2:length(varargin)

        % get string/value pair
        argstr = varargin{idx};
        argval = varargin{idx+1};
        
        switch argstr
          
         case 'knots'
             if ~issorted(argval)
                 error('knots must be non-decreasing.');
             end
             spo.knots = argval(:);
             spo.order = set_order(spo.knots,spo.weights);
             
         case 'weights'
             spo.weights = argval(:);
             spo.order = set_order(spo.knots,spo.weights);
             
         case 'outOfRange'
             spo.outOfRange = argval;
             if (spo.outOfRange ~= 0) && (spo.outOfRange ~= 1)
                 error('fastBSpline.set: outOfRange must be 0 or 1.');
             end
             
         otherwise
             error('unknown b-spline property.');
             
        end
    end

    % check spline consistency
    checkNum(spi);
    
end


function spord = set_order(knots,weights)
%
% calculate spline order
%
    if length(knots) <= length(weights)
        error('fastBSpline.set: #knots must be > #weights.');
    end
    spord = length(knots)-length(weights)-1;

end
