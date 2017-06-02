import os

env = Environment()

# set the compiler
env['CC'] = 'gcc'

# set potential library paths
env.Append(LIBPATH=['/usr/lib', '/usr/local/lib', '/usr/lib/x86_64-linux-gnu'])

# set potential include paths
env.Append(CPPPATH=['/usr/include/', '/usr/local/include/'])

# set some compiler flags
env.Append(CCFLAGS=['-O3', '-Wall', '-Wextra', '-m64', '-ffast-math', '-fno-finite-math-only', '-flto', '-march=native', '-funroll-loops'])

conf = Configure(env)

# check for GSL/CBLAS library
if not conf.CheckLibWithHeader('gsl', 'gsl/gsl_cdf.h', 'c'):
  print("Error... could not find GSL library")
  Exit(1)

if not conf.CheckLib('gslcblas'):
  print("Error... could not find GSLcblas library")
  Exit(1)

env = conf.Finish()

# build library
env.Library('lintegrate', ['lintegrate.c', 'qkrules.c'])

