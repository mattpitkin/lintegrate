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

Citation
~~~~~~~~

If using lintegrate within you research, I would be grateful if you cite the associated `JOSS paper <https://joss.theoj.org/papers/10.21105/joss.04231>`_ for the software. The following BibTeX citation can be used:

.. code-block:: bibtex

   @article{Pitkin2022,
     doi = {10.21105/joss.04231},
     url = {https://doi.org/10.21105/joss.04231},
     year = {2022},
     publisher = {The Open Journal},
     volume = {7},
     number = {73},
     pages = {4231},
     author = {Matthew Pitkin},
     title = {lintegrate: A C/Python numerical integration library for working in log-space},
     journal = {Journal of Open Source Software}
   }

You may also want to cite the `GSL <https://www.gnu.org/software/gsl/>`__ reference "*M. Galassi et al, GNU Scientific Library Reference Manual (3rd Ed.), ISBN 0954612078*" and the URL http://www.gnu.org/software/gsl/.


Indices and tables
==================

* :ref:`genindex`
* :ref:`search`

.. image:: https://joss.theoj.org/papers/10.21105/joss.04231/status.svg
   :target: https://doi.org/10.21105/joss.04231

.. image:: https://badge.fury.io/py/lintegrate.svg
   :target: https://badge.fury.io/py/lintegrate

.. image:: https://anaconda.org/conda-forge/lintegrate/badges/version.svg
   :target: https://anaconda.org/conda-forge/lintegrate

.. image:: https://github.com/mattpitkin/lintegrate/workflows/build/badge.svg
   :target: https://github.com/mattpitkin/lintegrate/actions?query=workflow%3Abuild
