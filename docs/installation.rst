Installation
============

The lintegrate library requires that you have the `GNU Scientific Library (GSL)
<https://www.gnu.org/software/gsl/>`_ installed on your system. In particular, the development
version of the library is required, so that the header files are present.

For Linux systems, GSL can be installed with:

.. tabbed:: Debian-based

    .. code-block:: console

        $ sudo apt install libgsl-dev

.. tabbed:: Red Hat-based

    .. code-block:: console

        $ sudo yum install gsl-devel

.. tabbed:: openSUSE-based

    .. code-block:: console

        $ sudo zypper install gsl-devel

For Mac OS, GSL can be installed with: 

.. code-block:: console

    $ brew install gsl

For Windows you can install lintegrate via :ref:`Conda`, which will automatically include
dependencies such as GSL.

Installing from source
----------------------

The C library of lintegrate can be installed on Linux and Mac OS systems from the source hosted on
`GitHub <https://github.com/mattpitkin/lintegrate>`_. This requires the `SCons
<https://scons.org/>`_ software construction tool. The source repository can be cloned with:

.. tabbed:: HTTPS

   .. code-block:: console

      $ git clone https://github.com/mattpitkin/lintegrate.git

.. tabbed:: ssh

   .. code-block:: console

      $ git clone git@github.com:mattpitkin/lintegrate.git

.. tabbed:: GitHub CLI

   .. code-block:: console

      $ gh repo clone mattpitkin/lintegrate

After cloning, build and install the library with:

.. code-block:: console
    
    $ sudo scons
    $ sudo scons install

Python package
^^^^^^^^^^^^^^

The Python package can also be installed by running:

.. code-block:: console

    $ pip install .

PyPI
----

To install lintegrate using pip from the `PyPI repository <https://pypi.org/project/lintegrate/>`_
`GSL <https://www.gnu.org/software/gsl/>`_ must be already installed on your system. lintegrate can
then be installed with:

.. code-block:: console

    $ pip install lintegrate

Conda
-----

lintegrate can be installed on Linux, Mac OS, or Windows, without having to pre-install any
dependencies by using the `conda-forge <https://anaconda.org/conda-forge/lintegrate>`_ version of
the package. This can be done via the Anaconda Navigator or on the command line using:

.. code-block:: console

    $ conda install -c conda-forge lintegrate

Contributing
------------

Contributions to lintegrate, either to the C library or the Python wrapper, are welcome. Issues can
be raised via the GitHub `issue tracker <https://github.com/mattpitkin/lintegrate/issues>`_ and
`pull requests <https://github.com/mattpitkin/lintegrate/pulls>`_ are encouraged.