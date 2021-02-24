@echo off
rem simple Windows version of gsl-config for conda installs
set LIBRARY_PREFIX=%CONDA_PREFIX%\Library

set XCFLAGS=-I%LIBRARY_PREFIX%\include
set XLIBS1=-L%LIBRARY_PREFIX%\lib -lgsl -lgslcblas
set XLIBS2=-L%LIBRARY_PREFIX%\lib -lgsl
set XPREFIX=%LIBRARY_PREFIX%

for %%p in (%*) do (
    if x%%p == x--cflags echo %XCFLAGS%
    if x%%p == x--libs echo %XLIBS1%
    if x%%p == x--libs-without-cblas echo %XLIBS2%
    if x%%p == x--version bash "%LIBRARY_PREFIX%\bin\gsl-config" --version
    if x%%p == x--prefix echo %LIBRARY_PREFIX%
)
