/* example using lintegrate_split functionality */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_integration.h>

#include <time.h>

#include <lintegrate.h>

/* create function for integration */
double lintegrand(double x, void *params);

double lintegrand(double x, void *params){
  return 1e-11/x;
}

int main( int argv, char **argc ){
  gsl_function F;

  double qaganswer = 0., cquadanswer = 0., qnganswer = 0.;
  double abserr = 0.;
  size_t neval = 0;

  double minlim = 1e-13; /* minimum for integration range */
  double maxlim = 1e-5;  /* maximum for integration range */

  /* split the interval logarithmically for integrating */
  size_t nints = 50, i = 0;
  double splits[nints+1];
  for ( i=0; i<nints+1; i++ ){
    splits[i] = pow(10., (log10(minlim) + i*(log10(maxlim)-log10(minlim))/(double)nints));
  }

  double abstol = 1e-10; /* absolute tolerance */
  double reltol = 1e-10; /* relative tolerance */

  F.function = &lintegrand;

  clock_t t1, t2;

  /* integrate log of function using QAG */
  t1 = clock();
  lintegration_qag_split(&F, splits, nints+1, abstol, reltol, 100, GSL_INTEG_GAUSS31, &qaganswer, &abserr);
  t2 = clock();
  fprintf(stderr, "lintegration_qag_split: run time = %ld mus\n", (t2-t1)*1000000/CLOCKS_PER_SEC);

  /* integrate log of function using QNG */
  t1 = clock();
  lintegration_qng_split(&F, splits, nints+1, abstol, reltol, &qnganswer, &abserr, &neval);
  t2 = clock();
  fprintf(stderr, "lintegration_qng_split: run time = %ld mus\n", (t2-t1)*1000000/CLOCKS_PER_SEC);

  /* integrate log of function using CQUAD */
  t1 = clock();
  lintegration_cquad_split(&F, splits, nints+1, abstol, reltol, 50, &cquadanswer, &abserr, &neval);
  t2 = clock();
  fprintf(stderr, "lintegration_cquad_split: run time = %ld mus\n", (t2-t1)*1000000/CLOCKS_PER_SEC);

  fprintf(stdout, "Answer \"lintegrate QAG\" = %.8lf\n", qaganswer);
  fprintf(stdout, "Answer \"lintegrate QNG\" = %.8lf\n", qnganswer);
  fprintf(stdout, "Answer \"lintegrate CQUAD\" = %.8lf\n", cquadanswer);
  fprintf(stdout, "(Approximate) Analytical answer = %.8lf\n", log(2.74356e28)); // via Wolfram Alpha

  return 0;
}
