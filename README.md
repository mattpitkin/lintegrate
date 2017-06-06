# lintegrate

A numerical integration routine that works for the natural logarithm of functions

This library provides a couple of numerical integration functions, heavily based on the GSL functions, to integrate a function when only its
natural logarithm is given, and return the natural logarithm of that integral. The two functions are equivalents of the GSL functions:
 * [`gsl_integration_qag`](https://www.gnu.org/software/gsl/manual/html_node/QAG-adaptive-integration.html#QAG-adaptive-integration)
 * [`gsl_integration_qng`](https://www.gnu.org/software/gsl/manual/html_node/QNG-non_002dadaptive-Gauss_002dKronrod-integration.html#QNG-non_002dadaptive-Gauss_002dKronrod-integration)

and are called `lintegrate_qag` and `lintegrate_qng` respectively. These can be useful when, e.g., you have a log Gaussian likelihood function
(in cases where the exponentiation of the Gaussian function would lead to zeros or infinities) and you want to numerically find the integral of
the Gaussian function itself.

## Example

An [example](example/example.c) of the use of both functions is:

```C
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
  double qaganswer = 0., qnganswer = 0., answer = 0.;
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

  /* integrate function using GSL QAG */
  F.function = &integrand;
  gsl_integration_qag(&F, minlim, maxlim, abstol, reltol, 100, GSL_INTEG_GAUSS31, w, &answer, &abserr);

  gsl_integration_workspace_free(w);

  fprintf(stdout, "Answer \"lintegrate QAG\" = %.8lf\n", qaganswer);
  fprintf(stdout, "Answer \"lintegrate QNG\" = %.8lf\n", qnganswer);
  fprintf(stdout, "Answer \"gsl_integrate_qag\" = %.8lf\n", log(answer));
  fprintf(stdout, "Analytical answer = %.8lf\n", log(sqrt(2.*M_PI)));

  return 0;
}
```

## Requirements

* [GSL](https://www.gnu.org/software/gsl/) - on Debian/Ubuntu (16.04) install with e.g. `sudo apt-get install libgsl-dev`

## Installation

The library can be built using [scons](http://scons.org) by just typing `scons` in the base directory. To install
the library system-wide (in `/usr/local/lib` by default) run:
```
sudo scons
sudo scons install
```

Python wrappers to the functions can be built in the `python` directory by running, e.g.:
```
sudo python setup.py install
```
for a system-wide install (add `--user` and remove `sudo` if just wanting to install for a single user).

## Python

If the Python module has been installed it has the following functions:
 * `lqng` - a wrapper to `lintegration_qng`
 * `lqag` - a wrapper to `lintegration_qag`
 * `logtrapz` - using the trapezium rule for integration on a grid of values

The `lqng` and `lqag` functions are used in a similar way to the scipy [`quad`](https://docs.scipy.org/doc/scipy-0.19.0/reference/generated/scipy.integrate.quad.html) function.

An example of their use would be:

```python
from lintegrate import lqag

# define the log of the function to be integrated
def chisqfunc(x, args):
    mu, sig = args # unpack extra arguments
    return -0.5*((x-mu)/sig)**2

# set integration limits
xmin = -6.
xmax = 6.

# set additional arguments
mu = 0.
sig = 1.

res = lqag(chi, xmin, xmax, args=(mu, sig))
```

&copy; 2017 Matthew Pitkin
