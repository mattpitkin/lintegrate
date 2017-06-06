# -*- coding: utf-8 -*-

import cython
cimport cython

import numpy as np
cimport numpy as np

from numpy.math cimport LOGE2

from scipy.misc import logsumexp

from libc.math cimport exp, sqrt, log

cdef extern from "gsl/gsl_integration.h":
    void gsl_integration_workspace_free (gsl_integration_workspace * w)
    ctypedef struct gsl_integration_workspace
    gsl_integration_workspace * gsl_integration_workspace_alloc (size_t n)

cdef extern from "lintegrate.h":
    ctypedef double (*pylintfunc)(double x, void *funcdata, void *args)
    int lintegration_qng (pylintfunc f, void *funcdata, void *args, double a, double b, double epsabs, double epsrel, double *result, double *abserr, size_t *neval);
    int lintegration_qag (pylintfunc f, void *funcdata, void *args, double a, double b, double epsabs, double epsrel, size_t limit, int key, gsl_integration_workspace * workspace, double * result, double * abserr)

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
                if not isinstance(args, tuple):
                    args = (args,)
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


def lqng(func, a, b, args=(), epsabs=1.49e-8, epsrel=1.49e-8):
    """
    Python wrapper to the :func:`lintegration_qng` function. This will integrate `exp(func)`, whilst staying
    in log-space to ensure numerical precission, using a non-adaptive proceedure. It uses fixed
    Gauss-Kronrod-Patterson abscisae to sample the integrand at a maximum of 87 points (see
    `gsl_integration_qng <https://www.gnu.org/software/gsl/manual/html_node/QNG-non_002dadaptive-Gauss_002dKronrod-integration.html#QNG-non_002dadaptive-Gauss_002dKronrod-integration>`_).

    Parameters
    ----------
    func : function
        A callable Python function which returns the natural logarithm of the underlying function
        being integrated over.
    a : float
        Lower limit of integration
    b : float
        Upper limit of integration
    args : tuple, optional
        Extra arguments to pass to `func`. These must be unpacked within `func`, e.g.::

            def myfunc(x, args):
                y, z = args
                return x + y + z

    Returns
    -------
    result : float
        The natural logarithm of the integral of exp(func)
    abserr : float
        An estimate of the absolute error in the result
    neval : int
        The number of evaluations used in the integration


    Other parameters
    ----------------
    epsabs : float, optional
        The absolute error tolerance for the integral
    epsrel : float, optional
        The relative error tolerance for the integral
    """

    if not callable(func):
        raise Exception('"func" must be a callable function')

    if not isinstance(args, tuple):
        args = (args,) # convert to tuple

    cdef double result = 0.
    cdef double abserr = 0.
    cdef size_t neval = 0
    cdef int suc = 0

    suc = lintegration_qng(lintegrate_callback, <void*>func, <void*> args, a, b, epsabs, epsrel, &result, &abserr, &neval)

    assert suc == 0, "'lintegration_qng' failed"

    return (result, abserr, neval)


def lqag(func, a, b, args=(), epsabs=1.49e-8, epsrel=1.49e-8, limit=50, intkey=1):
    """
    Python wrapper to the :func:`lintegration_qag` function. This will integrate `exp(func)`, whilst staying
    in log-space to ensure numerical precission, using a  simple adaptive proceedure (see
    `gsl_integration_qag <https://www.gnu.org/software/gsl/manual/html_node/QAG-adaptive-integration.html#QAG-adaptive-integration>`_).

    Parameters
    ----------
    func : function
        A callable Python function which returns the natural logarithm of the underlying function
        being integrated over.
    a : float
        Lower limit of integration
    b : float
        Upper limit of integration
    args : tuple, optional
        Extra arguments to pass to `func`. These must be unpacked within `func`, e.g.::

            def myfunc(x, args):
                y, z = args
                return x + y + z

    Returns
    -------
    result : float
        The natural logarithm of the integral of exp(func)
    abserr : float
        An estimate of the absolute error in the result

    Other parameters
    ----------------
    epsabs : float, optional
        The absolute error tolerance for the integral
    epsrel : float, optional
        The relative error tolerance for the integral
    limit : int, optional
        The maximum number of subintervals used in the integration
    intkey : int, optional
        A key given the integration rule following those for the `gsl_integration_qag` function. This can be
        1, 2, 3, 4, 5, or 6, corresponding to the 15, 21, 31, 41, 51 and 61 point Gauss-Kronrod rules respectively.
    """

    if not callable(func):
        raise Exception('"func" must be a callable function')

    if not isinstance(args, tuple):
        args = (args,) # convert to tuple

    if intkey not in [1, 2, 3, 4, 5, 6]:
        raise Exception('"intkey" must be 1, 2, 3, 4, 5, or 6')

    if isinstance(intkey, float):
        intket = int(intkey)

    cdef double result = 0.
    cdef double abserr = 0.
    cdef int suc = 0

    assert limit > 0 and isinstance(limit, int), '"limit" must be a positive integer'

    cdef gsl_integration_workspace *w = gsl_integration_workspace_alloc(limit)

    suc = lintegration_qag(lintegrate_callback, <void*>func, <void*>args, a, b, epsabs, epsrel, limit, intkey, w, &result, &abserr)

    gsl_integration_workspace_free(w)

    assert suc == 0, "'lintegration_qag' failed"

    return (result, abserr)


# callback function to allow python functions to be passed to C lintegration functions
# (see e.g. https://github.com/cython/cython/tree/master/Demos/callback)
cdef double lintegrate_callback(double x, void *f, void *args):
    return (<object>f)(x, <object>args)

