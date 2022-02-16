lintegrate
==========

lintegrate provides a C library for `numerical integration
<https://en.wikipedia.org/wiki/Numerical_integration>`_ of functions for which numerical
instabilities require working with the `natural logarithm
<https://en.wikipedia.org/wiki/Natural_logarithm>`_ of the function.

In addition to the C library, there are Python versions of several of the core methods that are
accessed in a similar way to the SciPy :func:`~scipy.integrate.quad` function.

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   Installation <installation>
   C API <capi>
   Python API <pythonapi>
   Examples <examples>

Indices and tables
==================

* :ref:`genindex`
* :ref:`search`

.. image:: https://zenodo.org/badge/DOI/10.5281/zenodo.5913234.svg
   :target: https://doi.org/10.5281/zenodo.5913234

.. image:: https://badge.fury.io/py/lintegrate.svg
   :target: https://badge.fury.io/py/lintegrate

.. image:: https://anaconda.org/conda-forge/lintegrate/badges/version.svg
   :target: https://anaconda.org/conda-forge/lintegrate

.. image:: https://github.com/mattpitkin/lintegrate/workflows/build/badge.svg
   :target: https://github.com/mattpitkin/lintegrate/actions?query=workflow%3Abuild