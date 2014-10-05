function copts  = de_opts_check(opts, d0)
%function copts  = de_opts_check(opts, d0)
%
% Checks structure with options for devec3 and fills in
% missing parameters with default values.
%
% copts :  completed opts structure with options
%    copts.xv :      length(didx) x 2 matrix with lower and
%                    upper limits for initial population.
%                    Default is [0,1] for each layer.
%    copts.np :      number of population members; default
%                    is 50.
%    copts.f :       step size F in interfal [0,2]; default
%                    is 0.8.
%    copts.cr :      crossover probability; default is 0.5.
%    copts.strategy: strategy, see 'devec3'; default is 7.
%    copts.refresh:  print info every 'refresh' iterations;
%                    default is -1 (no info)
% d0 : vector with initial thickness guesses.

% Ulf Griesmann, January 2014

% constants
C_RNG = 1;      % sets upper limit
C_NP  = 20;
C_F   = 0.002;  % "stepsize"
C_CR  = 0.6;
C_STR = 7;
C_REF = -1; 

if isrow(d0), d0 = d0'; end
D = [zeros(length(d0),1), C_RNG*d0];

% options structure
if isempty(opts)
   copts.xv = D;               % initial parameter limits
   copts.np = C_NP*length(d0); % number of populations per layer
   copts.f  = C_F;             % step size
   copts.cr = C_CR;            % crossover probability
   copts.strategy = C_STR;     % minimization strategy
   copts.refresh = C_REF;      % info display refresh
else
   copts = opts;
   if ~isfield(copts, 'xv'),       copts.xv = D; end
   if ~isfield(copts, 'np'),       copts.np = C_NP*length(d0); end
   if ~isfield(copts, 'f'),        copts.f  = C_F; end
   if ~isfield(copts, 'cr'),       copts.cr = C_CR; end
   if ~isfield(copts, 'strategy'), copts.strategy = C_STR; end
   if ~isfield(copts, 'refresh'),  copts.refresh = C_REF; end
end

return
