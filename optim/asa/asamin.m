%  ASAMIN A gateway function to Adaptive Simulated Annealing (ASA)
%
%  ASAMIN is a matlab gateway function to Lester Ingber's Adaptive
%  Simulated Annealing (ASA) Software
%
%  Copyright (c) 1999-2008  Shinichi Sakata. All Rights Reserved. 
%  $Id: asamin.m,v 1.39 2011/02/18 16:49:47 ssakata Exp $
%
%  Usage:
%
%  asamin ('set')
%
%    lists the current value of each option.
%
%  asamin ('set', opt_name)
%
%    shows the current value of the option given by a character string
%    opt_name; e.g., 
%
%        asamin ('set', 'seed')
%
%  asamin ('set', opt_name, opt_value)
%
%    set the value opt_value to the option opt_name; e.g.,
%
%        asamin ('set', 'seed', 654342)
%        asamin ('set', 'asa_out_file', 'example.log')
%
%  The valid options in these commands are:
%
%    rand_seed
%    test_in_cost_func
%    use_rejected_cost
%    asa_out_file
%    limit_acceptances
%    limit_generated
%    limit_invalid
%    accepted_to_generated_ratio
%    cost_precision
%    maximum_cost_repeat
%    number_cost_samples
%    temperature_ratio_scale
%    cost_parameter_scale_ratio
%    temperature_anneal_scale
%    include_integer_parameters
%    user_initial_parameters
%    sequential_parameters
%    initial_parameter_temperature
%    acceptance_frequency_modulus
%    generated_frequency_modulus
%    reanneal_cost
%    reanneal_parameters
%    delta_x
%
%    rand_seed is the seed of the random number generation in ASA. 
%
%    If test_in_cost_func is set to zero, the cost function should
%    simply return the value of the objective function. When
%    test_in_cost_func is set to one, asamin () calls the cost
%    function with a threshold value as well as the parameter
%    value. The cost function needs to judge if the value of the cost
%    function exceeds the threshold as well as compute the value of
%    the cost function when asamin () requires. (See COST FUNCTION
%    below for details.)
%
%    All other items but use_rejected_cost belong to structure
%    USER_OPTIONS in ASA. See ASA_README in the ASA package for
%    details. The default value of use_rejected_cost is zero. If you
%    set this option to one, ASA uses the current cost value to
%    compute certain indices, even if the current state is rejected by
%    the user cost function, provided that the current cost value is
%    lower than the cost value of the past best state. (See COST
%    FUNCTION below about the user cost function.)
%
%  asamin ('reset')
%    resets all option values to the hard-coded default values.
%
%  [fstar,xstar,grad,hessian,state] = ...
%     asamin ('minimize', func, xinit, xmin, xmax, xtype,...
%              parm1, parm2, ...)
%
%     minimizes the cost function func (also see COST FUNCTION below).
%     The argument xinit specifies the initial value of the arguments
%     of the cost function. Each element of the vectors xmin and xmax
%     specify the lower and upper bounds of the corresponding
%     argument.  The vector xtype indicates the types of the
%     arguments. If xtype(i) is -1 if the i'th argument is real;
%     xtype(i) is 1 if the i'th argument is integer. If this argument
%     should be ignored in reannealing, multiply the corresponding
%     element of xtype by 2 so that the element is 2 or -2. All
%     parameters following xtype are optional and simply passed to the
%     cost function each time the cost function is called.
%
%     This way of calling asamin returns the following values:
%
%     fstar
%       The value of the objective function at xstar.
%     xstar
%       The argument vector at the exit from the ASA routine. If things go
%       well, xstar should be the minimizer of "func".
%     grad
%       The gradient of "func" at xstar.
%     hessian
%       The Hessian of "func" at xstar.
%     state
%       The vector containing the information on the exit state. 
%       state(1) is the exit_code, and state(2) is the cost flag. See 
%       ASA_README for details.
%
%
%     
%  COST FUNCTION
%
%  If test_in_cost_func is set to zero, asamin () calls the "cost
%  function" (say, cost_func) with one argument, say x (the real cost
%  function is evaluated at this point). Cost_func is expected to
%  return the value of the objective function and cost_flag, the
%  latter of which must be zero if any constraint (if any) is
%  violated; otherwise one.
%
%  When test_in_cost_func is equal to one, asamin () calls the "cost
%  function" (say, cost_func) with three arguments, say, x (at which
%  the real cost function is evaluated), critical_cost_value, and
%  no_test_flag. Asamin expects cost_func to return three scalar
%  values, say, cost_value, cost_flag, and user_acceptance_flag in the
%  following manner.
%   
%    1. The function cost_func first checks if x satisfies the
%    constraints of the minimization problem. If any of the
%    constraints is not satisfied, cost_func sets zero to cost_flag
%    and return. (user_acceptance_flag and cost_value will not be used
%    by asamin () in this case.) If all constraints are satisfied, set
%    one to cost_flag, and proceed to the next step.
%   
%    2. If asamin () calls cost_func with no_test_flag==1, cost_func
%    must compute the value of the cost function, set it to cost_value
%    and return. When no_test_flag==0, cost_func is expected to judge
%    if the value of the cost function is greater than
%    critical_cost_value. If the value of the cost function is found
%    greater than critical_cost_value, cost_func must set zero to
%    user_acceptance_flag and return. (asamin () will not use
%    cost_value in this case.) On the other hand, if the value of the
%    cost function is found no greater than critical_cost_value,
%    cost_func must compute the cost function at x, set it to
%    cost_value, and set one to user_acceptance_flag.
%   
%  Remark: To understand the usefulness of test_in_cost_func == 1,
%  note that it is sometimes easier to check if the value of the cost
%  function is greater than critical_cost_value than compute the value
%  of the cost function. For example, suppose that the cost function g
%  is implicitly defined by an equation f(g(x),x)=0, where f is
%  strictly increasing in the first argument, and evaluation of g(x)
%  is computationally expensive (e.g., requiring an iterative method
%  to find a solution to f(y,x)=0). But we can easily show that
%  f(critical_cost_value,x) < 0 if and only if g(x) >
%  critical_cost_value. We can judge if g(x) > critical_cost_value by
%  computing f(critical_cost_value,x). The value of g(x) is not
%  necessary.
%
