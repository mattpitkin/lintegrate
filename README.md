# lintegrate

A numerical integration routine that works for the natural logarithm of functions

This library provides a numerical integration function, heavily based on the GSL [`gsl_integration_qag`](https://www.gnu.org/software/gsl/manual/html_node/QAG-adaptive-integration.html#QAG-adaptive-integration)
function, to integrate a function when only its natural logarithm is given, and return the
natural logarithm of that integral. This can be useful when, e.g., you have a log Gaussian likelihood
function (in cases where the exponentiation of the Gaussian function would lead to zeros or infinities)
and you want to numerically find the integral of the Gaussian function itself.

## Requirements

* [GSL](https://www.gnu.org/software/gsl/) - on Debian/Ubuntu (16.04) install with e.g. `sudo apt-get install libgsl-dev`

## Installation

The library can be built using [scons](http://scons.org) by just typing `scons` in the base directory. To install
the library system-wide (in `/usr/local/lib` by default) run:
```
sudo scons
sudo scons install
```

&copy; 2017 Matthew Pitkin
