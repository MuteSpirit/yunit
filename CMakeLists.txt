project(yunit)
cmake_minimum_required(VERSION 2.6)
cmake_policy(VERSION 2.6)

enable_testing()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/../_bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/../_lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")

link_directories("${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")
include_directories("${PROJECT_SOURCE_DIR}")

if(WIN32)
    add_definitions(/EHsc) # Enable C++ exceptions
else(WIN32)
    add_definitions(-fexceptions) # Enable C++ exceptions
endif(WIN32)
#
# cppunit
#
# ADD_DEFINITIONS(-Wall -Wextra -pedantic -O3 -std=c++0x -fno-implicit-templates)
add_library(cppunit SHARED test.cpp ltest.cpp test.h)
target_link_libraries(cppunit lua5.1)
add_dependencies(cppunit lua51lib)
#
# trace
#
if(WIN32)
    add_library(trace SHARED trace.c)
    target_link_libraries(trace lua5.1)
    add_dependencies(trace lua51lib)
endif(WIN32)
#
# minidump
#
if(WIN32)
    add_library(minidump SHARED minidump.c)
    target_link_libraries(minidump dbghelp lua5.1)
    add_dependencies(minidump lua51lib)
endif(WIN32)
#
# cppunit.t
#
add_library(cppunit.t SHARED test.t.cpp)
target_link_libraries(cppunit.t cppunit)
if(WIN32)
    add_dependencies(cppunit.t cppunit lua51int trace lfs)
    add_custom_command(TARGET cppunit.t 
                       POST_BUILD
                       COMMAND "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/$(Configuration)/lua5.1.exe" -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;${CMAKE_CURRENT_SOURCE_DIR}/../ts_modules/?.lua;]] .. package.path" -l yunit.work_in_vs -l yunit.default_test_run -e \"run([[${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/$(Configuration)/cppunit.t.dll]])\"
                      )
else(WIN32)
    add_dependencies(cppunit.t cppunit lua51int lfs)
endif(WIN32)
#
# sample.t
#
add_library(sample.t SHARED sample.t.cpp)
target_link_libraries(sample.t cppunit)
if(NOT WIN32)
    add_dependencies(sample.t cppunit lua51int lfs)
else(NOT WIN32)
    add_dependencies(sample.t cppunit trace lua51int lfs)
    add_custom_command(TARGET sample.t 
                       POST_BUILD
                       COMMAND "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/$(Configuration)/lua5.1.exe" -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;${CMAKE_CURRENT_SOURCE_DIR}/../ts_modules/?.lua;]] .. package.path" -l yunit.work_in_vs -l yunit.default_test_run -e \"run([[${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/$(Configuration)/sample.t.dll]])\"
                    )
endif(NOT WIN32)

# add_test (sampleTest ${EXECUTABLE_OUTPUT_PATH}/lua5.1 -e "package.path=[[${PROJECT_BINARY_DIR}/?.lua;${PROJECT_BINARY_DIR}/ts_modules/?.lua;]] .. package.path" -l yunit.work_in_vs -l yunit.default_test_run -e "run([[${CMAKE_LIBRARY_OUTPUT_PATH}/libsample.t.so]])")
# set_tests_properties (sampleTest PROPERTIES PASS_REGULAR_EXPRESSION "Errors:.*0")
#
# Installation rules
#
if(WIN32)
    set(YUNIT_TARGETS cppunit trace minidump)
    set(YUNIT_RUNTIME_DIR 5.1)
    set(YUNIT_LIBRARY_DIR 5.1/lib)
    set(YUNIT_ARCHIVE_DIR 5.1/lib)
    install(FILES 
                "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/RelWithDebInfo/cppunit.pdb"
                "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/RelWithDebInfo/trace.pdb"
                "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/RelWithDebInfo/minidump.pdb"
                CONFIGURATIONS RelWithDebInfo
                DESTINATION 5.1)
    set(YUNIT_HEADERS_DIR 5.1/include/yunit)
    set(YUNIT_LUA_MODULES_DIR 5.1/lua/yunit)
else(WIN32)
    set(YUNIT_TARGETS cppunit)
    set(YUNIT_RUNTIME_DIR lib/lua/5.1)
    set(YUNIT_LIBRARY_DIR lib/lua/5.1)
    set(YUNIT_ARCHIVE_DIR lib/lua/5.1)
    set(YUNIT_HEADERS_DIR include/lua5.1/yunit)
    set(YUNIT_LUA_MODULES_DIR lib/lua/5.1/lua/yunit)
endif(WIN32)

install(TARGETS ${YUNIT_TARGETS} 
        RUNTIME DESTINATION ${YUNIT_RUNTIME_DIR}
        LIBRARY DESTINATION ${YUNIT_LIBRARY_DIR}
        ARCHIVE DESTINATION ${YUNIT_ARCHIVE_DIR})
install(DIRECTORY . 
          DESTINATION ${YUNIT_HEADERS_DIR}
          FILES_MATCHING PATTERN "*.h")
install(DIRECTORY . 
          DESTINATION ${YUNIT_LUA_MODULES_DIR}
          FILES_MATCHING 
            PATTERN "*.lua"
            PATTERN "*.t.lua" EXCLUDE)
#
# Package info
#
set(YUNIT_NAME "yUnit")
set(YUNIT_VERSION 0 3 9)
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

set(CPACK_SOURCE_GENERATOR "TBZ2;TGZ;ZIP")

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
