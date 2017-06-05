# -*- coding: utf-8 -*-

import cython
cimport cython

import numpy as np
cimport numpy as np

from numpy.math cimport LOGE2

from scipy.misc import logsumexp

from libc.math cimport exp, sqrt, log

cdef extern from "gsl/gsl_math.h":
    ctypedef struct gsl_function:
        double (* function) (double x, void * params)
        void * params

cdef extern from "gsl/gsl_integration.h":
    void  gsl_integration_cquad_workspace_free (gsl_integration_cquad_workspace * w)
    ctypedef struct gsl_integration_workspace
    gsl_integration_workspace * gsl_integration_workspace_alloc (size_t n)


# import lintegration functions
cdef extern from "lintegrate.h":
    int lintegration_qag(const gsl_function *f, double a, double b, double epsabs, double epsrel, size_t limit, int key, gsl_integration_workspace * workspace, double * result, double * abserr)
    int lintegration_qng (const gsl_function *f, double a, double b, double epsabs, double epsrel, double * result, double * abserr, size_t * neval)


"""
Simple function to perform trapezium rule integration of a function when given its natural log
"""
def logtrapz(f, x, args=()):
    """
    Given the natural logarithm "f" of some function "g" (i.e., f = log(g)), compute the natural logarithm of the
    integral of that function using the trapezium rule.

    Parameters
    ----------
    f : :class:`numpy.ndarray`, list, or function handle
        A set of values of the logarithm of a function evaluated at points given by `x`, or a
       function handle of the log function to be evaluated.
    x : :class:`numpy.ndarray`, list, or float
        An array of values at which `f` has been evaluated, or is to be evaluated at. Or, provided
        `f` is also an array, a single value giving the spacing between evalation points (if the
        function has been evaluated on an evenly spaced grid).
    args : tuple
        A tuple of any additional parameters required by the function `f`

    Returns
    -------
    I : double
        The natural logarithm of the intergal of the function

    """

    if isinstance(f, np.ndarray) or isinstance(f, list):
        if isinstance(x, np.ndarray) or isinstance(x, list):
            # check arrays are the same length
            assert len(f) == len(x) and len(x) > 1, "Function and function evaluation points are not the same length"

            # make sure x values are in ascending order (keeping f values associated to their x evaluation points)
            zp = np.array(sorted(zip(x, f)))

            deltas = np.log(np.diff(zp[:,0])) # get the differences between evaluation points

            # perform trapezium rule
            return -LOGE2 + logsumexp([logsumexp(zp[:-1,1]+deltas), logsumexp(zp[1:,1]+deltas)])
        elif isinstance(x, float):
            assert x > 0., "Evaluation spacings must be positive"

            # perform trapezium rule
            return np.log(x/2.) + logsumexp([logsumexp(f[:-1]), logsumexp(f[1:])])
        else:
            raise Exception('Error... value of "x" must be a numpy array or a float')
    elif callable(f): # f is a function
        if isinstance(x, np.ndarray) or isinstance(x, list):
            assert len(x) > 1, "Function must be evaluated at more than one point"

            try:
                vs = f(np.array(x), *args) # make sure x is an array when passed to function
            except:
                raise Exception('Error... could not evaluate function "f"')

            # make sure x values are in ascending order (keeping f values associated to their x evaluation points)
            zp = np.array(sorted(zip(x, vs)))

            deltas = np.log(np.diff(zp[:,0])) # get the differences between evaluation points

            # perform trapezium rule
            return -LOGE2 + logsumexp([logsumexp(zp[:-1,1]+deltas), logsumexp(zp[1:,1]+deltas)])
        else:
            raise Exception('Error... "x" must be a numpy array or list')
    else:
        raise Exception('Error... "f" must be a numpy array, list, or callable function')


ctypedef struct lparams:
    void *function # python function object
    void *args     # arguments

ctypedef lparams * lparams_ptr


cpdef functionwrapper(double x, void *p):
    cdef lparams * params = <lparams_ptr>p

    func = <object>p.function
    args = <object>p.args

    try:
        func(x, *args)
    except:
       raise Exception('Error... could not call function')


cpdef qag(func, double a, double b, args=(), epsabs=1.49e-8, epsrel=1.49e-8, limit=50, key=3):
    """
    Use `lintegrate_qag`
    """

    cdef gsl_function F
    cdef lparams params

    params.function = <void*>func
    params.args = <void*>args

    F.function = &functionwrapper
    F.params = params

    cdef gsl_integration_workspace *w = gsl_integration_workspace_alloc(limit)

    cdef double result = 0.
    cdef double err = 0.

    cdef int intkey = key # default is GSL_INTEG_GAUSS31
    cdef int suc = 0

    gsl_integration_workspace_free(w)

    suc = lintegrate_qag(&F, a, b, epsabs, epsrel, limit, intkey, &w, &result, &err)

    assert suc == 0, 'Error... integration not successful'

    return result, err

