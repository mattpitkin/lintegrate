import numpy as np
cimport numpy as np

from numpy.math cimport LOGE2, INFINITY

from libc.math cimport exp, sqrt, log, log10, isinf, fabs

DTYPE = np.float64
ctypedef np.float64_t DTYPE_t


cdef double logtrapzC(np.ndarray[DTYPE_t, ndim=1] lx, np.ndarray[DTYPE_t, ndim=1] t)
cdef double logplus(double x, double y)
