import os
import sys
import re
import enscons
import pytoml as toml
import numpy
from SCons.Builder import Builder
from subprocess import Popen


# build Cython file
cythonexists = True
try:
    import cython
except ImportError:
    cythonexists = False


def find_version():
    fp = open('lintegrate/__init__.py', 'r')
    version_file = fp.read()
    fp.close()
    version_match = re.search(r"^__version__ = ['\"]([^'\"]*)['\"]", version_file, re.M)
    if version_match:
        return version_match.group(1)
    raise RuntimeError("Unable to find version string.")


# check if prefix is set
AddOption('--prefix', dest='prefix', type='string', nargs=1,
          action='store', metavar='DIR', default='/usr/local',
          help='Installation Prefix')

AddOption('--user', dest='user', action='store_true', default=False,
          help='Install as pip-like "--user" (this overrides "--prefix")')


metadata = dict(toml.load(open('pyproject.toml')))['tool']['enscons']
metadata['version'] = find_version()

# most specific binary, non-manylinux1 tag should be at the top of this list
import wheel.pep425tags
full_tag = '-'.join(next(tag for tag in wheel.pep425tags.get_supported() if not 'manylinux' in tag))

# full_tag = py2.py3-none-any # pure Python packages compatible with 2+3

def generate_actions(source, target, env, for_signature):
        return "cython {} -o {}".format(source[0], target[0])

cythonbld = Builder(generator=generate_actions, suffix=".c", src_suffix=".pyx")

env = Environment(tools=['default', 'packaging', enscons.generate],
                  PACKAGE_METADATA=metadata,
                  WHEEL_TAG=full_tag,
                  BUILDERS={'Cython': cythonbld})

if cythonexists:
    env.Cython(Glob('lintegrate/*.pyx'))

# set the compiler
env['CC'] = 'gcc'

conf = Configure(env)

# check for GSL/CBLAS library
if not conf.CheckLibWithHeader('gsl', 'gsl/gsl_cdf.h', 'c'):
    print("Error... could not find GSL library")
    Exit(1)

if not conf.CheckLib('gslcblas'):
    print("Error... could not find GSLcblas library")
    Exit(1)

env = conf.Finish()

# get Python information
if sys.version_info[0] < 3:
    pythonconfig = os.popen('python3-config --cflags').read().split()
else:
    pythonconfig = os.popen('python2-config --cflags').read().split()

# set the CPPFLAGS
env.Append(CPPFLAGS=['-O3', '-DHAVE_PYTHON_LINTEGRATE', '-Wall', '-Wextra', '-m64', '-ffast-math', '-fno-finite-math-only', '-march=native', '-funroll-loops', os.popen('gsl-config --libs').read().split()[1:], pythonconfig])
env.Append(CPPPATH=[numpy.get_include(), 'src', os.popen('gsl-config --cflags').read().split()[0][2:], os.popen('gsl-config --libs').read().split()[0][2:]])

libs = []

# compile libraries
libsources = ['src/lintegrate_qag.c', 'src/lintegrate_qng.c', 'src/lintegrate_cquad.c', 'lintegrate/lintegrate.c']
sharedlib = env.SharedLibrary(target='lintegrate/liblintegrate', source=libsources)
staticlib = env.StaticLibrary(target='lintegrate/liblintegrate', source=libsources)
libs += sharedlib

py_source = Glob('lintegrate/*.py', 'lintegrate/liblintegrate.so')

platlib = env.Whl('platlib', py_source + libs, root='')
whl = env.WhlFile(source=platlib)

# Add automatic source files, plus any other needed files.
sdist_source=list(set(FindSourceFiles() +
                  ['PKG-INFO', 'setup.py'] +
                  Glob('src/*.c') + Glob('src/*.h') + Glob('lintegrate/*.pyx') + Glob('lintegrate/*.c')))

sdist_source += py_source

sdist = env.SDist(source=sdist_source)
env.Alias('sdist', sdist)

if GetOption('user'):
    install = env.Command("#DUMMY", whl, ' '.join([sys.executable, '-m', 'pip', 'install', '--no-deps', '--user', '$SOURCE']))
else:
    install = env.Command("#DUMMY", whl, ' '.join([sys.executable, '-m', 'pip', 'install', '--no-deps', '$SOURCE']))
env.Alias('install', install)
env.AlwaysBuild(install)

env.Default(sdist)
