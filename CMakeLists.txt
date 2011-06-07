PROJECT(yunit CXX C)
CMAKE_MINIMUM_REQUIRED(VERSION 2.6)

ENABLE_TESTING()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/../_bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/../_lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")

cmake_policy(VERSION 2.6)
link_directories("${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")
include_directories("${PROJECT_SOURCE_DIR}")

add_subdirectory(lua)
add_subdirectory(lfs)
add_subdirectory(ts_modules)
add_subdirectory(yunit)

set(CPACK_PACKAGE_NAME "yUnit")
set(CPACK_PACKAGE_VENDOR "Ivan Efimov aka MuteSpirit")

set(CPACK_PACKAGE_VERSION_MAJOR "0")
set(CPACK_PACKAGE_VERSION_MINOR "3")
set(CPACK_PACKAGE_VERSION_PATCH "8")

set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "yUnit (Yet another xUnit)")
set(CPACK_PACKAGE_CONTACT "mutespirit@gmail.com")
set(CPACK_RESOURCE_FILE_README "${CMAKE_CURRENT_SOURCE_DIR}/readme.txt")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/copyright.txt")

set(CPACK_PACKAGE_INSTALL_DIRECTORY lua)

set(CPACK_SOURCE_GENERATOR "TBZ2;TGZ;ZIP")

IF(WIN32 AND NOT UNIX)
    # There is a bug in NSI that does not handle full unix paths properly. Make
    # sure there is at least one set of four (4) backlasshes.
    set(CPACK_GENERATOR "NSIS")
    set(CPACK_NSIS_DISPLAY_NAME "yUnit (Yet another xUnit)")
    set(CPACK_NSIS_URL_INFO_ABOUT "http:\\\\\\\\code.google.com/p/yunit/w/list")
    set(CPACK_NSIS_CONTACT "mutespirit@gmail.com")
    set(CPACK_NSIS_MODIFY_PATH ON)
ELSE(WIN32 AND NOT UNIX)
    set(CPACK_GENERATOR "DEB")
    set(CPACK_DEBIAN_PACKAGE_SECTION "Developer Tools")
ENDIF(WIN32 AND NOT UNIX)
    
INCLUDE(CPack)
