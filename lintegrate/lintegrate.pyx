# -*- coding: utf-8 -*-

# Copyright (C) 2017 Matthew Pitkin
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

import cython
cimport cython

import numpy as np
cimport numpy as np

from numpy.math cimport LOGE2, INFINITY

from scipy.misc import logsumexp

from libc.math cimport exp, sqrt, log, log10, isinf, fabs

cdef extern from "gsl/gsl_integration.h":
    void gsl_integration_workspace_free (gsl_integration_workspace * w)
    ctypedef struct gsl_integration_workspace
    gsl_integration_workspace * gsl_integration_workspace_alloc (size_t n)
    void gsl_integration_cquad_workspace_free (gsl_integration_cquad_workspace * w)
    ctypedef struct gsl_integration_cquad_workspace
    gsl_integration_cquad_workspace * gsl_integration_cquad_workspace_alloc (size_t n)

cdef extern from "gsl/gsl_sf_log.h":
    double gsl_sf_log_1plusx(double x)

cdef extern from "lintegrate.h":
    ctypedef double (*pylintfunc)(double x, void *funcdata, void *args)
    int lintegration_qng (pylintfunc f, void *funcdata, void *args, double a, double b, double epsabs, double epsrel, double *result, double *abserr, size_t *neval)
    int lintegration_qag (pylintfunc f, void *funcdata, void *args, double a, double b, double epsabs, double epsrel, size_t limit, int key, gsl_integration_workspace * workspace, double * result, double * abserr)
    int lintegration_cquad (pylintfunc f, void *funcdata, void *args, double a, double b, double epsabs, double epsrel, gsl_integration_cquad_workspace * ws, double *result, double *abserr, size_t * nevals)


DTYPE = np.float64
ctypedef np.float64_t DTYPE_t

GSL_DBL_EPSILON = 2.2204460492503131e-16

cdef double logtrapzC(np.ndarray[DTYPE_t, ndim=1] lx, np.ndarray[DTYPE_t, ndim=1] t):
    assert len(lx) == len(t) or len(t) == 1, "Function and function evaluation points must be the same length, or there must be a single evaluation point spacing given"

    cdef double B = -INFINITY

    cdef int i = 0
    cdef double z
    cdef int loopmax = len(lx)-1

    for i in range(loopmax):
        z = logplus(lx[i], lx[i+1])
        if len(t) > 1:
          z = z + log(t[i+1]-t[i])

        B = logplus(B,z)

    B -= LOGE2

    if len(t) > 1:
        return B
    else:
        return B + log(t[0])


cdef logplus(double x, double y):
    """
    Calculate :math:`\log{(e^x + e^y)}` in a way that preserves numerical precision.

    .. note:: This is faster than using the :func:`numpy.logaddexp` function

    Parameters
    ----------
    x, y : double
        The natural logarithm of two values.

    Returns
    -------
    z : double
        The value of :math:`\log{(e^x + e^y)}`.
    """

    cdef double z = INFINITY
    cdef double tmp = x - y
    if x == y or fabs(tmp) < 1e3*GSL_DBL_EPSILON:
        z = x + LOGE2
    elif x > y:
        z = x + gsl_sf_log_1plusx(exp(-tmp))
    elif x <= y:
        z = y + gsl_sf_log_1plusx(exp(tmp))
    return z


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
        `f` is also an array, a single value giving the spacing between evaluation points (if the
        function has been evaluated on an evenly spaced grid).
    args : tuple
        A tuple of any additional parameters required by the function `f` (to be unpacked within
        the function).

    Returns
    -------
    I : double
        The natural logarithm of the integral of the function

    """

    if isinstance(f, np.ndarray) or isinstance(f, list):
        if isinstance(x, np.ndarray) or isinstance(x, list):
            # check arrays are the same length
            assert len(f) == len(x) and len(x) > 1, "Function and function evaluation points are not the same length"

            # make sure x values are in ascending order (keeping f values associated to their x evaluation points)
            zp = np.array(sorted(zip(x, f)))

            # perform trapezium rule (internal logtrapzC function is faster than using scipy logsumexp)
            return logtrapzC(zp[:,1], zp[:,0])
        elif isinstance(x, float):
            assert x > 0., "Evaluation spacings must be positive"

            # perform trapezium rule
            return logtrapzC(f, np.array([x]))
        else:
            raise Exception('Error... value of "x" must be a numpy array or a float')
    elif callable(f): # f is a function
        if isinstance(x, np.ndarray) or isinstance(x, list):
            assert len(x) > 1, "Function must be evaluated at more than one point"

            try:
                if not isinstance(args, tuple):
                    args = (args,)
                vs = f(np.array(x), args) # make sure x is an array when passed to function
            except:
                raise Exception('Error... could not evaluate function "f"')

            # make sure x values are in ascending order (keeping f values associated to their x evaluation points)
            zp = np.array(sorted(zip(x, vs)))

            # perform trapezium rule (internal logtrapzC function is faster than using scipy logsumexp)
            return logtrapzC(zp[:,1], zp[:,0])
        else:
            raise Exception('Error... "x" must be a numpy array or list')
    else:
        raise Exception('Error... "f" must be a numpy array, list, or callable function')


def lqng(func, a=0., b=0., args=(), epsabs=1.49e-8, epsrel=1.49e-8, intervals=None, nintervals=0, intervaltype='linear'):
    """
    Python wrapper to the :func:`lintegration_qng` function. This will integrate `exp(func)`, whilst staying
    in log-space to ensure numerical precision, using a non-adaptive procedure. It uses fixed
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
    intervals : :class:`numpy.ndarray`, list, optional
        An array of values bounding intervals into which the integral will be split (this could be
        used, for example, if you have a very tightly peaked function and require small intervals
        around the peak).
    nintervals : int, optional
        If `intervals` is not given then split the range between `a` and `b` into `nintervals'
        intervals
    intervaltype : string, optional
        If splitting into `nintervals` intervals then choose whether to split the range in equal
        intervals in 'linear', 'log', or 'log10' space
    """

    if not callable(func):
        raise Exception('"func" must be a callable function')

    assert b > a or intervals is not None or (nintervals != 0 and b > a), "Integral range must have b > a"

    if not isinstance(args, tuple):
        args = (args,) # convert to tuple

    cdef double result = 0., sumres = -INFINITY
    cdef double abserr = 0., sumabserr = -INFINITY
    cdef size_t neval = 0, nevaltmp = 0
    cdef int suc = 0

    if intervals is None:
        if nintervals == 0: # just use a and b
            nintervals = 1

        assert nintervals > 0, "Number of intervals must be positive"

        if intervaltype.lower() == 'linear':
            intervals = np.linspace(a, b, nintervals+1)
        elif intervaltype.lower() == 'log':
            intervals = np.logspace(log(a), log(b), nintervals+1, base=exp(1.))
        elif intervaltype.lower() == 'log10':
            intervals = np.logspace(log10(a), log10(b), nintervals+1)
        else:
            raise Exception("Interval type must be 'linear', 'log', or 'log10'")
    else:
        if isinstance(intervals, np.ndarray) or isinstance(intervals, list):
            intervals = np.array(sorted(intervals)) # make sure array is in ascending order

    for i in xrange(len(intervals)-1):
        suc = lintegration_qng(lintegrate_callback, <void*>func, <void*> args, intervals[i], intervals[i+1], epsabs, epsrel, &result, &abserr, &nevaltmp)
        assert suc == 0, "'lintegration_qng' failed"
        sumres = logplus(sumres, result)
        sumabserr = logplus(sumabserr, abserr)
        neval += nevaltmp
    result = sumres
    abserr = sumabserr

    return (result, abserr, neval)


def lqag(func, a=0., b=0., args=(), epsabs=1.49e-8, epsrel=1.49e-8, limit=50, intkey=1, intervals=None, nintervals=0, intervaltype='linear'):
    """
    Python wrapper to the :func:`lintegration_qag` function. This will integrate `exp(func)`, whilst staying
    in log-space to ensure numerical precision, using a simple adaptive procedure (see
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
    intervals : :class:`numpy.ndarray`, list, optional
        An array of values bounding intervals into which the integral will be split (this could be
        used, for example, if you have a very tightly peaked function and require small intervals
        around the peak).
    nintervals : int, optional
        If `intervals` is not given then split the range between `a` and `b` into `nintervals'
        intervals
    intervaltype : string, optional
        If splitting into `nintervals` intervals then choose whether to split the range in equal
        intervals in 'linear', 'log', or 'log10' space
    """

    if not callable(func):
        raise Exception('"func" must be a callable function')

    assert b > a or intervals is not None or (nintervals != 0 and b > a), "Integral range must have b > a"

    if not isinstance(args, tuple):
        args = (args,) # convert to tuple

    if intkey not in [1, 2, 3, 4, 5, 6]:
        raise Exception('"intkey" must be 1, 2, 3, 4, 5, or 6')

    if isinstance(intkey, float):
        intket = int(intkey)

    cdef double result = 0., sumres = -INFINITY
    cdef double abserr = 0., sumabserr = -INFINITY
    cdef int suc = 0

    assert limit > 0 and isinstance(limit, int), '"limit" must be a positive integer'

    cdef gsl_integration_workspace *w = gsl_integration_workspace_alloc(limit)

    if intervals is None:
        if nintervals == 0: # just use a and b
            nintervals = 1

        assert nintervals > 0, "Number of intervals must be positive"

        if intervaltype.lower() == 'linear':
            intervals = np.linspace(a, b, nintervals+1)
        elif intervaltype.lower() == 'log':
            intervals = np.logspace(log(a), log(b), nintervals+1, base=exp(1.))
        elif intervaltype.lower() == 'log10':
            intervals = np.logspace(log10(a), log10(b), nintervals+1)
        else:
            raise Exception("Interval type must be 'linear', 'log', or 'log10'")
    else:
        if isinstance(intervals, np.ndarray) or isinstance(intervals, list):
            intervals = np.array(sorted(intervals)) # make sure array is in ascending order

    for i in xrange(len(intervals)-1):
        suc = lintegration_qag(lintegrate_callback, <void*>func, <void*>args, intervals[i], intervals[i+1], epsabs, epsrel, limit, intkey, w, &result, &abserr)
        assert suc == 0, "'lintegration_qag' failed"
        sumres = logplus(sumres, result)
        sumabserr = logplus(sumabserr, abserr)
    result = sumres
    abserr = sumabserr

    gsl_integration_workspace_free(w)

    return (result, abserr)


def lcquad(func, a, b, args=(), epsabs=1.49e-8, epsrel=1.49e-8, wsintervals=100, intervals=None, nintervals=0, intervaltype='linear'):
    """
    Python wrapper to the :func:`lintegration_cquad` function. This will integrate `exp(func)`, whilst staying
    in log-space to ensure numerical precision, using a doubly adaptive procedure (see
    `gsl_integration_cquad <https://www.gnu.org/software/gsl/manual/html_node/CQUAD-doubly_002dadaptive-integration.html>`_).

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
    wsintervals : int, optional
        A sufficient number of subintervals for the integration (if the workspace is full the smallest intervals will be discarded)
    intervals : :class:`numpy.ndarray`, list, optional
        An array of values bounding intervals into which the integral will be split (this could be
        used, for example, if you have a very tightly peaked function and require small intervals
        around the peak).
    nintervals : int, optional
        If `intervals` is not given then split the range between `a` and `b` into `nintervals'
        intervals
    intervaltype : string, optional
        If splitting into `nintervals` intervals then choose whether to split the range in equal
        intervals in 'linear', 'log', or 'log10' space
    """

    if not callable(func):
        raise Exception('"func" must be a callable function')

    assert b > a or intervals is not None or (nintervals != 0 and b > a), "Integral range must have b > a"

    if not isinstance(args, tuple):
        args = (args,) # convert to tuple

    cdef double result = 0., sumres = -INFINITY
    cdef double abserr = 0., sumabserr = -INFINITY
    cdef size_t neval = 0, nevaltmp = 0
    cdef int suc = 0

    assert wsintervals > 0 and isinstance(wsintervals, int), '"intervals" must be a positive integer'

    cdef gsl_integration_cquad_workspace *w = gsl_integration_cquad_workspace_alloc(wsintervals)

    if intervals is None:
        if nintervals == 0: # just use a and b
            nintervals = 1

        assert nintervals > 0, "Number of intervals must be positive"

        if intervaltype.lower() == 'linear':
            intervals = np.linspace(a, b, nintervals+1)
        elif intervaltype.lower() == 'log':
            intervals = np.logspace(log(a), log(b), nintervals+1, base=exp(1.))
        elif intervaltype.lower() == 'log10':
            intervals = np.logspace(log10(a), log10(b), nintervals+1)
        else:
            raise Exception("Interval type must be 'linear', 'log', or 'log10'")
    else:
        if isinstance(intervals, np.ndarray) or isinstance(intervals, list):
            intervals = np.array(sorted(intervals)) # make sure array is in ascending order

    for i in xrange(len(intervals)-1):
        suc = lintegration_cquad(lintegrate_callback, <void*>func, <void*>args, intervals[i], intervals[i+1], epsabs, epsrel, w, &result, &abserr, &nevaltmp)
        assert suc == 0, "'lintegration_cquad' failed"
        sumres = logplus(sumres, result)
        sumabserr = logplus(sumabserr, abserr)
        neval += nevaltmp
    result = sumres
    abserr = sumabserr

    gsl_integration_cquad_workspace_free(w)

    return (result, abserr, neval)


# callback function to allow python functions to be passed to C lintegration functions
# (see e.g. https://github.com/cython/cython/tree/master/Demos/callback)
cdef double lintegrate_callback(double x, void *f, void *args):
    return (<object>f)(x, <object>args)
