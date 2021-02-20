#!/usr/bin/env python

from setuptools import setup, find_packages
from setuptools import Extension

import os
import sys
import numpy
import re
import platform
import distutils


"""
When making a new distribution use:
$ python setup.py sdist
"""


MAJOR, MINOR1, MINOR2, RELEASE, SERIAL = sys.version_info

READFILE_KWARGS = {"encoding": "utf-8"} if MAJOR >= 3 else {}


def readfile(filename):
    with open(filename, **READFILE_KWARGS) as fp:
        filecontents = fp.read()
    return filecontents

# check for Windows
WINDOWS = platform.system().lower() == "windows"

# check whether user has Cython
try:
    import Cython
except ImportError:
    have_cython = False
else:
    have_cython = True

extra_compile_args = ["-Wall", "-DHAVE_PYTHON_LINTEGRATE"]

if WINDOWS:
    extra_compile_args += ["-O2", "-DGSL_DLL", "-DWIN32"]
else:
    extra_compile_args += [
        "-O3",
        "-Wextra",
        "-m64",
        "-ffast-math",
        "-fno-finite-math-only",
        "-march=native",
        "-funroll-loops",
    ]

if have_cython:
    from Cython.Build import cythonize

    ext_modules = [
        Extension(
            "lintegrate.lintegrate",
            sources=[
                "lintegrate/lintegrate.pyx",
                "src/lintegrate_qag.c",
                "src/lintegrate_qng.c",
                "src/lintegrate_cquad.c",
            ],
            include_dirs=[
                numpy.get_include(),
                ".",
                os.popen("gsl-config --cflags").read()[2:-1],
                "src",
            ],
            library_dirs=[".", os.popen("gsl-config --libs").read().split()[0][2:]],
            libraries=["gsl", "gslcblas"],
            extra_compile_args=extra_compile_args,
        )
    ]
    ext_modules = cythonize(ext_modules)
else:
    ext_modules = [
        Extension(
            "lintegrate.lintegrate",
            sources=[
                "lintegrate/lintegrate.c",
                "src/lintegrate_qag.c",
                "src/lintegrate_qng.c",
                "src/lintegrate_cquad.c",
            ],
            include_dirs=[
                numpy.get_include(),
                ".",
                os.popen("gsl-config --cflags").read()[2:-1],
                "src",
            ],
            library_dirs=[".", os.popen("gsl-config --libs").read().split()[0][2:]],
            libraries=["gsl", "gslcblas"],
            extra_compile_args=extra_compile_args,
        )
    ]


# get version string for pyx file (see e.g. https://packaging.python.org/single_source_version/)
def find_version():
    fp = open("lintegrate/__init__.py", "r")
    version_file = fp.read()
    fp.close()
    version_match = re.search(r"^__version__ = ['\"]([^'\"]*)['\"]", version_file, re.M)
    if version_match:
        return version_match.group(1)
    raise RuntimeError("Unable to find version string.")


with open("requirements.txt") as requires_file:
    requirements = requires_file.read().split("\n")

setup(
    name="lintegrate",
    version=find_version(),
    url="https://github.com/mattpitkin/lintegrate",
    description="Python functions implementing numerical integration of functions in log-space.",
    long_description=readfile(os.path.join(os.path.dirname(__file__), "README.md")),
    long_description_content_type="text/markdown",
    author="Matthew Pitkin",
    author_email="m.pitkin@lancaster.ac.uk",
    packages=find_packages(),
    setup_requires=["numpy", "cython", "setuptools_scm"],
    install_requires=requirements,
    ext_modules=ext_modules,
    license="GPL",
    classifiers=[
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: GNU General Public License (GPL)",
        "Operating System :: POSIX :: Linux",
        "Programming Language :: Python",
        "Programming Language :: C",
        "Natural Language :: English",
    ],
)
