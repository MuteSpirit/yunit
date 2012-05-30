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

set(LUA_VERSIONS 5.1 5.2)
foreach(LUA_VERSION ${LUA_VERSIONS})
    add_subdirectory(lua_${LUA_VERSION})
endforeach(LUA_VERSION)    

add_subdirectory(yunit)


#INCLUDE(ExternalProject)


#IF(UNIX)
#    set(LUA_BUILD_COMMAND make -j 2 linux)
#ELSE(UNIX)
#    set(LUA_BUILD_COMMAND make -j 2 generic)
#ENDIF(UNIX)

#set(LUA_51_BINARY_DIR ${PROJECT_BINARY_DIR}/lua/5.1)
#set(LUA_52_BINARY_DIR ${PROJECT_BINARY_DIR}/lua/5.2)

#ExternalProject_Add(
#    lua5.1
#    URL ${CMAKE_CURRENT_SOURCE_DIR}/lua/5.1
##    CONFIGURE_COMMAND ""
#    SOURCE_DIR ${LUA_51_BINARY_DIR}
##    BUILD_COMMAND ${LUA_BUILD_COMMAND}
#    BUILD_IN_SOURCE 1
#    INSTALL_COMMAND ""
#)
#
#ExternalProject_Add(
#    lua5.2
#    URL ${CMAKE_CURRENT_SOURCE_DIR}/lua/5.2
##    CONFIGURE_COMMAND ""
#    SOURCE_DIR ${LUA_52_BINARY_DIR}
##    BUILD_COMMAND ${LUA_BUILD_COMMAND}
#    BUILD_IN_SOURCE 1
#    INSTALL_COMMAND ""
#)
#
#ExternalProject_Add(
#    yunit
#    URL ${CMAKE_CURRENT_SOURCE_DIR}/yunit
#    SOURCE_DIR yunit
#    BUILD_IN_SOURCE 1
##    INSTALL_COMMAND ""
#)
#