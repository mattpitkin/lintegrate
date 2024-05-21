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


ROOT = Path(__file__).parent
WINDOWS = os.name == "nt"
CONDA = os.environ.get("CONDA_BUILD", 0)


def gsl_config(*args, **kwargs):
    """Run gsl-config and return pre-formatted output"""
    if WINDOWS:
        cmd = "gsl-config {}".format(" ".join(args))
        kwargs.setdefault("shell", True)
    else:
        cmd = ["gsl-config"] + list(args)
    return subprocess.check_output(cmd, **kwargs).decode("utf-8").strip()


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
        "-funroll-loops",
    ]

ext_modules = [
    Extension(
        "lintegrate",
        sources=[
            "src/lintegrate.pyx",
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
            gsl_config("--libs-without-cblas").split(" ")[0][2:],
        ],
        libraries=[
            l.replace("-l", "") for l in gsl_config("--libs-without-cblas").split()[1:]
        ],
        extra_compile_args=extra_compile_args,
    ),
]


for e in ext_modules:
    e.cython_directives = {"language_level": "3"}

setup(
    ext_modules=ext_modules,
)

