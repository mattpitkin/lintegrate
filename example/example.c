/* example using lintegrate functionality */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_integration.h>

#include <lintegrate.h>

/* create function for integration */
double lintegrand(double x, void *params);

double lintegrand(double x, void *params){
  mu = (double)params->mu;
  sig = (double)params->sig;

  return -0.5*(mu-x)*(mu-x)/(sig*sig);
}

struct intparams {
  double mu;
  double sig;
};

int main( int argv, char **argc ){
  gsl_function F;
  struct intparams params;
  gsl_integration_workspace *w = gsl_integration_workspace_alloc (100);
  double answer = 0.;
  double anserr = 0.;

  params.mu = 0.;
  params.sig = 1.;

  F.function = &lintegrand;
  F.params = &params;

  lintegration_qag(&F, -5., 5., 1e-10, 1e-10, 100, GSL_INTEG_GAUSS31, w, &answer, &abserr);

  gsl_integration_workspace_free(w);

  return 0;
}
