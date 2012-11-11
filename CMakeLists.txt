project(yunit)
cmake_minimum_required(VERSION 2.6)
cmake_policy(VERSION 2.6)

enable_testing()
#
# Output binaries directories are situated one level up, then build directory.
# Reason: we can access to built files, without information about name of build directory
#
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/../_bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/../_lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")

link_directories("${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")
##############################################################################################################    
# Package info
##############################################################################################################    
set(YUNIT_NAME "yUnit")
set(YUNIT_VERSION 0 3 16)
set(YUNIT_DESCRIPTION "yUnit (Yet another xUnit)")
set(YUNIT_VENDOR "Ivan Efimov aka MuteSpirit")
set(YUNIT_CONTACT "mutespirit@gmail.com")

##############################################################################################################    
# CPack commands
##############################################################################################################    
include(CPack)

set(CPACK_PACKAGE_NAME ${YUNIT_NAME})
set(CPACK_PACKAGE_VENDOR ${YUNIT_VENDOR})

list(GET YUNIT_VERSION 0 CPACK_PACKAGE_VERSION_MAJOR)
list(GET YUNIT_VERSION 1 CPACK_PACKAGE_VERSION_MINOR)
list(GET YUNIT_VERSION 2 CPACK_PACKAGE_VERSION_PATCH)

set(CPACK_PACKAGE_DESCRIPTION_SUMMARY ${YUNIT_DESCRIPTION})
set(CPACK_PACKAGE_CONTACT ${YUNIT_CONTACT})
set(CPACK_RESOURCE_FILE_README "${PROJECT_SOURCE_DIR}/readme.txt")
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/copyright.txt")

set(CPACK_PACKAGE_INSTALL_DIRECTORY lua)

set(CPACK_SOURCE_GENERATOR TBZ2;TGZ;ZIP)

if(WIN32 AND NOT UNIX)
    # There is a bug in NSI that does not handle full unix paths properly. Make
    # sure there is at least one set of four (4) backlasshes.
    set(CPACK_GENERATOR "NSIS")
    set(CPACK_NSIS_DISPLAY_NAME ${YUNIT_DESCRIPTION})
    set(CPACK_NSIS_URL_INFO_ABOUT "http:\\\\\\\\code.google.com/p/yunit")
    set(CPACK_NSIS_CONTACT ${YUNIT_CONTACT})
    set(CPACK_NSIS_MODIFY_PATH ON)
else(WIN32 AND NOT UNIX)
    set(CPACK_GENERATOR "DEB")
    set(CPACK_DEBIAN_PACKAGE_SECTION "Developer Tools")
endif(WIN32 AND NOT UNIX)

##############################################################################################################    
# build Lua
##############################################################################################################    
#
# we cannot use points in yunit shared library output file name, because it will not allow use it in Lua
# "require" command argument. So Lua version is 51 or 52 instead of 5.1 and 5.2
# Now Lua source is situated in external repository, loaded as subrepo. Such repository does not contain CMake files.
#
set(LUA51_DIR ${CMAKE_SOURCE_DIR}/lua_51)
set(LUA51_LIB_FILES 
    ${LUA51_DIR}/lapi.c
    ${LUA51_DIR}/lauxlib.c 
    ${LUA51_DIR}/lbaselib.c 
    ${LUA51_DIR}/lcode.c 
    ${LUA51_DIR}/ldblib.c 
    ${LUA51_DIR}/ldebug.c 
    ${LUA51_DIR}/ldo.c 
    ${LUA51_DIR}/ldump.c 
    ${LUA51_DIR}/lfunc.c 
    ${LUA51_DIR}/lgc.c 
    ${LUA51_DIR}/linit.c 
    ${LUA51_DIR}/liolib.c 
    ${LUA51_DIR}/llex.c 
    ${LUA51_DIR}/lmathlib.c 
    ${LUA51_DIR}/lmem.c 
    ${LUA51_DIR}/loadlib.c 
    ${LUA51_DIR}/lobject.c 
    ${LUA51_DIR}/lopcodes.c 
    ${LUA51_DIR}/loslib.c 
    ${LUA51_DIR}/lparser.c 
    ${LUA51_DIR}/lstate.c 
    ${LUA51_DIR}/lstring.c 
    ${LUA51_DIR}/lstrlib.c 
    ${LUA51_DIR}/ltable.c 
    ${LUA51_DIR}/ltablib.c 
    ${LUA51_DIR}/ltm.c 
    ${LUA51_DIR}/lundump.c 
    ${LUA51_DIR}/lvm.c 
    ${LUA51_DIR}/lzio.c 
    ${LUA51_DIR}/print.c)
  
set(LUA52_DIR ${CMAKE_SOURCE_DIR}/lua_52)
set(LUA52_LIB_FILES ${LUA52_DIR}/lapi.c ${LUA52_DIR}/lauxlib.c ${LUA52_DIR}/lbaselib.c ${LUA52_DIR}/lbitlib.c ${LUA52_DIR}/lcode.c ${LUA52_DIR}/lcorolib.c ${LUA52_DIR}/lctype.c ${LUA52_DIR}/ldblib.c ${LUA52_DIR}/ldebug.c ${LUA52_DIR}/ldo.c ${LUA52_DIR}/ldump.c ${LUA52_DIR}/lfunc.c ${LUA52_DIR}/lgc.c ${LUA52_DIR}/linit.c ${LUA52_DIR}/liolib.c ${LUA52_DIR}/llex.c ${LUA52_DIR}/lmathlib.c ${LUA52_DIR}/lmem.c ${LUA52_DIR}/loadlib.c ${LUA52_DIR}/lobject.c ${LUA52_DIR}/lopcodes.c ${LUA52_DIR}/loslib.c ${LUA52_DIR}/lparser.c ${LUA52_DIR}/lstate.c ${LUA52_DIR}/lstring.c ${LUA52_DIR}/lstrlib.c ${LUA52_DIR}/ltable.c ${LUA52_DIR}/ltablib.c ${LUA52_DIR}/ltm.c ${LUA52_DIR}/lundump.c ${LUA52_DIR}/lvm.c ${LUA52_DIR}/lzio.c)


function(buildLua LUA_VERSION LUA_DIR LUA_LIB_FILES)     
    set(LUA_LIB_TARGET_NAME lua_lib_${LUA_VERSION})
    set(LUA_LIB_OUT_NAME lua${LUA_VERSION})
    #
    # Lua library must be shared (DLL), because lua interpreter executable file won't be ableto use Lua binding module, built as DLL and returning something,
    # created on heap, because process will crash during try to delete such objects in own (other then module) heap
    add_library(${LUA_LIB_TARGET_NAME} SHARED ${LUA_LIB_FILES})
    set_target_properties(${LUA_LIB_TARGET_NAME} PROPERTIES OUTPUT_NAME ${LUA_LIB_OUT_NAME})

   if (MSVC)
       set(INC_DIR_FLAG "/I")
       set(DEFINE_FLAG "/D")
   else (MSVC)
       set(INC_DIR_FLAG "-I")
       set(DEFINE_FLAG "-D")
   endif(MSVC)
    
   if(WIN32)
        set_target_properties(${LUA_LIB_TARGET_NAME} PROPERTIES 
                                            OUTPUT_NAME ${LUA_LIB_OUT_NAME}
                                            COMPILE_FLAGS "${DEFINE_FLAG}LUA_BUILD_AS_DLL ${DEFINE_FLAG}_CRT_SECURE_NO_WARNINGS ${INC_DIR_FLAG}${LUA_DIR}"
                                            LINK_FLAGS "/PDB:${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_CFG_INTDIR}/liblua${LUA_VERSION}.pdb")
    else(WIN32)
        if(UNIX)
            set_target_properties(${LUA_LIB_TARGET_NAME} PROPERTIES 
                                                OUTPUT_NAME ${LUA_LIB_OUT_NAME}
                                                COMPILE_FLAGS "${DEFINE_FLAG}LUA_USE_LINUX")
            target_link_libraries(${LUA_LIB_TARGET_NAME} dl ncurses)
        else(UNIX)
            if(APPLE)
                set_target_properties(${LUA_LIB_TARGET_NAME} PROPERTIES 
                                                    OUTPUT_NAME ${LUA_LIB_OUT_NAME}
                                                    COMPILE_FLAGS "${DEFINE_FLAG}LUA_USE_LINUX ${INC_DIR_FLAG}${LUA_DIR}")
                target_link_libraries(${LUA_LIB_TARGET_NAME} dl readline)
            endif(APPLE)
        endif(UNIX)
    endif(WIN32)
endfunction(buildLua)

buildLua(51 ${LUA51_DIR} ${LUA51_LIB_FILES})
#buildLua(52 ${LUA52_DIR} ${LUA52_LIB_FILES})
#
# build yUnit
if(WIN32)
    set(COPY_TARGET_FILES copy /b /y $(TargetDir)\\$(TargetName).* $(TargetDir)\\..)
endif(WIN32)
#add_subdirectory(yunit)
