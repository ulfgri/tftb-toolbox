function [copts, lmov] = lm_opts_check(opts)
%function [copts, lmov] = lm_opts_check(opts)
%
% Checks structure with options for levmar and fills in
% missing parameters with default values.
%
% copts :  completed structure with options
%   copts.init_mu :      initial mu scale factor
%   copts.thresh_grad :  threshold for |gradient|
%   copts.thresh_step :  threshold for step size
%   copts.thresh_res :   threshold for |residuum|
%   copts.diff_delta :   step size for jacobian calculation
%   copts.dscl :         gradient scaling factor
%
% lmov :  vector with options for levmar

% Ulf Griesmann, December 2013

% constants
C_MU = 1e-6;
T_STEP = 1e-9;
T_GRAD = 10*eps;
T_RES = 1e-9;
D_DELTA = 5e-7;
C_DSCL = 0.1; 

% options structure
if isempty(opts)
   copts.init_mu = C_MU;       % initial mu scale factor
   copts.thresh_step = T_STEP; % threshold for step size
   copts.thresh_grad = T_GRAD; % threshold for |gradient|
   copts.thresh_res = T_RES;   % threshold for |residuum|
   copts.diff_delta = D_DELTA; % step size for jacobian calculation
   copts.dscl = C_DSCL;        % gradient scaling factor
   copts.method = 'unc';       % minimization method
else
   copts = opts;
   if ~isfield(copts, 'init_mu'),     copts.init_mu = C_MU; end
   if ~isfield(copts, 'thresh_step'), copts.thresh_step = T_STEP; end
   if ~isfield(copts, 'thresh_grad'), copts.thresh_grad = T_GRAD; end
   if ~isfield(copts, 'thresh_res'),  copts.thresh_res = T_RES; end
   if ~isfield(copts, 'diff_delta'),  copts.diff_delta = D_DELTA; end
   if ~isfield(copts, 'dscl'),        copts.dscl = C_DSCL; end
   if ~isfield(copts, 'method'),      copts.method = 'unc'; end
end

% options vector
lmov = [C_MU, T_GRAD, T_STEP, T_RES, D_DELTA];

return
