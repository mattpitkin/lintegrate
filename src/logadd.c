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

#include <gsl/gsl_math.h>
#include <gsl/gsl_sf_log.h>

/* function to perform log(exp(lna) + exp(lnb)) maintaining numerical precision */
static double logaddexp(const double x, const double y);

/* function to perform log(exp(lna) - exp(lnb)) maintaining numerical precision */
static double logsubexp(const double x, const double y);

#define LOGDIFF(x, y) ((x) < (y) ? logsubexp(y, x) : logsubexp(x, y))

/* function to perform log(exp(lna) + exp(lnb)) maintaining numerical precision */
double logaddexp(const double x, const double y){
  if ( x == y ){ return x + M_LN2; }
  else{
    double tmp = x - y;
    if ( tmp > 0. ){
      return x + gsl_sf_log_1plusx(exp(-tmp));
    }
    else if ( tmp <= 0. ){
      return y + gsl_sf_log_1plusx(exp(tmp));
    }
    else{
      return tmp;
    }
  }
}

/* function to perform log(exp(lna) - exp(lnb)) maintaining numerical precision */
double logsubexp(const double x, const double y){
  double tmp = x - y;
  if ( tmp/fabs(x) > GSL_DBL_EPSILON ){ /* numbers smaller than just cause numerical noise */
    return x + gsl_sf_log_1plusx(-exp(-tmp));
  }
  else{
    return -INFINITY;
  }
}
