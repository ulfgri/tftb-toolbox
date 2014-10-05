% Demo program for levmar's MEX-file interface
% function names and function handles
%
% Ulf Griesmann, October 2013

format long;

% Unconstrained minimization

% fitting the exponential model x_i=p(1)*exp(-p(2)*i)+p(3) of expfit.c to noisy measurements obtained with (5.0 0.1 1.0)
p0=[1.0, 0.0, 0.0];
x=[5.8728, 5.4948, 5.0081, 4.5929, 4.3574, 4.1198, 3.6843, 3.3642, 2.9742, 3.0237, 2.7002, 2.8781,...
   2.5144, 2.4432, 2.2894, 2.0938, 1.9265, 2.1271, 1.8387, 1.7791, 1.6686, 1.6232, 1.571, 1.6057,...
   1.3825, 1.5087, 1.3624, 1.4206, 1.2097, 1.3129, 1.131, 1.306, 1.2008, 1.3469, 1.1837, 1.2102,...
   0.96518, 1.2129, 1.2003, 1.0743];

options=[1E-03, 1E-15, 1E-15, 1E-20, 1E-06];
% arg demonstrates additional data passing to expfit/jacexpfit
arg=[40];

% functions are specified with function names
[ret, popt, info] = levmar('expfit', 'jacexpfit', p0, x, 200, options, arg);
disp('Exponential model fitting (see also ../expfit.c)');
popt

% functions are specified with function handles
[ret, popt, info] = levmar(@expfit, @jacexpfit, p0, x, 200, options, arg);
disp('Exponential model fitting (see also ../expfit.c)');
popt

