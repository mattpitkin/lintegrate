Examples
========

C library
---------

Here we show a selection of examples of using the lintegrate C library functions. A Linux Makefile
for the three examples can be found `here
<https://github.com/mattpitkin/lintegrate/blob/master/example/Makefile>`_.

Example 1
^^^^^^^^^

In this example the :func:`lintegration_qag`, :func:`lintegration_qng` and
:func:`lintegration_cquad` functions are used to evaluate the integral of a Gaussian function in
log-space. The outputs are compared to the result of integration the original function using the GSL
:c:func:`gsl_integration_qag` function.

.. rli:: https://raw.githubusercontent.com/mattpitkin/lintegrate/master/example/example.c
   :language: c

Example 2
^^^^^^^^^

In this example the :func:`lintegration_qag`, :func:`lintegration_qng` and
:func:`lintegration_cquad` functions are used to evaluate the integral of flat function in
log-space. The outputs are compared to the result of integration the original function using the GSL
:c:func:`gsl_integration_qag` function.

.. rli:: https://raw.githubusercontent.com/mattpitkin/lintegrate/master/example/example_flat.c
   :language: c

Example 3
^^^^^^^^^

In this example the :func:`lintegration_qag_split`, :func:`lintegration_qng_split` and
:func:`lintegration_cquad_split` functions are used to evaluate the integral of function that is
very tightly peaked log-space. The outputs are compared to an analytical calculation of the integral
of original function found using `Wolfram Alpha <https://www.wolframalpha.com/>`_.

.. rli:: https://raw.githubusercontent.com/mattpitkin/lintegrate/master/example/example_split.c
   :language: c

Python interface
----------------

Here we show and example of using the Python interface for lintegrate.

.. code-block:: python

   from lintegrate import lqag, lqng, lcquad, logtrapz
   import numpy as np

   # define the log of the function to be integrated
   def integrand(x, args):
       mu, sig = args # unpack extra arguments
       return -0.5*((x-mu)/sig)**2

   # set integration limits
   xmin = -6.
   xmax = 6.

   # set additional arguments
   mu = 0.
   sig = 1.

   resqag = lqag(integrand, xmin, xmax, args=(mu, sig))
   resqng = lqng(integrand, xmin, xmax, args=(mu, sig))
   rescquad = lcquad(integrand, xmin, xmax, args=(mu, sig))
   restrapz = logtrapz(integrand, np.linspace(xmin, xmax, 100), args=(mu, sig))


Using R
^^^^^^^

The lintegrate Python interface can be accessed using `R <https://www.r-project.org/>`_ through the
`reticulate <https://github.com/rstudio/reticulate>`_ package. The above example would be:

.. code-block:: R

   library(reticulate)
   py_install("lintegrate", pip = TRUE) ## run once to make sure lintegrate is installed and visible to reticulate.
   lint <- import("lintegrate", convert =FALSE)
   integrand <- function(x, args){
     mu = args[1]
     sig = args[2]
     return(-.5 * ((x-mu)/sig)^2 )
   } 
   integrand <- Vectorize(integrand)
   mu <- 0
   sig <- 1
   mmin <- -10
   mmax <- 10
   lint$lqag(py_func(integrand), r_to_py(mmin), r_to_py(mmax), c(mu, sig))
