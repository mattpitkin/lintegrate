# -*- coding: utf-8 -*-

import cython
cimport cython

import numpy as np
cimport numpy as np

from numpy.math cimport LOGE2

from scipy.misc import logsumexp

from libc.math cimport exp, sqrt, log

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

