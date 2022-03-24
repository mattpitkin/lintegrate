Python API
==========

The functions described in the :ref:`C API` can be access using the Python lintegrate module
provided with the library. These functions have a similar style to the SciPy
:func:`~scipy.integrate.quad` function.

.. function:: logtrapz(f, x, [disable_checks=False, args=()])

    Given the natural logarithm ``f`` of some function ``g`` (i.e., f = log(g)), compute the natural logarithm of the
    integral of that function using the trapezium rule.

    :param f: A set of values of the logarithm of a function evaluated at points given by ``x``, or a function handle of the log function to be evaluated.
    :type f: :class:`numpy.ndarray`, list, or function handle
    :param x:  An array of values at which ``f`` has been evaluated, or is to be evaluated at. Or, provided ``f`` is also an array, a single value giving the spacing between evaluation points (if the function has been evaluated on an evenly spaced grid).
    :type x: :class:`numpy.ndarray`, list, or float
    :param bool disable_checks: Set this to True to disable checks, such as making sure ``x`` values are in ascending order. Defaults to False.
    :param tuple args: A tuple of any additional parameters required by the function ``f`` (to be unpacked within the function).
    :return: The natural logarithm of the integral of the function
    :rtype: float

.. function:: lqng(func, a=0., b=0., [args=(), epsabs=1.49e-8, epsrel=1.49e-8, intervals=None, nintervals=0, intervaltype='linear'])

    Python wrapper to the :func:`lintegration_qng` function. This will integrate `exp(func)`, whilst staying
    in log-space to ensure numerical precision, using a non-adaptive procedure. It uses fixed
    Gauss-Kronrod-Patterson abscisae to sample the integrand at a maximum of 87 points (see
    :c:func:`gsl_integration_qng`).

    :param function func: A callable Python function which returns the natural logarithm of the underlying function being integrated over.
    :param float a: Lower limit of integration
    :param float b: Upper limit of integration
    :param tuple args:
        Extra arguments to pass to `func`. These must be unpacked within `func`, e.g.::

            def myfunc(x, args):
                y, z = args
                return x + y + z

    :param float epsabs: The absolute error tolerance for the integral
    :param float epsrel: The relative error tolerance for the integral
    :param intervals:
        An array of values bounding intervals into which the integral will be split (this could be
        used, for example, if you have a very tightly peaked function and require small intervals
        around the peak).
    :type intervals: :class:`numpy.ndarray` or list
    :param int nintervals: If ``intervals`` is not given then split the range between ``a`` and ``b`` into ``nintervals`` intervals
    :param str intervaltype: If splitting into ``nintervals`` intervals then choose whether to split the range in equal intervals in 'linear', 'log', or 'log10' space
    :return: A tuple containing: the natural logarithm of the integral of exp(func), an estimate of the absolute error in the result, and the number of evaluations used in the integration
    :rtype: tuple

.. function:: lqag(func, a=0., b=0., [args=(), epsabs=1.49e-8, epsrel=1.49e-8, limit=50, intkey=1, intervals=None, nintervals=0, intervaltype='linear'])

    Python wrapper to the :func:`lintegration_qag` function. This will integrate `exp(func)`, whilst staying
    in log-space to ensure numerical precision, using a simple adaptive procedure (see
    :c:func:`gsl_integration_qag`).

    :param function func: A callable Python function which returns the natural logarithm of the underlying function being integrated over.
    :param float a: Lower limit of integration
    :param float b: Upper limit of integration
    :param tuple args:
        Extra arguments to pass to `func`. These must be unpacked within `func`, e.g.::

            def myfunc(x, args):
                y, z = args
                return x + y + z

    :param float epsabs: The absolute error tolerance for the integral
    :param float epsrel: The relative error tolerance for the integral
    :param int limit: The maximum number of subintervals used in the integration
    :param int intkey: A key given the integration rule following those for the :c:func:`gsl_integration_qag` function. This can be 1, 2, 3, 4, 5, or 6, corresponding to the 15, 21, 31, 41, 51 and 61 point Gauss-Kronrod rules respectively.
    :param intervals:
        An array of values bounding intervals into which the integral will be split (this could be
        used, for example, if you have a very tightly peaked function and require small intervals
        around the peak).
    :type intervals: :class:`numpy.ndarray` or list
    :param int nintervals: If ``intervals`` is not given then split the range between ``a`` and ``b`` into ``nintervals`` intervals
    :param str intervaltype: If splitting into ``nintervals`` intervals then choose whether to split the range in equal intervals in 'linear', 'log', or 'log10' space
    :return: A tuple containing: the natural logarithm of the integral of exp(func) and an estimate of the absolute error in the result
    :rtype: tuple

.. function:: lcquad(func, a, b, [args=(), epsabs=1.49e-8, epsrel=1.49e-8, wsintervals=100, intervals=None, nintervals=0, intervaltype='linear'])

    Python wrapper to the :func:`lintegration_cquad` function. This will integrate `exp(func)`, whilst staying
    in log-space to ensure numerical precision, using a doubly adaptive procedure (see
    :c:func:`gsl_integration_cquad`).

    :param function func: A callable Python function which returns the natural logarithm of the underlying function being integrated over.
    :param float a: Lower limit of integration
    :param float b: Upper limit of integration
    :param tuple args:
        Extra arguments to pass to `func`. These must be unpacked within `func`, e.g.::

            def myfunc(x, args):
                y, z = args
                return x + y + z

    :param float epsabs: The absolute error tolerance for the integral
    :param float epsrel: The relative error tolerance for the integral
    :param int wsintervals: A sufficient number of subintervals for the integration (if the workspace is full the smallest intervals will be discarded)
    :param intervals:
        An array of values bounding intervals into which the integral will be split (this could be
        used, for example, if you have a very tightly peaked function and require small intervals
        around the peak).
    :type intervals: :class:`numpy.ndarray` or list
    :param int nintervals: If ``intervals`` is not given then split the range between ``a`` and ``b`` into ``nintervals`` intervals
    :param str intervaltype: If splitting into ``nintervals`` intervals then choose whether to split the range in equal intervals in 'linear', 'log', or 'log10' space
    :return: A tuple containing: the natural logarithm of the integral of exp(func), an estimate of the absolute error in the result, and the number of evaluations used in the integration
    :rtype: tuple
