---
title: 'lintegrate: a C/Python numerical integration library for working in log-space'
tags:
  - numerical integration
  - GSL
  - C
  - Python
authors:
  - name: Matthew Pitkin
    orcid: 0000-0003-4548-526X
    affiliation: 1
affiliations:
  - name: Department of Physics, Lancaster University, Lancaster, UK, LA1 4YB
    index: 1
date: 11 February 2022
bibliography: paper.bib
---

# Summary

There are many situation in which the integral of a function must be evaluated numerically between
given limits. For C code there are a range of numerical integration (sometimes called numerical
quadrature) functions provided within the GSL library. However, in situations where the integrand
has an extremely large dynamic range these GSL functions can fail due to numerical instability. One
way to get around numerical instability issues is to work with the natural logarithm of the
function. You cannot simply integrate the logarithm of the function as this will not give the
integral of the original function. lintegrate provides a range of C functions, equivalent to
functions in GSL, that allow you to integrate a function when only working with the natural
logarithm of the function is computationally practical. The result returned is the natural logarithm
of the integral of the underlying function.

# Acknowledgements

We thank Luiz Max F. Carvalho for adding an example of accessing the library through R. We thank
Duncan Macleod for help with packaging the library for distribution via conda.

# References