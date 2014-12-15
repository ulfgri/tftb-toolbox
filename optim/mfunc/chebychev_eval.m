function [mval] = chebychev_eval(vx,vp,xdom,bcom)
%function [mval] = chebychev_eval(vx,vp,xdom,bcom)
%
% chebychev_eval: value of a Chebychev polynomial of the first kind
%                 or its terms Ti(x)
%
% mval : value of the polynomial or its components (one column per term,
%        starting with term 0)
% vx   : values independent variables
% vp   : values polynomial coefficients (element i corresponds to coefficient
%        of term i-1)
% xdom : (optional) domain of x. Default is [-1,1].
% bcom : (optional) if > 0, return values of polynomial terms instead of sum
%        of all terms. Default is 0.

% This software was developed at the National Institute of Standards and Technology
% by employees of the Federal Government in the course of their official duties.
% Pursuant to title 17 Section 105 of the United States Code this software is not
% subject to copyright protection and is in the public domain. This software is an
% experimental system. NIST assumes no responsibility whatsoever for its use by other
% parties, and makes no guarantees, expressed or implied, about its quality, reliability,
% or any other characteristic.
%  
% This software can be redistributed and/or modified freely provided that any derivative
% works bear some notice that they are derived from it, and any modified versions bear
% some notice that they have been modified.
%
% We would appreciate acknowledgement if the software is used.
%
% Version: 1.0
% Author: Johannes Soons; NIST; Apr 2003 
% Review: Johannes Soons; NIST; May 2006 
% Status: OK
% ---------------------------------------------------------

  if nargin < 4, bcom = []; end
  if nargin < 3, xdom = []; end

  if isempty(bcom), bcom = 0; end
  if isempty(xdom), xdom = [-1,1]; end
  
  if isempty(vx), return; end
  if isempty(vp), return; end

  if length(vx(1,:)) > 1, vx = vx'; end
  if length(vp(1,:)) > 1, vp = vp'; end
  
  np = length(vp);  
  
% scale independent variable 

  vx = -1+(vx-xdom(1))*2/(xdom(2)-xdom(1));

% generate first two terms

  mval(:,1) = ones(length(vx),1);
  
  if np > 1
    mval(:,2) = vx;
%  
%   use recurrence relation to calculate other terms
%
%   Tn(x) = 2*x*Tn-1(x)-Tn-2(x)

    for i = 3:np
      mval(:,i) = 2*vx.*mval(:,i-1)-mval(:,i-2);
    end
  end
  
% return result

  mval = bsxfun(@times,mval,vp');
  
  if bcom == 0 
    mval = sum(mval,2); 
  end

end
