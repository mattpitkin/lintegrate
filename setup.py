# -*- coding: utf-8 -*-

"""
When making a new distribution use:
$ python setup.py sdist
"""

import distutils
import os
import re
import subprocess
from pathlib import Path
from setuptools import (
    Extension,
    find_packages,
    setup,
)

import numpy

from Cython.Build import cythonize

ROOT = Path(__file__).parent
WINDOWS = os.name == "nt"


def readfile(filename):
    with open(filename, encoding="utf-8") as fp:
        return fp.read()


def gsl_config(*args, **kwargs):
    """Run gsl-config and return pre-formatted output
    """
    if WINDOWS:
        cmd = "gsl-config {}".format(" ".join(args))
        kwargs.setdefault("shell", True)
    else:
        cmd = ["gsl-config"] + list(args)
    return subprocess.check_output(cmd, **kwargs).decode("utf-8").strip()


def find_version():
    """Get version string for pyx file

    see e.g. https://packaging.python.org/single_source_version/
    """
    fp = open("lintegrate/__init__.py", "r")
    version_file = fp.read()
    fp.close()
    version_match = re.search(r"^__version__ = ['\"]([^'\"]*)['\"]", version_file, re.M)
    if version_match:
        return version_match.group(1)
    raise RuntimeError("Unable to find version string.")


# define ext_modules
extra_compile_args = [
    "-Wall",
    "-DHAVE_PYTHON_LINTEGRATE",
]
if WINDOWS:
    extra_compile_args += [
        "-O2",
        "-DGSL_DLL",
        "-DWIN32",
    ]
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
ext_modules = cythonize([
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
            gsl_config("--cflags")[2:],
            "src",
        ],
        library_dirs=[
            gsl_config("--libs").split(" ")[0][2:],
        ],
        libraries=[
            "gsl",
        ],
        extra_compile_args=extra_compile_args,
    ),
])


setup(
    name="lintegrate",
    version=find_version(),
    url="https://github.com/mattpitkin/lintegrate",
    description="Python functions implementing numerical integration of functions in log-space.",
    long_description=readfile(ROOT / "README.md"),
    long_description_content_type="text/markdown",
    author="Matthew Pitkin",
    author_email="m.pitkin@lancaster.ac.uk",
    packages=find_packages(),
    python_requires=">=3.6",
    setup_requires=["numpy", "cython", "setuptools_scm"],
    install_requires=readfile(ROOT / "requirements.txt").split("\n"),
    ext_modules=ext_modules,
    license="GPL-3.0-or-later",
    classifiers=[
        "Intended Audience :: Science/Research",
        "License :: OSI Approved :: GNU General Public License v3 or later (GPLv3+)",
        "Natural Language :: English",
        "Operating System :: POSIX :: Linux",
        "Programming Language :: C",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
    ],
)
