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

# compile and install library
build_library()
