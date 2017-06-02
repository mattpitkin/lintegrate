/* Copyright (C) 2017 Matthew Pitkin
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or (at
 * your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 */
#ifndef _LINTEGRATE_H
#define _LINTEGRATE_H

#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_integration.h>
#include <gsl/gsl_sf_log.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_errno.h>

/* function to perform log(exp(lna) + exp(lnb)) maintaining numerical precision */
double logaddexp(const double x, const double y);

/* function to perform log(exp(lna) - exp(lnb)) maintaining numerical precision */
double logsubexp(const double x, const double y);

#define LOGSUBCHOOSE(x, y) ((x) < (y) ? logsubexp(y, x) : logsubexp(x, y))

void lintegration_qk (const int n, const double xgk[], 
                      const double wg[], const double wgk[],
                      double fv1[], double fv2[],
                      const gsl_function *f, double a, double b,
                      double * result, double * abserr, 
                      double * resabs, double * resasc);

void lintegration_qk15 (const gsl_function * f, double a, double b,
                        double *result, double *abserr,
                        double *resabs, double *resasc);

void lintegration_qk21 (const gsl_function * f, double a, double b,
                        double *result, double *abserr,
                        double *resabs, double *resasc);

void lintegration_qk31 (const gsl_function * f, double a, double b,
                        double *result, double *abserr,
                        double *resabs, double *resasc);

void lintegration_qk41 (const gsl_function * f, double a, double b,
                        double *result, double *abserr,
                        double *resabs, double *resasc);

void lintegration_qk51 (const gsl_function * f, double a, double b,
                        double *result, double *abserr,
                        double *resabs, double *resasc);

void lintegration_qk61 (const gsl_function * f, double a, double b,
                        double *result, double *abserr,
                        double *resabs, double *resasc);

#if HAVE_EXTENDED_PRECISION_REGISTERS
#define GSL_COERCE_DBL(x) (gsl_coerce_double(x))
#else
#define GSL_COERCE_DBL(x) (x)
#endif

#endif /* _LINTEGRATE_H */

