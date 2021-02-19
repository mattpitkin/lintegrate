"""
Test script for lintegrate module.
"""

import os
import pytest
import numpy as np


def integrand(x, args):
    """
    Logarithm of a Gaussian distribution.
    """

    mu, sig = args  # unpack extra arguments
    return -0.5*((x-mu)/sig)**2 -0.5*np.log(2.*np.pi*sig**2)


class TestLintegrate(object):
    """
    Tests for different integration methods.
    """

    xmin = -8.  # minimum of x-range
    xmax = 8.   # maximum of x-range
    N = 500     # number of points in x

    # points at which to evaluate the integral
    xs = np.linspace(xmin, xmax, N)

    # mean and sigma of Gaussian
    mu = 0.
    sigma = 1.

    def test_logtrapz(self):
        from lintegrate import logtrapz

        f = integrand

        with pytest.raises(TypeError):
            # test when second argument is wrong type
            logtrapz(f, 1, args=(self.mu, self.sigma))

        with pytest.raises(RuntimeError):
            logtrapz(f, self.xs, 'kgskdg')

        with pytest.raises(AssertionError):
            logtrapz(f, [self.xs[0]], args=(self.mu, self.sigma))

        # wrong integrand function type
        with pytest.raises(RuntimeError):
            logtrapz('kgsdk', self.xs)

        # evaluate the integrand
        feval = integrand(self.xs, (self.mu, self.sigma))

        with pytest.raises(TypeError):
            logtrapz(feval, 'jhfs', args=(self.mu, self.sigma))

        with pytest.raises(AssertionError):
            logtrapz(feval, self.xs[0:10], args=(self.mu, self.sigma))

        with pytest.raises(AssertionError):
            logtrapz(feval, -1., args=(self.mu, self.sigma))

        # check consistency of results
        r1 = logtrapz(f, self.xs, args=(self.mu, self.sigma))
        r2 = logtrapz(feval, self.xs)
        r3 = logtrapz(feval, np.diff(self.xs)[0])
        r4 = logtrapz(feval, self.xs, disable_checks=True)

        assert (r1 == r2)
        assert np.abs(r2 - r3) < 1e-13
        assert np.abs(r2 - r4) < 1e-13

        # check result is a small number, i.e., np.exp(res) ~ 1
        assert np.abs(r1) < 1e-9

    def test_lqag(self):
        """
        Test QAG integration.
        """

        from lintegrate import lqag

        f = integrand

        with pytest.raises(RuntimeError):
            lqag('blah', self.xmin, self.xmax, args=(self.mu, self.sigma))

        with pytest.raises(AssertionError):
            # interval ranges are the wrong way round
            lqag(f, self.xmax, self.xmin, args=(self.mu, self.sigma))

        with pytest.raises(ValueError):
            lqag(f, self.xmin, self.xmax, args=(self.mu, self.sigma),
                 intervaltype='Blah')

        res = lqag(f, self.xmin, self.xmax, args=(self.mu, self.sigma))

        assert len(res) == 2
        assert np.abs(res[0]) < 1e-9

    def test_lqng(self):
        """
        Test QNG integration.
        """

        from lintegrate import lqng

        f = integrand

        with pytest.raises(RuntimeError):
            lqng('blah', self.xmin, self.xmax, args=(self.mu, self.sigma))

        with pytest.raises(AssertionError):
            # interval ranges are the wrong way round
            lqng(f, self.xmax, self.xmin, args=(self.mu, self.sigma))

        with pytest.raises(ValueError):
            lqng(f, self.xmin, self.xmax, args=(self.mu, self.sigma),
                 intervaltype='Blah')

        res = lqng(f, self.xmin, self.xmax, args=(self.mu, self.sigma))

        assert len(res) == 3
        assert np.abs(res[0]) < 1e-9

    def test_lcquad(self):
        """
        Test CQUAD integration.
        """

        from lintegrate import lcquad

        f = integrand

        with pytest.raises(RuntimeError):
            lcquad('blah', self.xmin, self.xmax, args=(self.mu, self.sigma))

        with pytest.raises(AssertionError):
            # interval ranges are the wrong way round
            lcquad(f, self.xmax, self.xmin, args=(self.mu, self.sigma))

        with pytest.raises(ValueError):
            lcquad(f, self.xmin, self.xmax, args=(self.mu, self.sigma),
                   intervaltype='Blah')

        res = lcquad(f, self.xmin, self.xmax, args=(self.mu, self.sigma))

        assert len(res) == 3
        assert np.abs(res[0]) < 1e-9
