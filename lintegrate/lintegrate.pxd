import numpy as np
cimport numpy as np

from numpy.math cimport LOGE2, INFINITY

from libc.math cimport exp, sqrt, log, log10, isinf, fabs

cdef extern from "gsl/gsl_integration.h":
    void gsl_integration_workspace_free (gsl_integration_workspace * w)
    ctypedef struct gsl_integration_workspace
    gsl_integration_workspace * gsl_integration_workspace_alloc (size_t n)
    void gsl_integration_cquad_workspace_free (gsl_integration_cquad_workspace * w)
    ctypedef struct gsl_integration_cquad_workspace
    gsl_integration_cquad_workspace * gsl_integration_cquad_workspace_alloc (size_t n)

cdef extern from "gsl/gsl_sf_log.h":
    double gsl_sf_log_1plusx(double x)

cdef extern from "lintegrate.h":
    ctypedef double (*pylintfunc)(double x, void *funcdata, void *args)
    int lintegration_qng (pylintfunc f, void *funcdata, void *args, double a, double b, double epsabs, double epsrel, double *result, double *abserr, size_t *neval)
    int lintegration_qag (pylintfunc f, void *funcdata, void *args, double a, double b, double epsabs, double epsrel, size_t limit, int key, gsl_integration_workspace * workspace, double * result, double * abserr)
    int lintegration_cquad (pylintfunc f, void *funcdata, void *args, double a, double b, double epsabs, double epsrel, gsl_integration_cquad_workspace * ws, double *result, double *abserr, size_t * nevals)


DTYPE = np.float64
ctypedef np.float64_t DTYPE_t


cdef double logtrapzC(np.ndarray[DTYPE_t, ndim=1] lx, np.ndarray[DTYPE_t, ndim=1] t)
cdef double logplus(double x, double y)
