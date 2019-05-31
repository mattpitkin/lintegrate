import os
import sys


def build_library():
    # add a --prefix option for the installation path
    AddOption('--prefix', dest='prefix', type='string', nargs=1,
              action='store', metavar='DIR', default='/usr/local',
              help='Installation Prefix')

    # install prefix
    env = Environment(PREFIX=GetOption('prefix'))

    # set the compiler
    env['CC'] = 'gcc'

    # set potential library paths
    libpaths = ['/usr/lib', '/usr/local/lib', '/usr/lib/x86_64-linux-gnu']
    try:
        gsllib = os.popen('gsl-config --libs').read().split()[0][2:]
        if gsllib not in libpaths:
            libpaths.append(gsllib)
    except:
        print("Could not find GSL libraries")  
        Exit(1)

    env.Append(LIBPATH=libpaths)

    libs = ['-lm']
    for cl in os.popen('gsl-config --libs').read().strip().split()[1:]: # add GSL flags
        if cl not in libs:
            libs.append(cl)

    env.Append(LIBS=libs)

    # set potential include paths
    includepaths = ['/usr/include/', '/usr/local/include/']
    includepaths.append(os.popen('gsl-config --cflags').read()[2:-1])

    env.Append(CPPPATH=includepaths)

    # set some compiler flags
    ccflags = ['-O3', '-Wall', '-Wextra', '-m64', '-ffast-math', '-fno-finite-math-only', '-march=native', '-funroll-loops']
    env.Append(CCFLAGS=ccflags)

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
    sharedlib = env.SharedLibrary('liblintegrate', ['src/lintegrate_qag.c', 'src/lintegrate_qng.c', 'src/lintegrate_cquad.c', 'src/lintegrate_split.c'])
    staticlib = env.StaticLibrary('liblintegrate', ['src/lintegrate_qag.c', 'src/lintegrate_qng.c', 'src/lintegrate_cquad.c', 'src/lintegrate_split.c'])

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


if os.path.split(sys.argv[0])[-1] == 'scons':
    # scons install
    build_library()
else:
    import pytoml as toml
    import enscons

    # enscons install
    print('Hello!')
    build_library()
    
    # check if prefix is set
    AddOption('--prefix', dest='prefix', type='string', nargs=1,
              action='store', metavar='DIR', default='/usr/local',
              help='Installation Prefix')

    AddOption('--user', dest='user', action='store_true', default=False,
              help='Install as pip-like "--user" (this overrides "--prefix")')

    metadata = dict(toml.load(open('pyproject.toml')))['tool']['enscons']

    # add version
    def find_version():
        fp = open('lintegrate/lintegrate.pyx', 'r')
        version_file = fp.read()
        fp.close()
        version_match = re.search(r"^__version__ = ['\"]([^'\"]*)['\"]", version_file, re.M)
        if version_match:
            return version_match.group(1)
        raise RuntimeError("Unable to find version string.")

    metadata['version'] = find_version()

    # most specific binary, non-manylinux1 tag should be at the top of this list
    import wheel.pep425tags
    full_tag = '-'.join(next(tag for tag in wheel.pep425tags.get_supported() if not 'manylinux' in tag))

    # full_tag = py2.py3-none-any # pure Python packages compatible with 2+3

    env = Environment(tools=['default', 'packaging', enscons.generate],
                      PACKAGE_METADATA=metadata,
                      WHEEL_TAG=full_tag)

    # set the compiler to gfortran
    env['CC'] = 'gcc'

    py_source = Glob('psrpoppy/*.py')

libpath = os.path.join('psrpoppy', 'fortran')

# check whether installing on a Mac
if 'Darwin' in os.uname()[0]:
    env.Append(CFLAGS=['-m 32'])
    env.Append(CPPFLAGS=['-dynamiclib', '-O2', '-fPIC', '-fno-second-underscore', '-c', '-std=legacy'])
else:
    env.Append(CPPFLAGS=['-O2', '-fPIC', '-fno-second-underscore', '-c', '-std=legacy'])

env.Append(CPPPATH=[libpath])



libs = []

# compile libraries
for libname in LIBDIC:
    lib = os.path.join(libpath, libname)
    libsources = [os.path.join(libpath, srcfile) for srcfile in LIBDIC[libname]]
    
    sharedlib = env.SharedLibrary(target=lib, source=libsources)
    #staticlib = env.StaticLibrary(target=lib, source=libsources)

    libs += sharedlib

# install prefix
if not GetOption('user'):
    installprefix=GetOption('prefix')
else: # install in --user location
    installprefix=os.path.join(os.environ['HOME'], '.local')
pyprefix='psrpoppy'
executables = ['dosurvey', 'evolve', 'populate']

# install executables
insbins = env.InstallAs(target=[os.path.join(installprefix, 'bin', ex) for ex in executables],
               source=[os.path.join(pyprefix, ex+'.py') for ex in executables])

otherfiles = Glob('psrpoppy/fortran/*.so') + Glob('psrpoppy/fortran/lookuptables/*') + Glob('psrpoppy/models/*') + Glob('psrpoppy/surveys/*')

platlib = env.Whl('platlib', py_source + libs + otherfiles, root='')
whl = env.WhlFile(source=platlib)

# Add automatic source files, plus any other needed files.
sdist_source=list(set(FindSourceFiles() +
                  ['PKG-INFO', 'setup.py'] +
                  Glob('psrpoppy/fortran/*.f') + Glob('psrpoppy/fortran/*.inc') + Glob('psrpoppy/fortran/lookuptables/*') + Glob('psrpoppy/models/*') + Glob('psrpoppy/surveys/*')))

sdist_source += py_source

sdist = env.SDist(source=sdist_source)
env.Alias('sdist', sdist)

if GetOption('user'):
    install = env.Command("#DUMMY", whl, ' '.join([sys.executable, '-m', 'pip', 'install', '--no-deps', '--user', '$SOURCE']))
else:
    install = env.Command("#DUMMY", whl, ' '.join(['PYTHONUSERBASE={}'.format(installprefix), sys.executable, '-m', 'pip', 'install', '--no-deps', '--user', '$SOURCE']))
env.Alias('install', install + insbins)
env.AlwaysBuild(install + insbins)

env.Default(sdist)
