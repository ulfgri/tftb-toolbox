%
%  $Id: asatest.m,v 1.39 2011/02/18 16:49:47 ssakata Exp $
%
xinit = [999; -1007; 1001; -903];
xl=-10000 * ones(4,1);
xu=10000 * ones(4,1);
xt=-1 * ones(4,1);
asamin('set','rand_seed',696969);
asamin('set','asa_out_file','asatest1.log');
asamin('set','test_in_cost_func',0);
[fstar, xstar, grad, hessian, state] = ...
  asamin('minimize', 'test_cost_func1', xinit, xl, xu, xt);
asamin('set','rand_seed',696969);
asamin('set','test_in_cost_func',1);
asamin('set','asa_out_file','asatest2.log');
[fstar, xstar, grad, hessian, state] = ...
  asamin('minimize', 'test_cost_func2', xinit, xl, xu, xt);

