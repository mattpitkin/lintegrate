# -*- coding: utf-8 -*-

"""
When making a new distribution use:
$ python setup.py sdist
"""

import os
import re
import subprocess
from pathlib import Path
from setuptools import (
    Extension,
    setup,
)

import numpy

from Cython.Build import cythonize

ROOT = Path(__file__).parent
WINDOWS = os.name == "nt"
CONDA = os.environ.get("CONDA_BUILD", 0)


def readfile(filename):
    with open(filename, encoding="utf-8") as fp:
        return fp.read()


def gsl_config(*args, **kwargs):
    """Run gsl-config and return pre-formatted output"""
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
elif CONDA:
    extra_compile_args += [
        "-O3",
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
ext_modules = cythonize(
    [
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
                "lintegrate",
            ],
            library_dirs=[
                gsl_config("--libs").split(" ")[0][2:],
            ],
            libraries=[
                "gsl",
            ],
            extra_compile_args=extra_compile_args,
        ),
    ],
    language_level="3",
)


setup(
    version=find_version(),
    ext_modules=ext_modules,
)
