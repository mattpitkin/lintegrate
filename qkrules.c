/* qkrules.c
 *
 * Copyright (C) 1996, 1997, 1998, 1999, 2000, 2007 Brian Gough
 * Copyright (C) 2017 Matthew Pitkin
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

/* set various Gauss-Kronrod rule - copied/modified from GSL integration qk[15,21,31,41,51,61].c */

#ifndef _QKRULES_H
#define _QKRULES_H

#include <gsl/gsl_integration.h>

#include "qkrules.h"
#include "lintegrate.h"

void lintegration_qk15 (const gsl_function * f, double a, double b,
                        double *result, double *abserr,
                        double *resabs, double *resasc){
  double fv1[8], fv2[8];
  lintegration_qk (8, xgk15, wg15, wgk15, fv1, fv2, f, a, b, result, abserr, resabs, resasc);
}

void lintegration_qk21 (const gsl_function * f, double a, double b,
                        double *result, double *abserr,
                        double *resabs, double *resasc){
  double fv1[11], fv2[11];
  lintegration_qk (11, xgk21, wg21, wgk21, fv1, fv2, f, a, b, result, abserr, resabs, resasc);
}

void lintegration_qk31 (const gsl_function * f, double a, double b,
                        double *result, double *abserr,
                        double *resabs, double *resasc){
  double fv1[16], fv2[16];
  lintegration_qk (16, xgk31, wg31, wgk31, fv1, fv2, f, a, b, result, abserr, resabs, resasc);
}

void lintegration_qk41 (const gsl_function * f, double a, double b,
                        double *result, double *abserr,
                        double *resabs, double *resasc){
  double fv1[21], fv2[21];
  lintegration_qk (21, xgk41, wg41, wgk41, fv1, fv2, f, a, b, result, abserr, resabs, resasc);
}

void lintegration_qk51 (const gsl_function * f, double a, double b,
                        double *result, double *abserr,
                        double *resabs, double *resasc){
  double fv1[26], fv2[26];
  lintegration_qk (26, xgk51, wg51, wgk51, fv1, fv2, f, a, b, result, abserr, resabs, resasc);
}

void lintegration_qk61 (const gsl_function * f, double a, double b,
                        double *result, double *abserr,
                        double *resabs, double *resasc){
  double fv1[31], fv2[31];
  gsl_integration_qk (31, xgk61, wg61, wgk61, fv1, fv2, f, a, b, result, abserr, resabs, resasc);
}

#endif
