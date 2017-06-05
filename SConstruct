import os
import sys

# add a --prefix option for the installation path
AddOption('--prefix', dest='prefix', type='string', nargs=1,
          action='store', metavar='DIR', default='/usr/local',
          help='Installation Prefix')

env = Environment()

# set the compiler
env['CC'] = 'gcc'

# set potential library paths
env.Append(LIBPATH=['/usr/lib', '/usr/local/lib', '/usr/lib/x86_64-linux-gnu'])

# set potential include paths
env.Append(CPPPATH=['/usr/include/', '/usr/local/include/'])

# install prefix
env = Environment(PREFIX=GetOption('prefix'))

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

# create libraries
sharedlib = env.SharedLibrary('liblintegrate', ['src/lintegrate_qag.c', 'src/qkrules.c', 'src/lintegrate_qng.c'])
staticlib = env.StaticLibrary('liblintegrate', ['src/lintegrate_qag.c', 'src/qkrules.c', 'src/lintegrate_qng.c'])

# install libraries
installlibDir = os.path.join(env['PREFIX'], 'lib')
if not os.path.isdir(installlibDir):
  print("Error... install directory '%s' is not present" % installlibDir)
  sys.exit(1)

sharedinstall = env.Install(installlibDir, sharedlib)
staticinstall = env.Install(installlibDir, staticlib)

installlist = [sharedinstall, staticinstall]

# install headers
hfiles = Glob('src/*.h')

installhdir = os.path.join(env['PREFIX'], 'include/lintegrate')
if not os.path.isdir(installhdir):
  # try making directory
  try:
    os.makedirs(installhdir)
  except:
    print("Error... could not create '%s' directory" % installhdir)
    sys.exit(1)

hinstall = env.Install(installhdir, hfiles)
installlist.append(hinstall)

# create an 'install' target
env.Alias('install', installlist)

