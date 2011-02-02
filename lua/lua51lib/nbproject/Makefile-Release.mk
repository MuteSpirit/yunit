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
	${OBJECTDIR}/_ext/1472/loadlib.o \
	${OBJECTDIR}/_ext/1472/ldump.o \
	${OBJECTDIR}/_ext/1472/ltablib.o \
	${OBJECTDIR}/_ext/1472/lzio.o \
	${OBJECTDIR}/_ext/1472/lparser.o \
	${OBJECTDIR}/_ext/1472/lapi.o \
	${OBJECTDIR}/_ext/1472/lauxlib.o \
	${OBJECTDIR}/_ext/1472/ldblib.o \
	${OBJECTDIR}/_ext/1472/lbaselib.o \
	${OBJECTDIR}/_ext/1472/ltm.o \
	${OBJECTDIR}/_ext/1472/lstate.o \
	${OBJECTDIR}/_ext/1472/lmathlib.o \
	${OBJECTDIR}/_ext/1472/llex.o \
	${OBJECTDIR}/_ext/1472/lstring.o \
	${OBJECTDIR}/_ext/1472/lgc.o \
	${OBJECTDIR}/_ext/1472/liolib.o \
	${OBJECTDIR}/_ext/1472/ltable.o \
	${OBJECTDIR}/_ext/1472/lcode.o \
	${OBJECTDIR}/_ext/1472/lvm.o \
	${OBJECTDIR}/_ext/1472/lfunc.o \
	${OBJECTDIR}/_ext/1472/lmem.o \
	${OBJECTDIR}/_ext/1472/lopcodes.o \
	${OBJECTDIR}/_ext/1472/linit.o \
	${OBJECTDIR}/_ext/1472/lstrlib.o \
	${OBJECTDIR}/_ext/1472/ldebug.o \
	${OBJECTDIR}/_ext/1472/lobject.o \
	${OBJECTDIR}/_ext/1472/ldo.o \
	${OBJECTDIR}/_ext/1472/loslib.o \
	${OBJECTDIR}/_ext/1472/lundump.o


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
	"${MAKE}"  -f nbproject/Makefile-Release.mk ../../_bin/liblua5.1.so

../../_bin/liblua5.1.so: ${OBJECTFILES}
	${MKDIR} -p ../../_bin
	${LINK.c} -shared -o ../../_bin/liblua5.1.so -fPIC ${OBJECTFILES} ${LDLIBSOPTIONS} 

${OBJECTDIR}/_ext/1472/loadlib.o: ../loadlib.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/loadlib.o ../loadlib.c

${OBJECTDIR}/_ext/1472/ldump.o: ../ldump.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/ldump.o ../ldump.c

${OBJECTDIR}/_ext/1472/ltablib.o: ../ltablib.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/ltablib.o ../ltablib.c

${OBJECTDIR}/_ext/1472/lzio.o: ../lzio.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lzio.o ../lzio.c

${OBJECTDIR}/_ext/1472/lparser.o: ../lparser.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lparser.o ../lparser.c

${OBJECTDIR}/_ext/1472/lapi.o: ../lapi.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lapi.o ../lapi.c

${OBJECTDIR}/_ext/1472/lauxlib.o: ../lauxlib.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lauxlib.o ../lauxlib.c

${OBJECTDIR}/_ext/1472/ldblib.o: ../ldblib.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/ldblib.o ../ldblib.c

${OBJECTDIR}/_ext/1472/lbaselib.o: ../lbaselib.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lbaselib.o ../lbaselib.c

${OBJECTDIR}/_ext/1472/ltm.o: ../ltm.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/ltm.o ../ltm.c

${OBJECTDIR}/_ext/1472/lstate.o: ../lstate.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lstate.o ../lstate.c

${OBJECTDIR}/_ext/1472/lmathlib.o: ../lmathlib.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lmathlib.o ../lmathlib.c

${OBJECTDIR}/_ext/1472/llex.o: ../llex.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/llex.o ../llex.c

${OBJECTDIR}/_ext/1472/lstring.o: ../lstring.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lstring.o ../lstring.c

${OBJECTDIR}/_ext/1472/lgc.o: ../lgc.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lgc.o ../lgc.c

${OBJECTDIR}/_ext/1472/liolib.o: ../liolib.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/liolib.o ../liolib.c

${OBJECTDIR}/_ext/1472/ltable.o: ../ltable.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/ltable.o ../ltable.c

${OBJECTDIR}/_ext/1472/lcode.o: ../lcode.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lcode.o ../lcode.c

${OBJECTDIR}/_ext/1472/lvm.o: ../lvm.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lvm.o ../lvm.c

${OBJECTDIR}/_ext/1472/lfunc.o: ../lfunc.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lfunc.o ../lfunc.c

${OBJECTDIR}/_ext/1472/lmem.o: ../lmem.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lmem.o ../lmem.c

${OBJECTDIR}/_ext/1472/lopcodes.o: ../lopcodes.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lopcodes.o ../lopcodes.c

${OBJECTDIR}/_ext/1472/linit.o: ../linit.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/linit.o ../linit.c

${OBJECTDIR}/_ext/1472/lstrlib.o: ../lstrlib.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lstrlib.o ../lstrlib.c

${OBJECTDIR}/_ext/1472/ldebug.o: ../ldebug.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/ldebug.o ../ldebug.c

${OBJECTDIR}/_ext/1472/lobject.o: ../lobject.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lobject.o ../lobject.c

${OBJECTDIR}/_ext/1472/ldo.o: ../ldo.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/ldo.o ../ldo.c

${OBJECTDIR}/_ext/1472/loslib.o: ../loslib.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/loslib.o ../loslib.c

${OBJECTDIR}/_ext/1472/lundump.o: ../lundump.c 
	${MKDIR} -p ${OBJECTDIR}/_ext/1472
	${RM} $@.d
	$(COMPILE.c) -O2 -fPIC  -MMD -MP -MF $@.d -o ${OBJECTDIR}/_ext/1472/lundump.o ../lundump.c

# Subprojects
.build-subprojects:

# Clean Targets
.clean-conf: ${CLEAN_SUBPROJECTS}
	${RM} -r build/Release
	${RM} ../../_bin/liblua5.1.so

# Subprojects
.clean-subprojects:

# Enable dependency checking
.dep.inc: .depcheck-impl

include .dep.inc
