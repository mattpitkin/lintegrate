import os

from .lintegrate import *

try:
    from ._version import version as __version__
except ModuleNotFoundError:
    __version__ = ""


def get_include():
    """
    Get base location containing the lintegrate package. This allows the path
    to be included in other Cython packages that want to use lintegrate cdef
    functions.
    """

    import lintegrate

    return os.path.split(lintegrate.__file__)[0].strip("lintegrate")

