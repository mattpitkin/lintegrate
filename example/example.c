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
  gsl_integration_cquad_workspace *cw = gsl_integration_cquad_workspace_alloc(50);
  double qaganswer = 0., qnganswer = 0., cquadanswer = 0., answer = 0.;
  double abserr = 0.;
  size_t neval = 0;

  double minlim = -6.; /* minimum for integration range */
  double maxlim = 6.;  /* maximum for integration range */

  double abstol = 1e-10; /* absolute tolerance */
  double reltol = 1e-10; /* relative tolerance */

  params.mu = 0.;
  params.sig = 1.;

  F.function = &lintegrand;
  F.params = &params;

  /* integrate log of function using QAG */
  lintegration_qag(&F, minlim, maxlim, abstol, reltol, 100, GSL_INTEG_GAUSS31, w, &qaganswer, &abserr);

  /* integrate log of function using QNG */
  lintegration_qng(&F, minlim, maxlim, abstol, reltol, &qnganswer, &abserr, &neval);

  /* integrate log of function using CQUAD */
  lintegration_cquad(&F, minlim, maxlim, abstol, reltol, cw, &cquadanswer, &abserr, &neval);

  /* integrate function using GSL QAG */
  F.function = &integrand;
  gsl_integration_qag(&F, minlim, maxlim, abstol, reltol, 100, GSL_INTEG_GAUSS31, w, &answer, &abserr);

  gsl_integration_workspace_free(w);
  gsl_integration_cquad_workspace_free(cw);

  fprintf(stdout, "Answer \"lintegrate QAG\" = %.8lf\n", qaganswer);
  fprintf(stdout, "Answer \"lintegrate QNG\" = %.8lf\n", qnganswer);
  fprintf(stdout, "Answer \"lintegrate CQUAD\" = %.8lf\n", cquadanswer);
  fprintf(stdout, "Answer \"gsl_integrate_qag\" = %.8lf\n", log(answer));
  fprintf(stdout, "Analytical answer = %.8lf\n", log(sqrt(2.*M_PI)));

  return 0;
}
