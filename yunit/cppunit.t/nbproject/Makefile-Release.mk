#
# Generated Makefile - do not edit!
#
# Edit the Makefile in the project folder instead (../Makefile). Each target
# has a -pre and a -post target defined where you can add customized code.
#
# This makefile implements configuration specific macros and targets.


# Environment
MKDIR=mkdir
CP=cp
GREP=grep
NM=nm
CCADMIN=CCadmin
RANLIB=ranlib
CC=gcc
CCC=g++-4.5
CXX=g++-4.5
FC=
AS=as

# Macros
CND_PLATFORM=GNU-Linux-x86
CND_CONF=Release
CND_DISTDIR=dist

# Include project Makefile
include Makefile

# Object Directory
OBJECTDIR=build/${CND_CONF}/${CND_PLATFORM}

# Object Files
OBJECTFILES= \
	${OBJECTDIR}/_ext/1472/test.t.o


# C Compiler Flags
CFLAGS=

# CC Compiler Flags
CCFLAGS=
CXXFLAGS=

# Fortran Compiler Flags
FFLAGS=

# Assembler Flags
ASFLAGS=

# Link Libraries and Options
LDLIBSOPTIONS=-Wl,-rpath ../cppunit/../../_bin -L../cppunit/../../_bin -lcppunit

# Build Targets
.build-conf: ${BUILD_SUBPROJECTS}
	"${MAKE}"  -f nbproject/Makefile-Release.mk ../../_bin/libcppunit.t.so

../../_bin/libcppunit.t.so: ../cppunit/../../_bin/libcppunit.so

../../_bin/libcppunit.t.so: ${OBJECTFILES}
	${MKDIR} -p ../../_bin
	${LINK.cc} -shared -o ../../_bin/libcppunit.t.so -fPIC ${OBJECTFILES} ${LDLIBSOPTIONS} 

${OBJECTDIR}/_ext/1472/test.t.o: ../test.t.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.cc) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/test.t.o ../test.t.cpp

# Subprojects
.build-subprojects:
	cd ../cppunit && ${MAKE}  -f Makefile CONF=Release
	cd ../cppunit && ${MAKE}  -f Makefile CONF=Release

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r build/Release
	${RM} ../../_bin/libcppunit.t.so

# Subprojects
.clean-subprojects:
	cd ../cppunit && ${MAKE}  -f Makefile CONF=Release clean
	cd ../cppunit && ${MAKE}  -f Makefile CONF=Release clean

# Enable dependency checking
.dep.inc: .depcheck-impl

include .dep.inc
