# Introduction #

yUnit >= v0.3.9 does not content many needed dependencies, such as Lua, LuaFileSystem and so on. I have no time resources

# Build on Windows #

## Prepare working space ##
Install
  * CMake v2.6 or higher
  * TortoiseHg (http://mercurial.selenic.com/)
  * LuaForWindows v5.1.4 (use Full Installation and Default Installatin directory) (http://code.google.com/p/luaforwindows/)
  * C/C++ compiler, for example one of next list:
    * Microsoft Visual Studio (Visual Studio 2010 is my choise on Windows)
    * Windows SDK
    * Windows Platform SDK
    * MinGW
  * NSIS (http://nsis.sourceforge.net/)

## Get yUnit sources ##
  * Create directory for build
  * Run command line and go to that directory
  * Try one variant from next list:
    * Make a clone of yUnit repository
```
hg clone https://code.google.com/p/yunit/ yunit
```
    * Download source archive from http://code.google.com/p/yunit/downloads/list, extract into current directory and rename to 'yunit'

## Build using Visual Studio ##
  * Generate project and solution files for VS.
```
mkdir yunit_build
cd yunit_build
cmake ../yunit -G "Visual Studio 10"
```
We are using "out-of-source" build schema
  * Run Visual Studio and open yunit.sln from 'yunit\_build' subdirectory
  * Build ALL\_BUILD, RUN\_TESTS, PACKAGE projects
  * Check that build and run tests processes were executed successfully
  * There is setup program with name 'yUnit-x.x.x-win32.exe' in 'yunit\_build' subdirectory

## Build using NMake ##
  * Run 'Visual Studio Command Prompt' from Start menu
  * Go to directory with subdirectory 'yunit', containing yUnit sources
  * Generate makefiles
```
mkdir yunit_build
cd yunit_build
cmake ../yunit -G "NMake Makefiles"
```
We are using "out-of-source" build schema
  * Build
```
nmake
nmake test ARGS=--output-on-failure
nmake package
nmake package_source
```
  * Check that build and run tests processes were executed successfully
  * There are setup program with name 'yUnit-x.x.x-win32.exe' and source archive files in 'yunit\_build' subdirectory

# Build on Linux #
```
# install GCC
sudo apt-get install gcc g++ cpp 
# install CMake
sudo apt-get install cmake
# install Mercurial
sudo apt-get install mercurial-common mercurial
# install dependencies
sudo apt-get install liblua5.1-0 liblua5.1-0-dev  lua5.1
# make build directory
cd ~
mkdir ws
hg clone https://code.google.com/p/yunit/ yunit
mkdir yunit_build
cmake ../yunit
make
make test ARGS=--output-on-failure
make package
make package_source
```
> Check that build and run tests processes were executed successfully. Now there are setup program with name 'yUnit-x.x.x-Linux.deb' and source archive files in 'yunit\_build' subdirectory.