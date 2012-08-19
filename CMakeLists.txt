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
#
# Package info
#
set(YUNIT_NAME "yUnit")
set(YUNIT_VERSION 0 3 16)
set(YUNIT_DESCRIPTION "yUnit (Yet another xUnit)")
set(YUNIT_VENDOR "Ivan Efimov aka MuteSpirit")
set(YUNIT_CONTACT "mutespirit@gmail.com")
#
# CPack commands
#
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

IF(WIN32 AND NOT UNIX)
    # There is a bug in NSI that does not handle full unix paths properly. Make
    # sure there is at least one set of four (4) backlasshes.
    set(CPACK_GENERATOR "NSIS")
    set(CPACK_NSIS_DISPLAY_NAME ${YUNIT_DESCRIPTION})
    set(CPACK_NSIS_URL_INFO_ABOUT "http:\\\\\\\\code.google.com/p/yunit/w/list")
    set(CPACK_NSIS_CONTACT ${YUNIT_CONTACT})
    set(CPACK_NSIS_MODIFY_PATH ON)
ELSE(WIN32 AND NOT UNIX)
    set(CPACK_GENERATOR "DEB")
    set(CPACK_DEBIAN_PACKAGE_SECTION "Developer Tools")
ENDIF(WIN32 AND NOT UNIX)
    
INCLUDE(CPack)

if(WIN32)
    set(COPY_TARGET_FILES copy /b /y $(TargetDir)\\$(TargetName).* $(TargetDir)\\..)
endif(WIN32)

# we cannot use points in yunit shared library output file name, because it will not allow use it in Lua "require" command argument. So Lua version is 51 or 52 and no 5.1 and 5.2
#foreach(LUA_VERSION 51 52)
#    add_subdirectory(lua_${LUA_VERSION})
#endforeach(LUA_VERSION)    

add_subdirectory(yunit)
