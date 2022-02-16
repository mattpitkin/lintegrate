C API
=====

The C library contains a selection numerical integration functions based on equivalents in the `GSL
numerical integration
<https://www.gnu.org/software/gsl/doc/html/integration.html#numerical-integration>`_ package. To use
these functions the ``lintegrate.h`` header file must be included.

For all these functions the input :c:type:`gsl_function` ``f`` should return the natural logarithm
of the required integrand. The outputs will include the natural logarithm of the resulting integral.

QNG non-adaptive Gauss-Kronrod integration
------------------------------------------

.. function:: int lintegration_qng (const gsl_function *f, double a, double b, double epsabs, double epsrel, double * result, double * abserr, size_t * neval)

   This is the equivalent of the GSL :c:func:`gsl_integration_qng` function (see the link for a
   description of the arguments and return values). It applies a non-adaptive procedure which
   applied the `Gauss-Kronrod
   <https://en.wikipedia.org/wiki/Gauss%E2%80%93Kronrod_quadrature_formula>`_ integration rules. The
   output will include the natural logarithm of the resulting integral.

.. function:: int lintegration_qng_split (const gsl_function *f, double *splitpts, size_t npts, double epsabs, double epsrel, double * result, double * abserr, size_t * neval)

    In some cases it might be necessary to split the integral into multiple segments that are
    integrated separately and then combined. For example, if there is a large dynamic range for the
    abscissa variable. The "split" version of :func:`lintegration_qng` takes in an array of values
    ``splitpts`` giving the bounds (including of the upper bound point) and the length of that array
    ``npts``. The other arguments are the same as for :func:`lintegration_qng`.

QAG adaptive integration
------------------------

.. function:: int lintegration_qag (const gsl_function *f, double a, double b, double epsabs, double epsrel, size_t limit, int key, gsl_integration_workspace * workspace, double * result, double * abserr)

    This is the equivalent of the GSL :c:func:`gsl_integration_qag` function (see the links for a
    description of the arguments and return values). It applies a simple adaptive integration
    procedure. The integration region is divided into subintervals, and on each iteration the
    subinterval with the largest estimated error is bisected.

.. function:: int lintegration_qag_split (const gsl_function *f, double *splitpts, size_t npts, double epsabs, double epsrel, size_t limit, int key, double * result, double * abserr)

    In some cases it might be necessary to split the integral into multiple segments that are
    integrated separately and then combined. For example, if there is a large dynamic range for the
    abscissa variable. The "split" version of :func:`lintegration_qag` takes in an array of values
    ``splitpts`` giving the bounds (including of the upper bound point) and the length of that array
    ``npts``. The other arguments are the same as for :func:`lintegration_qag` except that is does
    not require a :c:type:`gsl_integration_workspace`.

CQUAD doubly-adaptive integration
---------------------------------

.. function:: int lintegration_cquad (const gsl_function * f, double a, double b, double epsabs, double epsrel, gsl_integration_cquad_workspace * ws, double *result, double *abserr, size_t * nevals)

    This is the equivalent of the GSL :c:func:`gsl_integration_cquad` function (see the links for a
    description of the arguments and return values). The algorithm uses a doubly-adaptive scheme in
    which `Clenshaw-Curtis <https://en.wikipedia.org/wiki/Clenshaw%E2%80%93Curtis_quadrature>`_
    quadrature rules of increasing degree are used to compute the integral in each interval.  It can
    handle most types of singularities, non-numerical function values such as ``Inf`` or ``NaN``, as
    well as some divergent integrals.

.. function:: int lintegration_cquad_split (const gsl_function * f, double *splitpts, size_t npts, double epsabs, double epsrel, size_t wsints, double *result, double *abserr, size_t * nevals)

    In some cases it might be necessary to split the integral into multiple segments that are
    integrated separately and then combined. For example, if there is a large dynamic range for the
    abscissa variable. The "split" version of :func:`lintegration_cquad` takes in an array of values
    ``splitpts`` giving the bounds (including of the upper bound point) and the length of that array
    ``npts``. The other arguments are the same as for :func:`lintegration_cquad`. It does not
    require a :c:type:`gsl_integration_cquad_workspace`, but does take in ``wsints`` to set the
    maximum number of intervals for each :c:type:`gsl_integration_cquad_workspace` allocated via
    :c:func:`gsl_integration_cquad_workspace_alloc`.
