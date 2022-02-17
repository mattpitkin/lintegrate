---
title: 'lintegrate: A C/Python numerical integration library for working in log-space'
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
quadrature) functions provided within the GSL library [@GSL]. However, in situations where the
integrand has an extremely large dynamic range these GSL functions can fail due to numerical
instability. One way to get around numerical instability issues is to work with the natural
logarithm of the function. You cannot simply integrate the logarithm of the function as this will
not give the integral of the original function. lintegrate provides a range of C integration
functions, equivalent to functions in GSL, that allow you to integrate a function when only working
with the natural logarithm of the function is computationally practical. The result returned is the
natural logarithm of the integral of the underlying function. lintegrate also provides a Python
module for accessing some of these functions in Python.

# Statement of need

A particular case where the natural logarithm of a function is generally numerically favourable is
when evaluating likelihoods in statistical applications. For example, the Gaussian likelihood of a
model $m(\vec{\theta})$, defined by a set of model parameters $\vec{\theta}$ and given a data set
$\mathbf{d}$ consisting $N$ points, is

\begin{equation}\label{eq:likelihood}
L(\vec{\theta}) \propto \exp{\left(-\sum_{i=1}^N \frac{(d_i - m_i(\vec{\theta}))^2}{2\sigma_i^2}\right)},
\end{equation}

where $\sigma_i^2$ is an estimate of the noise variance for point $i$. Evaluating the exponent for a
range of $\vec{\theta}$ values will often lead to a numbers that breach the limits of values that
are storable as double precision floating point numbers and/or have an extremely large dynamic
range. In these cases, if you wanted to marginalise (i.e., integrate) over some subset of the
parameters $\vec{\theta}$, e.g., 

\begin{equation}\label{eq:Z}
Z = \int_{\theta_1} L(\vec{\theta}) \pi(\theta_1) {\rm d}\theta_1,
\end{equation}

where $\pi(\theta_1)$ is the prior probability distribution for the parameter $\theta_1$, you cannot
work directly with \autoref{eq:likelihood}. Instead you must work with the natural logarithm of the
likelihood:

\begin{equation}\label{eq:lnlikelihood}
\ln{L(\vec{\theta})} = C - \sum_{i=1}^N \frac{(d_i - m_i(\vec{\theta}))^2}{2\sigma_i^2}.
\end{equation}

lintegrate allows you to calculate the logarithm of $Z$ in \autoref{eq:Z}, while working with the
natural logarthim of integrands such as in \autoref{eq:lnlikelihood}.

lintegrate was originally developed to marginalise probability distributions for the hierarchical
Bayesian inference of pulsar ellipticity distributions in `@Pitkin:2008`. In `@Nash:2019` and
`@Strauss:2021`, lintegrate has been used to calculate "true" value of integrals to compare against
values learned or inferred through other methods as a form of validation.

# Acknowledgements

We thank Luiz Max F. Carvalho for adding an example of accessing the library through R. We thank
Duncan Macleod for help with packaging the library for distribution via conda.

# References