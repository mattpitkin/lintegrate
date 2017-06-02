/* example using lintegrate functionality */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <gsl/gsl_math.h>
#include <gsl/gsl_integration.h>

#include <lintegrate.h>

/* create function for integration */
double lintegrand(double x, void *params);

struct intparams {
  double mu;
  double sig;
};

double lintegrand(double x, void *params){
  struct intparams * p = (struct intparams *)params;
  double mu = p->mu;
  double sig = p->sig;

  return -0.5*(mu-x)*(mu-x)/(sig*sig);
}

double integrand(double x, void *params){
  struct intparams * p = (struct intparams *)params;
  double mu = p->mu;
  double sig = p->sig;

  return exp(-0.5*(mu-x)*(mu-x)/(sig*sig));
}

int main( int argv, char **argc ){
  gsl_function F;
  struct intparams params;
  gsl_integration_workspace *w = gsl_integration_workspace_alloc (100);
  double lanswer = 0., answer = 0.;
  double abserr = 0.;

  params.mu = 0.;
  params.sig = 1.;

  F.function = &lintegrand;
  F.params = &params;

  /* integrate log of function */
  lintegration_qag(&F, -6., 6., 1e-10, 1e-10, 100, GSL_INTEG_GAUSS31, w, &lanswer, &abserr);

  /* integrate function */
  F.function = &integrand;
  gsl_integration_qag(&F, -6., 6., 1e-10, 1e-10, 100, GSL_INTEG_GAUSS31, w, &answer, &abserr);

  gsl_integration_workspace_free(w);

  fprintf(stdout, "Answer 1 = %.8lf, Answer 2 = %.8lf, exact answer = %.8lf\n", lanswer, log(answer), log(sqrt(2.*M_PI)));

  return 0;
}
