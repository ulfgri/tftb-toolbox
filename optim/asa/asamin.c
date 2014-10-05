/***********************************************************************
* ASAMIN --- MATLAB Gateway to Lester Ingber's Adaptive Simulated
* Annealing (ASA) Software
* 
* Copyright (c) 1999-2008 Shinichi Sakata.  All Rights Reserved.
***********************************************************************/
/* $Id: asamin.c,v 1.39 2011/02/18 16:49:47 ssakata Exp $ */

#include <string.h>
#include <float.h>

#include "mex.h"
#include "asa.h"
#include "asamin.h"

/* Some working storage */
static USER_DEFINES *USER_ASA_OPTIONS;
static char cost_func_name[MAXLEN_COST_FUNC_NAME];
static mxArray *cost_func_handle;
static int use_rejected_cost[1] = { FALSE };

static double (*cost_function) ();
static int matlab_cost_func_nrhs = 1;
static mxArray **matlab_cost_func_prhs;
static double *critical_cost_value;
static double *user_acceptance_flag;

static void
set_real_to_option (const mxArray * value, double *var)
{
   if ((mxGetM (value) == 1) && (mxGetN (value) == 1)
       && (mxIsDouble (value)) && (!mxIsComplex (value))) {
      *var = mxGetScalar (value);
   }
   else {
      mexErrMsgTxt ("Error: The second operand must be real.");
   }
}

static void
set_int_to_option (const mxArray * value, int *var)
{
   if ((mxGetM (value) == 1) && (mxGetN (value) == 1)
       && (mxIsDouble (value)) && (!mxIsComplex (value))) {
      *var = (int)mxGetScalar (value);
   }
   else {
      mexErrMsgTxt ("Error: The second operand must be real.");
   }
}

static void
set_longint_to_option (const mxArray * value, long int *var)
{
   if ((mxGetM (value) == 1) && (mxGetN (value) == 1)
       && (mxIsDouble (value)) && (!mxIsComplex (value))) {
      *var = (long int)mxGetScalar (value);
   }
   else {
      mexErrMsgTxt ("Error: The second operand must be real.");
   }
}

static void
set_string_to_option (const mxArray * value, char *var)
{
   if (mxIsChar (value)) {
      mxGetString (value, var, mxGetN (value) + 1);
   }
   else {
      mexErrMsgTxt ("Error: The second operand must be a character string.");
   }
}

/*
  The next two functions, myrand and randflt, were copied from
  user.c in ASA.
*/

#define MULT ((LONG_INT) 25173)
#define MOD ((LONG_INT) 65536)
#define INCR ((LONG_INT) 13849)
#define FMOD ((double) 65536.0)

/***********************************************************************
* double myrand - returns random number between 0 and 1
*	This routine returns the random number generator between 0 and 1
***********************************************************************/

static double
myrand (LONG_INT * rand_seed)
{
#if FALSE			/* (change to FALSE for alternative RNG) */
   *rand_seed = (LONG_INT) ((MULT * (*rand_seed) + INCR) % MOD);
   return ((double) (*rand_seed) / FMOD);
#else
   /* See "Random Number Generators: Good Ones Are Hard To Find,"
      Park & Miller, CACM 31 (10) (October 1988) pp. 1192-1201.
      ***********************************************************
      THIS IMPLEMENTATION REQUIRES AT LEAST 32 BIT INTEGERS
      *********************************************************** */
#define _A_MULTIPLIER  16807L
#define _M_MODULUS     2147483647L	/* (2**31)-1 */
#define _Q_QUOTIENT    127773L	/* 2147483647 / 16807 */
#define _R_REMAINDER   2836L	/* 2147483647 % 16807 */
   long lo;
   long hi;
   long test;

   hi = *rand_seed / _Q_QUOTIENT;
   lo = *rand_seed % _Q_QUOTIENT;
   test = _A_MULTIPLIER * lo - _R_REMAINDER * hi;
   if (test > 0) {
      *rand_seed = test;
   }
   else {
      *rand_seed = test + _M_MODULUS;
   }
   return ((double) *rand_seed / _M_MODULUS);
#endif /* alternative RNG */
}

/***********************************************************************
* double randflt
***********************************************************************/

static double
randflt (LONG_INT * rand_seed)
{
   return (resettable_randflt (rand_seed, 0));
}

/***********************************************************************
* double resettable_randflt
***********************************************************************/
static double
resettable_randflt (LONG_INT * rand_seed, int reset)
  /* shuffles random numbers in random_array[SHUFFLE] array */
{

   /* This RNG is a modified algorithm of that presented in
    * %A K. Binder
    * %A D. Stauffer
    * %T A simple introduction to Monte Carlo simulations and some
    *    specialized topics
    * %B Applications of the Monte Carlo Method in statistical physics
    * %E K. Binder
    * %I Springer-Verlag
    * %C Berlin
    * %D 1985
    * %P 1-36
    * where it is stated that such algorithms have been found to be
    * quite satisfactory in many statistical physics applications. */

   double rranf;
   unsigned kranf;
   int n;
   static int randflt_initial_flag = 0;
   LONG_INT initial_seed;
   static double random_array[SHUFFLE];	/* random variables */

   if (*rand_seed < 0)
      *rand_seed = -*rand_seed;

   if ((randflt_initial_flag == 0) || reset) {
      initial_seed = *rand_seed;

      for (n = 0; n < SHUFFLE; ++n)
	 random_array[n] = myrand (&initial_seed);

      randflt_initial_flag = 1;

      for (n = 0; n < 1000; ++n)	/* warm up random generator */
	 rranf = randflt (&initial_seed);

      rranf = randflt (rand_seed);

      return (rranf);
   }

   kranf = (unsigned) (myrand (rand_seed) * SHUFFLE) % SHUFFLE;
   rranf = *(random_array + kranf);
   *(random_array + kranf) = myrand (rand_seed);

   return (rranf);
}

static double
cost_function_without_test (double *x,
			    double *parameter_lower_bound,
			    double *parameter_upper_bound,
			    double *cost_tangents,
			    double *cost_curvature,
			    ALLOC_INT * parameter_dimension,
			    int *parameter_int_real,
			    int *cost_flag,
			    int *exit_code, USER_DEFINES * USER_OPTIONS)
{
   double unif_rn;
   double cost_value;
   double *pd;

   /* The cost function written in matlab should return
      the cost value */

   int nlhs = 2;
   mxArray *plhs[2];


   /* The cost function written in matlab is called with arguments:
      x */

   /* Set matlab_cost_func_prhs[0] */
   *user_acceptance_flag = USER_OPTIONS->User_Acceptance_Flag;
   if (cost_func_handle == NULL) {
      pd = mxGetPr(matlab_cost_func_prhs[0]);
      memcpy (pd, x, *parameter_dimension*sizeof (double));

      mexCallMATLAB (nlhs, plhs,
		     matlab_cost_func_nrhs,
		     matlab_cost_func_prhs, cost_func_name);
   }
   else {
      matlab_cost_func_prhs[0] = cost_func_handle;
      pd = mxGetPr(matlab_cost_func_prhs[1]);
      memcpy (pd, x, *parameter_dimension*sizeof (double));

      mexCallMATLAB (nlhs, plhs,
		     matlab_cost_func_nrhs,
		     matlab_cost_func_prhs, "feval");
   }

   cost_value = mxGetScalar (plhs[0]);
   *cost_flag = mxGetScalar (plhs[1]);

   if (!USER_OPTIONS->User_Acceptance_Flag) {
      unif_rn = randflt (USER_OPTIONS->Random_Seed);
      *critical_cost_value =
	 *USER_OPTIONS->Last_Cost -
	 USER_OPTIONS->Cost_Temp_Curr * log (unif_rn + DBL_MIN);
      if (cost_value <= *critical_cost_value) {
	 USER_OPTIONS->User_Acceptance_Flag = TRUE;
      }
      else {
	 USER_OPTIONS->User_Acceptance_Flag = FALSE;
      }
   }

   /* If the cost value less than the past best value is returned to
      asa (), asa () updates various indices using the returned cost
      value, whether the current state is accepted or not. This feature
      may have some values in certain applications, but it also may be
      confusing.  Here, we set the *critical_cost_value to cost_value if
      the current state is rejected, so that the cost value returned to
      asa () is never less than the past best value if the current state
      is rejected. If you want to return the cost value computed by the
      user matlab function instead, turn off this feature by replacing
      TRUE in the following line with FALSE.  */

   if (!*use_rejected_cost) {
      if ((!*user_acceptance_flag) &&
	  *cost_flag && (!USER_OPTIONS->User_Acceptance_Flag)) {
	 cost_value = *critical_cost_value;
      }
   }

   /* This gateway routine assumes that the user cost function can
      always determine if the current stage should be accepted; so,
      USER_OPTIONS->Cost_Acceptance_Flag is always set to TRUE. */
   USER_OPTIONS->Cost_Acceptance_Flag = TRUE;
   mxDestroyArray (plhs[0]);
   mxDestroyArray (plhs[1]);
   return (cost_value);
}

static double
cost_function_with_test (double *x,
			 double *parameter_lower_bound,
			 double *parameter_upper_bound,
			 double *cost_tangents,
			 double *cost_curvature,
			 ALLOC_INT * parameter_dimension,
			 int *parameter_int_real,
			 int *cost_flag,
			 int *exit_code, USER_DEFINES * USER_OPTIONS)
{
   double unif_rn;
   double cost_value;

   /* The cost function written in matlab should return
      the cost value
      cost_flag (the constraints are valid?)
      user_acceptance_flag (the current state is accepted?) */

   int nlhs = 3;
   mxArray *plhs[3];


   /* The cost function written in matlab is called with arguments:
      x
      critical_cost_value
      User_Acceptance_Flag (=1 if acceptancetest is not necessary)  */

   /* Set matlab_cost_func_prhs[0] */
   if (cost_func_handle == NULL) {
      memcpy (mxGetPr (matlab_cost_func_prhs[0]), x,
	      *parameter_dimension * (ALLOC_INT) sizeof (double));
   }
   else {
      matlab_cost_func_prhs[0] = cost_func_handle;
      memcpy (mxGetPr (matlab_cost_func_prhs[1]), x,
	      *parameter_dimension * (ALLOC_INT) sizeof (double));
   }

   /* Set matlab_cost_func_prhs[1] */

   if (!USER_OPTIONS->User_Acceptance_Flag) {
      unif_rn = randflt (USER_OPTIONS->Random_Seed);
      *critical_cost_value =
	 *USER_OPTIONS->Last_Cost -
	 USER_OPTIONS->Cost_Temp_Curr * log (unif_rn + DBL_MIN);
   }

   /* Set matlab_cost_func_prhs[2] */
   *user_acceptance_flag = USER_OPTIONS->User_Acceptance_Flag;

   if (cost_func_handle == NULL) {
      mexCallMATLAB (nlhs, plhs,
		     matlab_cost_func_nrhs,
		     matlab_cost_func_prhs, cost_func_name);
   }
   else {
      mexCallMATLAB (nlhs, plhs,
		     matlab_cost_func_nrhs,
		     matlab_cost_func_prhs, "feval");
   }
 
   cost_value = mxGetScalar (plhs[0]);
   *cost_flag = mxGetScalar (plhs[1]);
   USER_OPTIONS->User_Acceptance_Flag = mxGetScalar (plhs[2]);

   /* If the cost value less than the past best value is returned to
      asa (), asa () updates various indices using the returned cost
      value, whether the current state is accepted or not. This feature
      may have some values in certain applications, but it also may be
      confusing.  Here, we set the *critical_cost_value to cost_value if
      the current state is rejected, so that the cost value returned to
      asa () is never less than the past best value if the current state
      is rejected. If you want to return the cost value computed by the
      user matlab function instead, turn off this feature by replacing
      TRUE in the following line with FALSE.  */

   if (!*use_rejected_cost) {
      if ((!*user_acceptance_flag) &&
	  *cost_flag && (!USER_OPTIONS->User_Acceptance_Flag)) {
	 cost_value = *critical_cost_value;
      }
   }

   /* This gateway routine assumes that the user cost function can
      always determine if the current stage should be accepted; so,
      USER_OPTIONS->Cost_Acceptance_Flag is always set to TRUE. */
   USER_OPTIONS->Cost_Acceptance_Flag = TRUE;
   mxDestroyArray (plhs[0]);
   mxDestroyArray (plhs[1]);
   mxDestroyArray (plhs[2]);
   return (cost_value);
}

static void
user_acceptance_test (double current_cost,
		      ALLOC_INT * parameter_dimension,
		      USER_DEFINES * USER_OPTIONS)
{
   mexErrMsgTxt ("Internal Error: user_acceptance_test () is called.");
}

/* An exit function to clean up the working storage.
   Registered with matlab and called by matlab on exit */


static void
reset_options (LONG_INT * rand_seed,
	       int *test_in_cost_func,
	       int *use_rejected_cost, USER_DEFINES * USER_OPTIONS)
{
   *rand_seed = 696969;
   *test_in_cost_func = 0;
   *use_rejected_cost = FALSE;
   /* USER_OPTIONS->Limit_Acceptances = 10000; */
   USER_OPTIONS->Limit_Acceptances = 1000;
   USER_OPTIONS->Limit_Generated = 99999;
   USER_OPTIONS->Limit_Invalid_Generated_States = 1000;
   /* USER_OPTIONS->Accepted_To_Generated_Ratio = 1.0E-6; */
   USER_OPTIONS->Accepted_To_Generated_Ratio = 1.0E-4;

   USER_OPTIONS->Cost_Precision = 1.0E-18;
   USER_OPTIONS->Maximum_Cost_Repeat = 5;
   USER_OPTIONS->Number_Cost_Samples = 5;
   USER_OPTIONS->Temperature_Ratio_Scale = 1.0E-5;
   USER_OPTIONS->Cost_Parameter_Scale_Ratio = 1.0;
   USER_OPTIONS->Temperature_Anneal_Scale = 100.0;

   USER_OPTIONS->Include_Integer_Parameters = FALSE;
   USER_OPTIONS->User_Initial_Parameters = FALSE;
   USER_OPTIONS->Sequential_Parameters = -1;
   USER_OPTIONS->Initial_Parameter_Temperature = 1.0;

   USER_OPTIONS->Acceptance_Frequency_Modulus = 100;
   USER_OPTIONS->Generated_Frequency_Modulus = 10000;
   USER_OPTIONS->Reanneal_Cost = 1;
   USER_OPTIONS->Reanneal_Parameters = TRUE;

   USER_OPTIONS->Delta_X = 0.001;
   USER_OPTIONS->User_Tangents = FALSE;
   USER_OPTIONS->Curvature_0 = FALSE;
   strcpy (USER_OPTIONS->Asa_Out_File, "asa.log");
}


/*
 * mex Function entry
 */
void
mexFunction (int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
   char cmd[MAXLEN_CMD];
   int cmdlen;
   static LONG_INT rand_seed[1] = { 696969 };
   static int test_in_cost_func[1] = { 0 };

   static short initialized = FALSE;

   int option_matched = FALSE;
   int i;
   int noffs;
   double *ptr;

   int exit_code[1] = { 0 };
   double *parameter_lower_bound, *parameter_upper_bound,
      *cost_parameters, *cost_tangents, *cost_curvature;
   double *minimum_cost_value;

   /* the number of parameters to optimize */
   ALLOC_INT *parameter_dimension;

   /* pointer to array storage for parameter type flags */
   int *parameter_int_real;

   /* valid flag for cost function */
   int cost_flag[1] = { 0 };

   if (!initialized) {
      /* Register the Exit Function */

      if (0 != mexAtExit (exit_function)) {
	 mexErrMsgTxt ("Internal Error: Failed to register exit function.\n");
      }
      initialized = TRUE;
      if ((USER_ASA_OPTIONS =
	   (USER_DEFINES *) mxCalloc (1, sizeof (USER_DEFINES))) == NULL) {
	 mexErrMsgTxt ("Internal Error: USER_DEFINES cannot be allocated.");
      }
      mexMakeMemoryPersistent (USER_ASA_OPTIONS);
      if ((USER_ASA_OPTIONS->Asa_Out_File =
	   (char *) mxCalloc (MAXLEN_ASA_OUT_FILE, sizeof (char))) == NULL) {
	 mexErrMsgTxt
	    ("Internal Error: USER_ASA_OPTIONS->Asa_Out_File cannot be allocated.");
      }
      mexMakeMemoryPersistent (USER_ASA_OPTIONS->Asa_Out_File);

      reset_options (rand_seed, test_in_cost_func,
		     use_rejected_cost, USER_ASA_OPTIONS);
      USER_ASA_OPTIONS->Acceptance_Test = user_acceptance_test;
   }

   if (nrhs < 1) {
      mexErrMsgTxt ("Error: No command was given.");
   }

   if (!mxIsChar (prhs[0])) {
      mexErrMsgTxt ("Error: The first argument must be a commond.");
   }

   if ((cmdlen = mxGetN (prhs[0]) + 1) <= MAXLEN_CMD) {
      mxGetString (prhs[0], cmd, cmdlen);
   }
   else {
      *cmd = (char) 0;
   }

   if (strcmp ("reset", cmd) == 0) {
      reset_options (rand_seed, test_in_cost_func,
		     use_rejected_cost, USER_ASA_OPTIONS);
      return;
   }

   if (strcmp ("set", cmd) == 0) {
      nlhs = 0;			/* The set command returns nothing. */
      if (nrhs > 3) {
	 mexErrMsgTxt ("Error: Too many operands are given.");
      }
      if (nrhs >= 2) {
	 if (!mxIsChar (prhs[1])) {
	    mexErrMsgTxt ("Error: The first operand must be an option name.");
	 }
	 else {
	    if ((cmdlen = mxGetN (prhs[1]) + 1) <= MAXLEN_CMD) {
	       mxGetString (prhs[1], cmd, cmdlen);
	    }
	    else {
	       *cmd = (char) 0;
	    }
	 }
      }

      if ((nrhs == 1) || (strcmp ("rand_seed", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_longint_to_option (prhs[2], rand_seed);
	 }
	 else {
	    mexPrintf ("  rand_seed = %ld\n", *rand_seed);
	 }
      }

      if ((nrhs == 1) || (strcmp ("test_in_cost_func", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_int_to_option (prhs[2], test_in_cost_func);
	 }
	 else {
	    mexPrintf ("  test_in_cost_func = %ld\n", *test_in_cost_func);
	 }
      }

      if ((nrhs == 1) || (strcmp ("use_rejected_cost", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_int_to_option (prhs[2], use_rejected_cost);
	 }
	 else {
	    mexPrintf ("  use_rejected_cost = %ld\n", *use_rejected_cost);
	 }
      }

      if ((nrhs == 1) || (strcmp ("asa_out_file", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_string_to_option (prhs[2], USER_ASA_OPTIONS->Asa_Out_File);
	 }
	 else {
	    mexPrintf ("  asa_out_file = '%s'\n",
		       USER_ASA_OPTIONS->Asa_Out_File);
	 }
      }

      if ((nrhs == 1) || (strcmp ("limit_acceptances", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_longint_to_option (prhs[2],
				   &USER_ASA_OPTIONS->Limit_Acceptances);
	 }
	 else {
	    mexPrintf ("  limit_acceptances = %ld\n",
		       USER_ASA_OPTIONS->Limit_Acceptances);
	 }
      }

      if ((nrhs == 1) || (strcmp ("limit_generated", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_longint_to_option (prhs[2],
				   &USER_ASA_OPTIONS->Limit_Generated);
	 }
	 else {
	    mexPrintf ("  limit_generated = %ld\n",
		       USER_ASA_OPTIONS->Limit_Generated);
	 }
      }

      if ((nrhs == 1) || (strcmp ("limit_invalid", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_int_to_option (prhs[2],
			       &USER_ASA_OPTIONS->Limit_Invalid_Generated_States);
	 }
	 else {
	    mexPrintf ("  limit_invalid = %d\n",
		       USER_ASA_OPTIONS->Limit_Invalid_Generated_States);
	 }
      }

      if ((nrhs == 1) || (strcmp ("accepted_to_generated_ratio", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_real_to_option (prhs[2],
				&USER_ASA_OPTIONS->Accepted_To_Generated_Ratio);
	 }
	 else {

	    mexPrintf ("  accepted_to_generated_ratio = %g\n",
		       USER_ASA_OPTIONS->Accepted_To_Generated_Ratio);
	 }
      }

      if ((nrhs == 1) || (strcmp ("cost_precision", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_real_to_option (prhs[2], &USER_ASA_OPTIONS->Cost_Precision);
	 }
	 else {
	    mexPrintf ("  cost_precision = %g\n",
		       USER_ASA_OPTIONS->Cost_Precision);
	 }
      }

      if ((nrhs == 1) || (strcmp ("maximum_cost_repeat", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_int_to_option (prhs[2],
			       &USER_ASA_OPTIONS->Maximum_Cost_Repeat);
	 }
	 else {
	    mexPrintf ("  maximum_cost_repeat = %d\n",
		       USER_ASA_OPTIONS->Maximum_Cost_Repeat);
	 }
      }

      if ((nrhs == 1) || (strcmp ("number_cost_samples", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_int_to_option (prhs[2],
			       &USER_ASA_OPTIONS->Number_Cost_Samples);
	 }
	 else {
	    mexPrintf ("  number_cost_samples = %d\n",
		       USER_ASA_OPTIONS->Number_Cost_Samples);
	 }
      }

      if ((nrhs == 1) || (strcmp ("temperature_ratio_scale", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_real_to_option (prhs[2],
				&USER_ASA_OPTIONS->Temperature_Ratio_Scale);
	 }
	 else {
	    mexPrintf ("  temperature_ratio_scale = %g\n",
		       USER_ASA_OPTIONS->Temperature_Ratio_Scale);
	 }
      }

      if ((nrhs == 1) || (strcmp ("cost_parameter_scale_ratio", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_real_to_option (prhs[2],
				&USER_ASA_OPTIONS->Cost_Parameter_Scale_Ratio);
	 }
	 else {
	    mexPrintf ("  cost_parameter_scale_ratio = %g\n",
		       USER_ASA_OPTIONS->Cost_Parameter_Scale_Ratio);
	 }
      }

      if ((nrhs == 1) || (strcmp ("temperature_anneal_scale", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_real_to_option (prhs[2],
				&USER_ASA_OPTIONS->Temperature_Anneal_Scale);
	 }
	 else {
	    mexPrintf ("  temperature_anneal_scale = %g\n",
		       USER_ASA_OPTIONS->Temperature_Anneal_Scale);
	 }
      }

      if ((nrhs == 1) || (strcmp ("include_integer_parameters", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_int_to_option (prhs[2],
			       &USER_ASA_OPTIONS->Include_Integer_Parameters);
	 }
	 else {
	    mexPrintf ("  include_integer_parameters = %d\n",
		       USER_ASA_OPTIONS->Include_Integer_Parameters);
	 }
      }

      if ((nrhs == 1) || (strcmp ("user_initial_parameters", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_int_to_option (prhs[2],
			       &USER_ASA_OPTIONS->User_Initial_Parameters);
	 }
	 else {
	    mexPrintf ("  user_initial_parameters = %d\n",
		       USER_ASA_OPTIONS->User_Initial_Parameters);
	 }
      }

      if ((nrhs == 1) || (strcmp ("sequential_parameters", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_longint_to_option (prhs[2],
				   &USER_ASA_OPTIONS->Sequential_Parameters);
	 }
	 else {
	    mexPrintf ("  sequential_parameters = %d\n",
		       USER_ASA_OPTIONS->Sequential_Parameters);
	 }
      }

      if ((nrhs == 1) || (strcmp ("initial_parameter_temperature", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_real_to_option (prhs[2],
				&USER_ASA_OPTIONS->Initial_Parameter_Temperature);
	 }
	 else {
	    mexPrintf ("  initial_parameter_temperature = %g\n",
		       USER_ASA_OPTIONS->Initial_Parameter_Temperature);
	 }
      }

      if ((nrhs == 1) || (strcmp ("acceptance_frequency_modulus", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_int_to_option (prhs[2],
			       &USER_ASA_OPTIONS->Acceptance_Frequency_Modulus);
	 }
	 else {
	    mexPrintf ("  acceptance_frequency_modulus = %d\n",
		       USER_ASA_OPTIONS->Acceptance_Frequency_Modulus);
	 }
      }

      if ((nrhs == 1) || (strcmp ("generated_frequency_modulus", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_int_to_option (prhs[2],
			       &USER_ASA_OPTIONS->Generated_Frequency_Modulus);
	 }
	 else {
	    mexPrintf ("  generated_frequency_modulus = %d\n",
		       USER_ASA_OPTIONS->Generated_Frequency_Modulus);
	 }
      }

      if ((nrhs == 1) || (strcmp ("reanneal_cost", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_int_to_option (prhs[2], &USER_ASA_OPTIONS->Reanneal_Cost);
	 }
	 else {
	    mexPrintf ("  reanneal_cost = %d\n",
		       USER_ASA_OPTIONS->Reanneal_Cost);
	 }
      }

      if ((nrhs == 1) || (strcmp ("reanneal_parameters", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_int_to_option (prhs[2],
			       &USER_ASA_OPTIONS->Reanneal_Parameters);
	 }
	 else {
	    mexPrintf ("  reanneal_parameters = %d\n",
		       USER_ASA_OPTIONS->Reanneal_Parameters);
	 }
      }

      if ((nrhs == 1) || (strcmp ("delta_x", cmd) == 0)) {
	 option_matched = TRUE;
	 if (nrhs > 2) {
	    set_real_to_option (prhs[2], &USER_ASA_OPTIONS->Delta_X);
	 }
	 else {
	    mexPrintf ("  delta_x = %g\n", USER_ASA_OPTIONS->Delta_X);
	 }
      }
      if (!option_matched)
	 mexErrMsgTxt ("Error: The option name is invalid.");
      return;
   }

   if (strcmp ("minimize", cmd) == 0) {
      nlhs = 3;			/* The minimize command returns three matrices. */
      if (nrhs < 6) {
	 mexErrMsgTxt
	    ("Error: At least 5 operands are expected for 'minimize'.");
      }

      /*
       * get cost function name or handle
       */
      if (mxIsChar (prhs[1])) {
	 if ((cmdlen = mxGetN (prhs[1]) + 1) > MAXLEN_COST_FUNC_NAME) {
	    mexErrMsgTxt ("Error: The name of the cost function is too long.");
	 }
	 mxGetString (prhs[1], cost_func_name, cmdlen);
	 cost_func_handle = NULL;
	 noffs = 0;
      }
      else if (mxIsClass(prhs[1], "function_handle")) {
	 cost_func_handle = prhs[1];
	 noffs = 1;
      }
      else {
	 mexErrMsgTxt("Error: First operand must be the cost function name or function handle");
      }

      if (!mxIsChar (prhs[1])) {
      }

      if ((mxGetN (prhs[2]) != 1) || (mxGetN (prhs[3]) != 1) ||
	  (mxGetN (prhs[4]) != 1) || (mxGetN (prhs[5]) != 1) ||
	  (mxGetM (prhs[3]) != mxGetM (prhs[2])) ||
	  (mxGetM (prhs[4]) != mxGetM (prhs[2])) ||
	  (mxGetM (prhs[5]) != mxGetM (prhs[2])) ||
	  (!mxIsDouble (prhs[2])) || (mxIsComplex (prhs[2])) ||
	  (!mxIsDouble (prhs[3])) || (mxIsComplex (prhs[3])) ||
	  (!mxIsDouble (prhs[4])) || (mxIsComplex (prhs[4])) ||
	  (!mxIsDouble (prhs[5])) || (mxIsComplex (prhs[5]))) {
	 mexErrMsgTxt
	    ("Error: The second through fifth operands must be column vectors of the same size.");
      }
      plhs[0] = mxCreateDoubleMatrix (1, 1, mxREAL);
      minimum_cost_value = mxGetPr (plhs[0]);

      if ((parameter_dimension =
	   (ALLOC_INT *) mxCalloc (1, sizeof (ALLOC_INT))) == NULL) {
	 mexErrMsgTxt
	    ("Internal Error: parameter_dimension cannot be allocated.");
      }
      *parameter_dimension = mxGetM (prhs[2]);

      /* Allocate and initialize parameter initial values;
         the parameter final values will be stored here later */

      plhs[1] = mxCreateDoubleMatrix (*parameter_dimension, 1, mxREAL);
      cost_parameters = mxGetPr (plhs[1]);
      memcpy (cost_parameters, mxGetPr (prhs[2]),
	      *parameter_dimension * sizeof (double));

      /* Allocate and initialize parameter lower bounds */
      parameter_lower_bound = mxGetPr (prhs[3]);

      /* Allocate and initialize parameter upper bounds */
      parameter_upper_bound = mxGetPr (prhs[4]);

      /* Allocate and initialize the parameter types, real or integer */
      if ((parameter_int_real =
	   (int *) mxCalloc (*parameter_dimension, sizeof (int))) == NULL) {
	 mexErrMsgTxt
	    ("Internal Error: parameter_int_real cannot be allocated.");
      }
      ptr = mxGetPr (prhs[5]);
      for (i = 0; i < *parameter_dimension; i++) {
	 parameter_int_real[i] = *ptr;
	 ptr++;
      }

      /* Allocate space for parameter cost_tangents -
         used for reannealing */
      plhs[2] = mxCreateDoubleMatrix (*parameter_dimension, 1, mxREAL);
      cost_tangents = mxGetPr (plhs[2]);

      /* Allocate space for parameter cost_curvatures/covariance */
      plhs[3] =
	 mxCreateDoubleMatrix (*parameter_dimension,
			       *parameter_dimension, mxREAL);
      cost_curvature = mxGetPr (plhs[3]);

      /* Allocate space for status (exit_code and cost_flag),
         which will be set after returning from asa() */

      plhs[4] = mxCreateDoubleMatrix (2, 1, mxREAL);

      /* Allocate the space for the RHS variables of the matlab cost
         functions (global pointer variables) */

      if (*test_in_cost_func == 0) {
	 cost_function = cost_function_without_test;
	 matlab_cost_func_nrhs = nrhs - 5 + noffs;
      }
      else {
	 cost_function = cost_function_with_test;
	 matlab_cost_func_nrhs = nrhs - 3 + noffs;
      }
      if ((matlab_cost_func_prhs =
	   mxCalloc (matlab_cost_func_nrhs, sizeof (mxArray *))) == NULL) {
	 mexErrMsgTxt
	    ("Internal Error: matlab_cost_func_prhs cannot be allocated.");
      }

      matlab_cost_func_prhs[noffs] =
	 mxCreateDoubleMatrix (*parameter_dimension, 1, mxREAL);
      if (*test_in_cost_func == 0) {
	 for (i = 0; i < (nrhs - 6); i++) {
	    matlab_cost_func_prhs[noffs + 1 + i] = prhs[6 + i];
	 }
	 if ((critical_cost_value =
	      (double *) mxCalloc (1, sizeof (double))) == NULL) {
	    mexErrMsgTxt
	       ("Internal Error: critical_cost_value cannot be allocated.");
	 }
	 if ((user_acceptance_flag =
	      (double *) mxCalloc (1, sizeof (double))) == NULL) {
	    mexErrMsgTxt
	       ("Internal Error: user_acceptance_flag cannot be allocated.");
	 }
      }
      else {
	 matlab_cost_func_prhs[noffs + 1] = mxCreateDoubleMatrix (1, 1, mxREAL);
	 critical_cost_value = mxGetPr (matlab_cost_func_prhs[1]);
	 matlab_cost_func_prhs[noffs + 2] = mxCreateDoubleMatrix (1, 1, mxREAL);
	 user_acceptance_flag = mxGetPr (matlab_cost_func_prhs[2]);
	 for (i = 0; i < (nrhs - 6); i++) {
	    matlab_cost_func_prhs[noffs + 3 + i] = prhs[6 + i];
	 }
      }

      resettable_randflt (rand_seed, 1);	/* initialize random
						   number generator */

      USER_ASA_OPTIONS->Immediate_Exit = FALSE;

      *minimum_cost_value =
	 asa (cost_function,
	      randflt,
	      rand_seed,
	      cost_parameters,
	      parameter_lower_bound,
	      parameter_upper_bound,
	      cost_tangents,
	      cost_curvature,
	      parameter_dimension,
	      parameter_int_real, cost_flag, exit_code, USER_ASA_OPTIONS);

      *(mxGetPr (plhs[4])) = *exit_code;
      *(mxGetPr (plhs[4]) + 1) = *cost_flag;

      if (*exit_code == -1) {
	 mexErrMsgTxt ("Error: calloc in asa () failed.");
      }

      /* Free local memories */
      mxDestroyArray (matlab_cost_func_prhs[0]);
      if (*test_in_cost_func != 0) {
	 mxDestroyArray (matlab_cost_func_prhs[1]);
	 mxDestroyArray (matlab_cost_func_prhs[2]);
      }
      if (*test_in_cost_func == 0) {
	 mxFree (critical_cost_value);
	 mxFree (user_acceptance_flag);
      }
      mxFree (matlab_cost_func_prhs);
      mxFree (parameter_int_real);
      mxFree (parameter_dimension);
      return;
   }
   if (strcmp ("immediate exit", cmd) == 0) {
      USER_ASA_OPTIONS->Immediate_Exit = TRUE;
      return;
   }

   mexErrMsgTxt ("Error: No such command.");
}

static void
exit_function ()
{
   mxFree (USER_ASA_OPTIONS->Asa_Out_File);
   mxFree (USER_ASA_OPTIONS);
}
