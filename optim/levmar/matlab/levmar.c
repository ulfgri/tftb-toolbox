////////////////////////////////////////////////////////////////////////////////
// 
//  Matlab MEX file for the Levenberg - Marquardt minimization algorithm
//  Copyright (C) 2007  Manolis Lourakis (lourakis at ics forth gr)
//  Institute of Computer Science, Foundation for Research & Technology - Hellas
//  Heraklion, Crete, Greece.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
////////////////////////////////////////////////////////////////////////////////

/*
 * Modifications made by Ulf Griesmann, October 2013:
 * - first two parameters can be function handles
 * - data parameter x can be empty matrix ( [] )
 * - cleaned it up a bit
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <math.h>
#include <string.h>
#include <ctype.h>

#include <levmar.h>

#include <mex.h>

/**
 *#define DEBUG
 * better use -DDEBUG on the mex (or mkoctfile) command line
 */

#ifndef HAVE_LAPACK
#  ifdef _MSC_VER
#    pragma message("LAPACK not available, certain functionalities cannot be compiled!")
#  else
#    warning LAPACK not available, certain functionalities cannot be compiled
#  endif /* _MSC_VER */
   static int have_lapack = 0;
#else
   static int have_lapack = 1;
#endif	 /* HAVE_LAPACK */

#define __MAX__(A, B)     ((A)>=(B) ? (A) : (B))
#define __MIN__(A, B)     ((A)<(B) ? (A) : (B))

#define MIN_UNCONSTRAINED     0
#define MIN_CONSTRAINED_BC    1
#define MIN_CONSTRAINED_LEC   2
#define MIN_CONSTRAINED_BLEC  3
#define MIN_CONSTRAINED_BLEIC 4
#define MIN_CONSTRAINED_BLIC  5
#define MIN_CONSTRAINED_LEIC  6
#define MIN_CONSTRAINED_LIC   7

struct mexdata {
    /* matlab names of the fitting function & its Jacobian */
    char *fname, *jacname;

    /* matlab function handles */
    mxArray *fh_fun, *fh_jac;

    /* binary flags specifying if input p0 is a row or column vector */
    int isrow_p0;

    /* rhs args to be passed to matlab. If the name of the function
     * 'func' is passed as a string, rhs[0] is reserved for
     * passing the parameter vector. Problem-specific data, if
     * present, are passed in rhs[1], rhs[2], etc
     * If 'fun' is passed as a function handle, then rhs[0] is used
     * to pass the function handle, r[1] contains the parameter vector
     * and rhs[3:end] the problem specific data.
     */
    mxArray **rhs;
    int nrhs;			/* >= 1 */
};

/* display printf-style error messages in matlab */
static void matlabFmtdErrMsgTxt(char *fmt, ...)
{
    char buf[256];
    va_list args;

    va_start(args, fmt);
    vsprintf(buf, fmt, args);
    va_end(args);

    mexErrMsgTxt(buf);
}

/* display printf-style warning messages in matlab */
static void matlabFmtdWarnMsgTxt(char *fmt, ...)
{
    char buf[256];
    va_list args;

    va_start(args, fmt);
    vsprintf(buf, fmt, args);
    va_end(args);

    mexWarnMsgTxt(buf);
}

/* 
 * display debug messages when DEBUG is defined. Otherwise,
 * let the compiler remove the function.
 */
static void DebugMsgTxt(char *fmt, ...)
{
#ifdef DEBUG
    char buf[256];
    va_list args;

    va_start(args, fmt);
    vsprintf(buf, fmt, args);
    va_end(args);

    fflush(stderr);
    fprintf(stderr, "%s", buf);
#endif /* DEBUG */
}

static void func(double *p, double *hx, int m, int n, void *adata)
{
    mxArray *lhs[1];
    double *mp, *mx;
    register int i;
    int noffs;
    struct mexdata *dat = (struct mexdata *) adata;

    if (dat->fname == NULL) {
       noffs = 1;
       dat->rhs[0] = dat->fh_fun;
    }
    else {
       noffs = 0;
    }

    /* prepare to call matlab */
    mp = mxGetPr(dat->rhs[noffs]);
    for (i = 0; i < m; ++i)
	mp[i] = p[i];

    /* invoke matlab */
    if (dat->fname != NULL)
       mexCallMATLAB(1, lhs, dat->nrhs, dat->rhs, dat->fname);
    else
       mexCallMATLAB(1, lhs, dat->nrhs, dat->rhs, "feval");

    /* copy back results & cleanup */
    mx = mxGetPr(lhs[0]);
    for (i = 0; i < n; ++i)
	hx[i] = mx[i];

    /* delete the matrix created by matlab */
    mxDestroyArray(lhs[0]);
}

static void jacfunc(double *p, double *j, int m, int n, void *adata)
{
    mxArray *lhs[1];
    double *mp;
    double *mj;
    int noffs;
    register int i, k;
    struct mexdata *dat = (struct mexdata *) adata;

    /* prepare to call matlab */
    if (dat->jacname == NULL) {
       noffs = 1;
       dat->rhs[0] = dat->fh_jac;
    }
    else {
       noffs = 0;
    }

    /* copy parameters to MATLAB vector */
    mp = mxGetPr(dat->rhs[noffs]);
    for (i = 0; i < m; ++i)
	mp[i] = p[i];

    /* invoke matlab */
    if (dat->jacname != NULL)
       mexCallMATLAB(1, lhs, dat->nrhs, dat->rhs, dat->jacname);
    else
       mexCallMATLAB(1, lhs, dat->nrhs, dat->rhs, "feval");

    /* copy back results & cleanup. Note that the nxm Jacobian 
     * computed by matlab should be transposed so that
     * levmar gets it in row major, as expected
     */
    mj = mxGetPr(lhs[0]);
    for (i = 0; i < n; ++i)
	for (k = 0; k < m; ++k)
	    j[i * m + k] = mj[i + k * n];

    /* delete the matrix created by matlab */
    mxDestroyArray(lhs[0]);
}

/* matlab matrices are in column-major, this routine converts them to row major for levmar */
static double *getTranspose(mxArray * Am)
{
    int m, n;
    double *At, *A;
    register int i, j;

    m = mxGetM(Am);
    n = mxGetN(Am);
    A = mxGetPr(Am);
    At = mxMalloc(m * n * sizeof(double));

    for (i = 0; i < m; i++)
	for (j = 0; j < n; j++)
	    At[i * n + j] = A[i + j * m];

    return At;
}

/* check the supplied matlab function and its Jacobian. Returns 1 on error, 0 otherwise */
static int
checkFuncAndJacobian(double *p, int m, int n, int havejac,
		     struct mexdata *dat)
{
    mxArray *lhs[1];
    int i, noffs, ierr;
    int ret = 0;
    double *mp;

    mexSetTrapFlag(1); /* return to function on error */

    if (dat->fname == NULL) {
       dat->rhs[0] = dat->fh_fun;
       noffs = 1;
    }
    else {
       noffs = 0;
    }

    mp = mxGetPr(dat->rhs[noffs]);
    for (i = 0; i < m; ++i)
	mp[i] = p[i];

    /* attempt to call the supplied func */
    if (dat->fname != NULL) {
       DebugMsgTxt("checkFuncAndJacobian: calling func %s.\n", dat->fname);
       ierr = mexCallMATLAB(1, lhs, dat->nrhs, dat->rhs, dat->fname);
    }
    else {
       DebugMsgTxt("checkFuncAndJacobian: calling func (function handle).\n");
       ierr = mexCallMATLAB(1, lhs, dat->nrhs, dat->rhs, "feval");
    }
    if (ierr) {
	mexPrintf("levmar: error calling function.\n");
	ret = 1;
    } else if (!mxIsDouble(lhs[0]) || mxIsComplex(lhs[0])
	       || !(mxGetM(lhs[0]) == 1 || mxGetN(lhs[0]) == 1)
	       || __MAX__(mxGetM(lhs[0]), mxGetN(lhs[0])) != n) {
	mexPrintf("levmar: function must produce a real vector with %d elements (got %d).\n",
		  n, __MAX__(mxGetM(lhs[0]), mxGetN(lhs[0])));
	ret = 1;
    }
    /* delete the matrix created by matlab */
    mxDestroyArray(lhs[0]);

    if (havejac) {
	/* attempt to call the supplied jac  */
        if (dat->jacname == NULL) {
	   dat->rhs[0] = dat->fh_jac;
	   DebugMsgTxt("checkFuncAndJacobian: calling Jacobian (function handle).\n");
	   ierr = mexCallMATLAB(1, lhs, dat->nrhs, dat->rhs, "feval");
	}
	else {
	   DebugMsgTxt("checkFuncAndJacobian: calling Jacobian %s.\n", dat->jacname);
	   ierr = mexCallMATLAB(1, lhs, dat->nrhs, dat->rhs, dat->jacname);
	}
	if (ierr) {
	    mexPrintf("levmar: error calling Jacobian.\n");
	    ret = 1;
	} else if (!mxIsDouble(lhs[0]) || mxIsComplex(lhs[0])
		   || mxGetM(lhs[0]) != n || mxGetN(lhs[0]) != m) {
	    mexPrintf("levmar: Jacobian should produce a real %dx%d matrix (got %dx%d).\n",
		      n, m, mxGetM(lhs[0]), mxGetN(lhs[0]));
	    ret = 1;
	} else if (mxIsSparse(lhs[0])) {
	    mexPrintf("levmar: Jacobian is a sparse matrix, but must produce a real dense matrix.\n");
	    ret = 1;
	}
	/* delete the matrix created by matlab */
	mxDestroyArray(lhs[0]);
    }

    mexSetTrapFlag(0); /* return to MATLAB prompt on error */

    return ret;
}



/*
[ret, p, info, covar]=levmar_der (f, j, p0, x, itmax, opts, 'unc'                              ...)
[ret, p, info, covar]=levmar_bc  (f, j, p0, x, itmax, opts, 'bc',   lb, ub,                    ...)
[ret, p, info, covar]=levmar_bc  (f, j, p0, x, itmax, opts, 'bc',   lb, ub, dscl,              ...)
[ret, p, info, covar]=levmar_lec (f, j, p0, x, itmax, opts, 'lec',                A, b,        ...)
[ret, p, info, covar]=levmar_blec(f, j, p0, x, itmax, opts, 'blec', lb, ub,       A, b, wghts, ...)

[ret, p, info, covar]=levmar_bleic(f, j, p0, x, itmax, opts, 'bleic', lb, ub,       A, b, C, d, ...)
[ret, p, info, covar]=levmar_blic (f, j, p0, x, itmax, opts, 'blic',  lb, ub,             C, d, ...)
[ret, p, info, covar]=levmar_leic (f, j, p0, x, itmax, opts, 'leic',                A, b, C, d, ...)
[ret, p, info, covar]=levmar_lic  (f, j, p0, x, itmax, opts, 'lic',                       C, d, ...)

*/

void
mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * Prhs[])
{
    register int i;
    register double *pdbl;
    mxArray **prhs = (mxArray **) & Prhs[0], *At, *Ct;
    struct mexdata mdata;
    int len, status;
    double *p, *p0, *ret, *x;
    int m, n, havejac, Arows, Crows, itmax, nopts, mintype, nextra, noffs;
    double opts[LM_OPTS_SZ] =
	{ LM_INIT_MU, LM_STOP_THRESH, LM_STOP_THRESH, LM_STOP_THRESH,
	LM_DIFF_DELTA
    };
    double info[LM_INFO_SZ];
    double *lb = NULL, *ub = NULL, *dscl = NULL, *A = NULL, *b =
	NULL, *wghts = NULL, *C = NULL, *d = NULL, *covar = NULL;

    /* parse input args; start by checking their number */
    if ((nrhs < 5))
	matlabFmtdErrMsgTxt
	    ("levmar: at least 5 input arguments required (got %d).",
	     nrhs);
    if (nlhs > 4)
	matlabFmtdErrMsgTxt
	    ("levmar: too many output arguments (max. 4, got %d).", nlhs);
    else if (nlhs < 2)
	matlabFmtdErrMsgTxt
	    ("levmar: too few output arguments (min. 2, got %d).", nlhs);

    /* note that in order to accommodate optional args, prhs & nrhs are adjusted accordingly below */

  /** func **/
    /* first argument must be a string or a function handle */
    if ( !mxIsChar(prhs[0]) && !mxIsClass(prhs[0], "function_handle") )
	mexErrMsgTxt("levmar: first argument must be a string or a function handle.");
    if ( mxIsChar(prhs[0]) ) {
       if (mxGetM(prhs[0]) != 1)
	   mexErrMsgTxt("levmar: argument string func must be a row vector.");
       /* store supplied name */
       len = mxGetN(prhs[0]) + 1;
       mdata.fname = mxCalloc(len, sizeof(char));
       if ( mxGetString(prhs[0], mdata.fname, len) )
	  mexErrMsgTxt("levmar: not enough space. String is truncated.");
       mdata.fh_fun = NULL;
    }
    else {
       mdata.fh_fun = prhs[0];
       mdata.fname = NULL;
    }

  /** jac (optional) **/
    /* check whether second argument is a string */
    if ( mxIsChar(prhs[1]) || mxIsClass(prhs[1], "function_handle") ) {
       if ( mxIsChar(prhs[1]) ) {
	  if (mxGetM(prhs[1]) != 1)
	     mexErrMsgTxt("levmar: argument string jacname must be a row vector.");
	  /* store supplied name */
	  len = mxGetN(prhs[1]) + 1;
	  mdata.jacname = mxCalloc(len, sizeof(char));
	  if ( mxGetString(prhs[1], mdata.jacname, len) )
	     mexErrMsgTxt("levmar: not enough space. String is truncated.");
	  mdata.fh_jac = NULL;
       }
       else {
	  mdata.fh_jac = prhs[1];
	  mdata.jacname = NULL;
       }

       havejac = 1;
       ++prhs;
       --nrhs;
    } 
    else {
       mdata.jacname = NULL;
       mdata.fh_jac = NULL;
       havejac = 0;
       if ( mxIsEmpty(prhs[1]) ) {
	  ++prhs;
	  --nrhs;
       }
    }

    DebugMsgTxt("LEVMAR: %s analytic Jacobian\n", havejac ? "with" : "no");

    /* fname and jacname must be both strings or both function handles */
    if ( havejac && ( (mdata.fname == NULL && mdata.jacname != NULL) ||
		      (mdata.fname != NULL && mdata.jacname == NULL)) )
        mexErrMsgTxt("levmar: func and jacfunc must both be strings or both be function handles.");

  /** p0 **/
    /* the second required argument must be a real row or column vector */
    if (!mxIsDouble(prhs[1]) || mxIsComplex(prhs[1])
	|| !__MIN__(mxGetM(prhs[1]),mxGetN(prhs[1])) == 1)
	mexErrMsgTxt("levmar: p0 must be a real vector.");
    p0 = mxGetPr(prhs[1]);
    /* determine if we have a row or column vector and retrieve its 
     * size, i.e. the number of parameters
     */
    if (mxGetM(prhs[1]) == 1) {
	m = mxGetN(prhs[1]);
	mdata.isrow_p0 = 1;
    } else {
	m = mxGetM(prhs[1]);
	mdata.isrow_p0 = 0;
    }
    /* copy input parameter vector to avoid destroying it */
    p = mxMalloc(m * sizeof(double));
    for (i = 0; i < m; ++i)
	p[i] = p0[i];

  /** x **/
    /* the third required argument must be a real row or column vector or empty */
    if ( mxIsEmpty(prhs[2]) ) {
       x = NULL;
       n = 0;
    }
    else {
       if (!mxIsDouble(prhs[2]) || mxIsComplex(prhs[2])
	   || !__MIN__(mxGetM(prhs[2]),mxGetN(prhs[2])) == 1)
	  mexErrMsgTxt("levmar: x must be a real vector.");
       x = mxGetPr(prhs[2]);
       n = __MAX__(mxGetM(prhs[2]), mxGetN(prhs[2]));
    }

  /** itmax **/
    /* the fourth required argument must be a scalar */
    if (!mxIsDouble(prhs[3]) || mxIsComplex(prhs[3])
	|| mxGetM(prhs[3]) != 1 || mxGetN(prhs[3]) != 1)
	mexErrMsgTxt("levmar: itmax must be a scalar.");
    itmax = (int) mxGetScalar(prhs[3]);

  /** opts **/
    /* the fifth required argument must be a real row or column vector */
    if (!mxIsDouble(prhs[4]) || mxIsComplex(prhs[4]))
	mexErrMsgTxt("levmar: opts must be a real vector.");
    if ( !mxIsEmpty(prhs[4]) ) { /* if opts==[], the defaults are used */
        pdbl = mxGetPr(prhs[4]);
        nopts = __MAX__(mxGetM(prhs[4]), mxGetN(prhs[4]));
	if (nopts > LM_OPTS_SZ)
	    matlabFmtdErrMsgTxt
		("levmar: opts must have at most %d elements, got %d.",
		 LM_OPTS_SZ, nopts);
	else if (nopts < ((havejac) ? LM_OPTS_SZ - 1 : LM_OPTS_SZ))
	    matlabFmtdWarnMsgTxt
		("levmar: only the %d first elements of opts specified, remaining set to defaults.",
		 nopts);
	for (i = 0; i < nopts; ++i)
	    opts[i] = pdbl[i];
    }
    else {
       DebugMsgTxt("LEVMAR: empty options vector, using defaults\n");
    }

  /** mintype (optional) **/
    /* check whether sixth argument is a string */
    if (nrhs >= 6 && mxIsChar(prhs[5]) == 1 && mxGetM(prhs[5]) == 1) {
	char *minhowto;

	/* examine supplied name */
	len = mxGetN(prhs[5]) + 1;
	minhowto = mxCalloc(len, sizeof(char));
	status = mxGetString(prhs[5], minhowto, len);
	if (status != 0)
	    mexErrMsgTxt("levmar: not enough space. String is truncated.");

	for (i = 0; minhowto[i]; ++i)
	    minhowto[i] = tolower(minhowto[i]);
	if (!strncmp(minhowto, "unc", 3))
	    mintype = MIN_UNCONSTRAINED;
	else if (!strncmp(minhowto, "bc", 2))
	    mintype = MIN_CONSTRAINED_BC;
	else if (!strncmp(minhowto, "lec", 3))
	    mintype = MIN_CONSTRAINED_LEC;
	else if (!strncmp(minhowto, "blec", 4))
	    mintype = MIN_CONSTRAINED_BLEC;
	else if (!strncmp(minhowto, "bleic", 5))
	    mintype = MIN_CONSTRAINED_BLEIC;
	else if (!strncmp(minhowto, "blic", 4))
	    mintype = MIN_CONSTRAINED_BLIC;
	else if (!strncmp(minhowto, "leic", 4))
	    mintype = MIN_CONSTRAINED_LEIC;
	else if (!strncmp(minhowto, "lic", 3))
	    mintype = MIN_CONSTRAINED_BLIC;
	else
	    matlabFmtdErrMsgTxt("levmar: unknown minimization type '%s'.",
				minhowto);

	mxFree(minhowto);

	++prhs;
	--nrhs;
    } else
	mintype = MIN_UNCONSTRAINED;

    if (mintype == MIN_UNCONSTRAINED)
	goto extraargs;

    /* arguments below this point are optional and their presence depends
     * upon the minimization type determined above
     */
  /** lb, ub **/
    if (nrhs >= 7
	&& (mintype == MIN_CONSTRAINED_BC
	    || mintype == MIN_CONSTRAINED_BLEC
	    || mintype == MIN_CONSTRAINED_BLIC
	    || mintype == MIN_CONSTRAINED_BLEIC)) {
	/* check if the next two arguments are real row or column vectors */
	if (mxIsDouble(prhs[5]) && !mxIsComplex(prhs[5])
	    && (mxGetM(prhs[5]) == 1 || mxGetN(prhs[5]) == 1)) {
	    if (mxIsDouble(prhs[6]) && !mxIsComplex(prhs[6])
		&& (mxGetM(prhs[6]) == 1 || mxGetN(prhs[6]) == 1)) {
		if ((i = __MAX__(mxGetM(prhs[5]), mxGetN(prhs[5]))) != m)
		    matlabFmtdErrMsgTxt
			("levmar: lb must have %d elements, got %d.", m,
			 i);
		if ((i = __MAX__(mxGetM(prhs[6]), mxGetN(prhs[6]))) != m)
		    matlabFmtdErrMsgTxt
			("levmar: ub must have %d elements, got %d.", m,
			 i);

		lb = mxGetPr(prhs[5]);
		ub = mxGetPr(prhs[6]);

		prhs += 2;
		nrhs -= 2;
	    }
	}
    }

  /** dscl **/
    if (nrhs >= 7 && (mintype == MIN_CONSTRAINED_BC)) {
	/* check if the next argument is a real row or column vector */
	if (mxIsDouble(prhs[5]) && !mxIsComplex(prhs[5])
	    && (mxGetM(prhs[5]) == 1 || mxGetN(prhs[5]) == 1)) {
	    if ((i = __MAX__(mxGetM(prhs[5]), mxGetN(prhs[5]))) != m)
		matlabFmtdErrMsgTxt
		    ("levmar: dscl must have %d elements, got %d.", m, i);

	    dscl = mxGetPr(prhs[5]);

	    ++prhs;
	    --nrhs;
	}
    }

  /** A, b **/
    if (nrhs >= 7
	&& (mintype == MIN_CONSTRAINED_LEC
	    || mintype == MIN_CONSTRAINED_BLEC
	    || mintype == MIN_CONSTRAINED_LEIC
	    || mintype == MIN_CONSTRAINED_BLEIC)) {
	/* check if the next two arguments are a real matrix and a real row or column vector */
	if (mxIsDouble(prhs[5]) && !mxIsComplex(prhs[5])
	    && mxGetM(prhs[5]) >= 1 && mxGetN(prhs[5]) >= 1) {
	    if (mxIsDouble(prhs[6]) && !mxIsComplex(prhs[6])
		&& (mxGetM(prhs[6]) == 1 || mxGetN(prhs[6]) == 1)) {
		if ((i = mxGetN(prhs[5])) != m)
		    matlabFmtdErrMsgTxt
			("levmar: A must have %d columns, got %d.", m, i);
		if ((i =
		     __MAX__(mxGetM(prhs[6]), mxGetN(prhs[6]))) != (Arows =
								    mxGetM
								    (prhs
								     [5])))
		    matlabFmtdErrMsgTxt
			("levmar: b must have %d elements, got %d.", Arows,
			 i);

		At = prhs[5];
		b = mxGetPr(prhs[6]);
		A = getTranspose(At);

		prhs += 2;
		nrhs -= 2;
	    }
	}
    }

    /* wghts */
    /* check if we have a weights vector */
    if (nrhs >= 6 && mintype == MIN_CONSTRAINED_BLEC) {	/* only check if we have seen both box & linear constraints */
	if (mxIsDouble(prhs[5]) && !mxIsComplex(prhs[5])
	    && (mxGetM(prhs[5]) == 1 || mxGetN(prhs[5]) == 1)) {
	    if (__MAX__(mxGetM(prhs[5]), mxGetN(prhs[5])) == m) {
		wghts = mxGetPr(prhs[5]);

		++prhs;
		--nrhs;
	    }
	}
    }

  /** C, d **/
    if (nrhs >= 7
	&& (mintype == MIN_CONSTRAINED_BLEIC
	    || mintype == MIN_CONSTRAINED_BLIC
	    || mintype == MIN_CONSTRAINED_LEIC
	    || mintype == MIN_CONSTRAINED_LIC)) {
	/* check if the next two arguments are a real matrix and a real row or column vector */
	if (mxIsDouble(prhs[5]) && !mxIsComplex(prhs[5])
	    && mxGetM(prhs[5]) >= 1 && mxGetN(prhs[5]) >= 1) {
	    if (mxIsDouble(prhs[6]) && !mxIsComplex(prhs[6])
		&& (mxGetM(prhs[6]) == 1 || mxGetN(prhs[6]) == 1)) {
		if ((i = mxGetN(prhs[5])) != m)
		    matlabFmtdErrMsgTxt
			("levmar: C must have %d columns, got %d.", m, i);
		if ((i =
		     __MAX__(mxGetM(prhs[6]), mxGetN(prhs[6]))) != (Crows =
								    mxGetM
								    (prhs
								     [5])))
		    matlabFmtdErrMsgTxt
			("levmar: d must have %d elements, got %d.", Crows,
			 i);

		Ct = prhs[5];
		d = mxGetPr(prhs[6]);
		C = getTranspose(Ct);

		prhs += 2;
		nrhs -= 2;
	    }
	}
    }

    /* arguments below this point are assumed to be extra arguments passed
     * to every invocation of the fitting function and its Jacobian
     */

  extraargs:
    /* handle any extra args and allocate memory for
     * passing the current parameter estimate to matlab
     */
    if ( mdata.fname == NULL )
       noffs = 1;
    else
       noffs = 0;
    nextra = nrhs - 5;
    mdata.nrhs = nextra + 1 + noffs;
    mdata.rhs = (mxArray **) mxMalloc(mdata.nrhs * sizeof(mxArray *));
    for (i = 0; i < nextra; ++i)
	mdata.rhs[i + 1 + noffs] = (mxArray *) prhs[nrhs - nextra + i];	/* discard 'const' modifier */
    DebugMsgTxt("LEVMAR: %d extra args\n", nextra);

    if (mdata.isrow_p0) {	/* row vector */
	mdata.rhs[noffs] = mxCreateDoubleMatrix(1, m, mxREAL);
    } else {			/* column vector */
	mdata.rhs[noffs] = mxCreateDoubleMatrix(m, 1, mxREAL);
    }

    /* ensure that the supplied function & Jacobian are as expected */
    if (checkFuncAndJacobian(p, m, n, havejac, &mdata)) {
	status = LM_ERROR;
	goto cleanup;
    }

    if (nlhs > 3)		/* covariance output required */
	covar = mxMalloc(m * m * sizeof(double));

    /* invoke levmar */
    switch (mintype) {

    case MIN_UNCONSTRAINED:	/* no constraints */
	if (havejac)
	    status =
		dlevmar_der(func, jacfunc, p, x, m, n, itmax, opts, info,
			    NULL, covar, (void *) &mdata);
	else
	    status =
		dlevmar_dif(func, p, x, m, n, itmax, opts, info, NULL,
			    covar, (void *) &mdata);
	DebugMsgTxt("LEVMAR: calling dlevmar_der()/dlevmar_dif()\n");
	break;

    case MIN_CONSTRAINED_BC:	/* box constraints */
	if (havejac)
	    status =
		dlevmar_bc_der(func, jacfunc, p, x, m, n, lb, ub, dscl,
			       itmax, opts, info, NULL, covar,
			       (void *) &mdata);
	else
	    status =
		dlevmar_bc_dif(func, p, x, m, n, lb, ub, dscl, itmax, opts,
			       info, NULL, covar, (void *) &mdata);
	DebugMsgTxt("LEVMAR: calling dlevmar_bc_der()/dlevmar_bc_dif()\n");
	break;

    case MIN_CONSTRAINED_LEC:	/* linear equation constraints */
        if (!have_lapack)
	    mexErrMsgTxt("levmar: no linear constraints support (HAVE_LAPACK was not defined).");
	if (havejac)
	    status =
		dlevmar_lec_der(func, jacfunc, p, x, m, n, A, b, Arows,
				itmax, opts, info, NULL, covar,
				(void *) &mdata);
	else
	    status =
		dlevmar_lec_dif(func, p, x, m, n, A, b, Arows, itmax, opts,
				info, NULL, covar, (void *) &mdata);
	DebugMsgTxt("LEVMAR: calling dlevmar_lec_der()/dlevmar_lec_dif()\n");
	break;

    case MIN_CONSTRAINED_BLEC:	/* box & linear equation constraints */
        if (!have_lapack)
	    mexErrMsgTxt("levmar: no box & linear constraints support, (HAVE_LAPACK was not defined).");
	if (havejac)
	    status =
		dlevmar_blec_der(func, jacfunc, p, x, m, n, lb, ub, A, b,
				 Arows, wghts, itmax, opts, info, NULL,
				 covar, (void *) &mdata);
	else
	    status =
		dlevmar_blec_dif(func, p, x, m, n, lb, ub, A, b, Arows,
				 wghts, itmax, opts, info, NULL, covar,
				 (void *) &mdata);
	DebugMsgTxt("LEVMAR: calling dlevmar_blec_der()/dlevmar_blec_dif()\n");
	break;

    case MIN_CONSTRAINED_BLEIC:	/* box, linear equation & inequalities constraints */
        if (!have_lapack)
	    mexErrMsgTxt("levmar: no box, linear equation & inequality constraints support (HAVE_LAPACK was not defined).");
	if (havejac)
	    status =
		dlevmar_bleic_der(func, jacfunc, p, x, m, n, lb, ub, A, b,
				  Arows, C, d, Crows, itmax, opts, info,
				  NULL, covar, (void *) &mdata);
	else
	    status =
		dlevmar_bleic_dif(func, p, x, m, n, lb, ub, A, b, Arows, C,
				  d, Crows, itmax, opts, info, NULL, covar,
				  (void *) &mdata);
	DebugMsgTxt("LEVMAR: calling dlevmar_bleic_der()/dlevmar_bleic_dif()\n");
	break;

    case MIN_CONSTRAINED_BLIC:	/* box, linear inequalities constraints */
        if (!have_lapack)
	    mexErrMsgTxt("levmar: no box & linear inequality constraints support (HAVE_LAPACK was not defined).");
	if (havejac)
	    status =
		dlevmar_bleic_der(func, jacfunc, p, x, m, n, lb, ub, NULL,
				  NULL, 0, C, d, Crows, itmax, opts, info,
				  NULL, covar, (void *) &mdata);
	else
	    status =
		dlevmar_bleic_dif(func, p, x, m, n, lb, ub, NULL, NULL, 0,
				  C, d, Crows, itmax, opts, info, NULL,
				  covar, (void *) &mdata);
	DebugMsgTxt("LEVMAR: calling dlevmar_blic_der()/dlevmar_blic_dif()\n");
	break;

    case MIN_CONSTRAINED_LEIC:	/* linear equation & inequalities constraints */
        if (!have_lapack)
	    mexErrMsgTxt("levmar: no eqn. & linear inequality constraints support (HAVE_LAPACK was not defined).");
	if (havejac)
	    status =
		dlevmar_bleic_der(func, jacfunc, p, x, m, n, NULL, NULL, A,
				  b, Arows, C, d, Crows, itmax, opts, info,
				  NULL, covar, (void *) &mdata);
	else
	    status =
		dlevmar_bleic_dif(func, p, x, m, n, NULL, NULL, A, b,
				  Arows, C, d, Crows, itmax, opts, info,
				  NULL, covar, (void *) &mdata);
	DebugMsgTxt("LEVMAR: calling dlevmar_leic_der()/dlevmar_leic_dif()\n");
	break;

    case MIN_CONSTRAINED_LIC:	/* linear inequalities constraints */
        if (!have_lapack)
	    mexErrMsgTxt("levmar: no linear inequality constraints support (HAVE_LAPACK was not defined).");
	if (havejac)
	    status =
		dlevmar_bleic_der(func, jacfunc, p, x, m, n, NULL, NULL,
				  NULL, NULL, 0, C, d, Crows, itmax, opts,
				  info, NULL, covar, (void *) &mdata);
	else
	    status =
		dlevmar_bleic_dif(func, p, x, m, n, NULL, NULL, NULL, NULL,
				  0, C, d, Crows, itmax, opts, info, NULL,
				  covar, (void *) &mdata);
	DebugMsgTxt("LEVMAR: calling dlevmar_lic_der()/dlevmar_lic_dif()\n");
	break;

    default:
	mexErrMsgTxt("levmar: unexpected internal error.");
    }

#ifdef DEBUG
    fflush(stderr);
    fprintf(stderr, "LEVMAR: minimization returned %d in %g iter, reason %g\n\tSolution: ",
	    status, info[5], info[6]);
    for (i = 0; i < m; ++i)
        fprintf(stderr, "%.7g   ", p[i]);
    fprintf(stderr, "\n\n\tMinimization info:\n\t");
    for (i = 0; i < LM_INFO_SZ; ++i)
       fprintf(stderr, "%g   ", info[i]);
    fprintf(stderr, "\n");
#endif				/* DEBUG */

    /* copy back return results */
  /** ret **/
    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    ret = mxGetPr(plhs[0]);
    ret[0] = (double) status;

  /** popt **/
    plhs[1] =
	(mdata.isrow_p0 == 1) ? mxCreateDoubleMatrix(1, m,
						     mxREAL) :
	mxCreateDoubleMatrix(m, 1, mxREAL);
    pdbl = mxGetPr(plhs[1]);
    for (i = 0; i < m; ++i)
	pdbl[i] = p[i];

  /** info **/
    if (nlhs > 2) {
	plhs[2] = mxCreateDoubleMatrix(1, LM_INFO_SZ, mxREAL);
	pdbl = mxGetPr(plhs[2]);
	for (i = 0; i < LM_INFO_SZ; ++i)
	    pdbl[i] = info[i];
    }

  /** covar **/
    if (nlhs > 3) {
	plhs[3] = mxCreateDoubleMatrix(m, m, mxREAL);
	pdbl = mxGetPr(plhs[3]);
	for (i = 0; i < m * m; ++i)	/* covariance matrices are symmetric, thus no need to transpose! */
	    pdbl[i] = covar[i];
    }

  cleanup:
    /* cleanup */
    mxDestroyArray(mdata.rhs[noffs]);
    if (A)
	mxFree(A);
    if (C)
	mxFree(C);

    if (mdata.fname != NULL)
        mxFree(mdata.fname);
    if (mdata.jacname != NULL)
        mxFree(mdata.jacname);
    mxFree(p);
    mxFree(mdata.rhs);
    if (covar)
	mxFree(covar);

    if (status == LM_ERROR)
	mexWarnMsgTxt("levmar: optimization returned with an error!");
}
