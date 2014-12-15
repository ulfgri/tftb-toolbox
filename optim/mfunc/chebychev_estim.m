function [vp] = chebychev_estim(vx,vy,vip,xdom)
% function [vp] = chebychev_estim(vx,vy,vip,xdom)
%
% chebychev_estim: Least squares estimation of a Chebychev polynomial
%                  of the first kind
%
% vx   : values independent variables
% vy   : values dependent variables
% vp   : values polynomial coefficients, padded with zeros (element i corresponds
%        to coefficient of term i-1)
% vip  : vector with the terms of the polynomial coefficients to be evaluated
%        (a value i corresponds to coefficient i-1)
% xdom : (optional, default [-1,1]) domain of x

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

  if nargin < 4, xdom = []; end

  if isempty(xdom), xdom = [-1,1]; end

  if length(vx(1,:)) > 1, vx = vx'; end
  if length(vy(1,:)) > 1, vy = vy'; end
  if length(vip(1,:)) > 1, vip = vip'; end

  vi = find(~isnan(vx) & ~isnan(vy));
  
  vp = [];
  
  if isempty(vi), return; end
  
% calculate regression matrix

  vp = zeros(max(vip),1);
  vp(vip,1) = 1;
  
  mX = chebychev_eval(vx(vi),vp,xdom,1);
  mX = mX(:,vip);
  
% solve

  vp = zeros(max(vip),1);
  vp(vip,1) = mX\vy(vi);

end
  