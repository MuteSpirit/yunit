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
	${OBJECTDIR}/thunk.o \
	${OBJECTDIR}/test.o \
	${OBJECTDIR}/ltest.o


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
LDLIBSOPTIONS=

# Build Targets
.build-conf: ${BUILD_SUBPROJECTS}
	"${MAKE}"  -f nbproject/Makefile-Release.mk dist/_bin/libcppunit.so

dist/_bin/libcppunit.so: ${OBJECTFILES}
	${MKDIR} -p dist/_bin
	${LINK.cc} -shared -o ${CND_DISTDIR}/_bin/libcppunit.so -s -fPIC ${OBJECTFILES} ${LDLIBSOPTIONS} 

${OBJECTDIR}/thunk.o: nbproject/Makefile-${CND_CONF}.mk thunk.cpp 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.cc) -O2 -Wall -I.. -I/usr/include -I/usr/include/c++/4.5.1 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/thunk.o thunk.cpp

${OBJECTDIR}/test.o: nbproject/Makefile-${CND_CONF}.mk test.cpp 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.cc) -O2 -Wall -I.. -I/usr/include -I/usr/include/c++/4.5.1 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/test.o test.cpp

${OBJECTDIR}/ltest.o: nbproject/Makefile-${CND_CONF}.mk ltest.cpp 
	${MKDIR} -p ${OBJECTDIR}
	${RM} $@.d
	$(COMPILE.cc) -O2 -Wall -I.. -I/usr/include -I/usr/include/c++/4.5.1 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/ltest.o ltest.cpp

# Subprojects
.build-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r build/Release
	${RM} dist/_bin/libcppunit.so

# Subprojects
.clean-subprojects:

# Enable dependency checking
.dep.inc: .depcheck-impl

include .dep.inc
