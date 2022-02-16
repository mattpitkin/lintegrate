Examples
========

Here we show a selection of examples of using the lintegrate C library functions. A Linux Makefile
for the three examples can be found `here
<https://github.com/mattpitkin/lintegrate/blob/master/example/Makefile>`_.

Example 1
---------

In this example the :func:`lintegration_qag`, :func:`lintegration_qng` and
:func:`lintegration_cquad` functions are used to evaluate the integral of a Gaussian function in
log-space. The outputs are compared to the result of integration the original function using the GSL
:c:func:`gsl_integration_qag` function.

.. rli:: https://raw.githubusercontent.com/mattpitkin/lintegrate/master/example/example.c
   :language: c

Example 2
---------

In this example the :func:`lintegration_qag`, :func:`lintegration_qng` and
:func:`lintegration_cquad` functions are used to evaluate the integral of flat function in
log-space. The outputs are compared to the result of integration the original function using the GSL
:c:func:`gsl_integration_qag` function.

.. rli:: https://raw.githubusercontent.com/mattpitkin/lintegrate/master/example/example_flat.c
   :language: c

Example 3
---------

In this example the :func:`lintegration_qag_split`, :func:`lintegration_qng_split` and
:func:`lintegration_cquad_split` functions are used to evaluate the integral of function that is
very tightly peaked log-space. The outputs are compared to an analytical calculation of the integral
of original function found using `Wolfram Alpha <https://www.wolframalpha.com/>`_.

.. rli:: https://raw.githubusercontent.com/mattpitkin/lintegrate/master/example/example_split.c
   :language: c