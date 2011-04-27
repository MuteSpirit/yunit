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
CND_CONF=Debug
CND_DISTDIR=dist

# Include project Makefile
include Makefile

# Object Directory
OBJECTDIR=build/${CND_CONF}/${CND_PLATFORM}

# Object Files
OBJECTFILES= \
	${OBJECTDIR}/_ext/1472/thunk.o \
	${OBJECTDIR}/_ext/1472/test.o \
	${OBJECTDIR}/_ext/1472/ltest.o


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
LDLIBSOPTIONS=-Wl,-rpath ../../lua/lua51lib/../../_bin -L../../lua/lua51lib/../../_bin -llua5.1

# Build Targets
.build-conf: ${BUILD_SUBPROJECTS}
	"${MAKE}"  -f nbproject/Makefile-Debug.mk ../../_bin/libcppunit.so

../../_bin/libcppunit.so: ../../lua/lua51lib/../../_bin/liblua5.1.so

../../_bin/libcppunit.so: ${OBJECTFILES}
	${MKDIR} -p ../../_bin
	${LINK.cc} -shared -o ../../_bin/libcppunit.so -s -fPIC ${OBJECTFILES} ${LDLIBSOPTIONS} 

${OBJECTDIR}/_ext/1472/thunk.o: nbproject/Makefile-${CND_CONF}.mk ../thunk.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.cc) -g -Wall -I../.. -I/usr/include -I/usr/include/c++/4.5.1 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/thunk.o ../thunk.cpp

${OBJECTDIR}/_ext/1472/test.o: nbproject/Makefile-${CND_CONF}.mk ../test.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.cc) -g -Wall -I../.. -I/usr/include -I/usr/include/c++/4.5.1 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/test.o ../test.cpp

${OBJECTDIR}/_ext/1472/ltest.o: nbproject/Makefile-${CND_CONF}.mk ../ltest.cpp 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.cc) -g -Wall -I../.. -I/usr/include -I/usr/include/c++/4.5.1 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/ltest.o ../ltest.cpp

# Subprojects
.build-subprojects:
	cd ../../lua/lua51lib && ${MAKE}  -f Makefile CONF=Debug

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r build/Debug
	${RM} ../../_bin/libcppunit.so

# Subprojects
.clean-subprojects:
	cd ../../lua/lua51lib && ${MAKE}  -f Makefile CONF=Debug clean

# Enable dependency checking
.dep.inc: .depcheck-impl

include .dep.inc
