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
             
         case 'weights'
             spo.weights = argval(:);
             
         case 'outOfRange'
             spo.outOfRange = argval;
             
         otherwise
             error('unknown b-spline property.');
             
        end
    end

    % check spline consistency
    checkNum(spi);
    
end
