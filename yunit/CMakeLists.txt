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
    add_dependencies(cppunit.t cppunit lua51int trace)
    add_custom_command(TARGET cppunit.t 
                       POST_BUILD
                       COMMAND "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/$(Configuration)/lua5.1.exe" -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;${CMAKE_CURRENT_SOURCE_DIR}/../ts_modules/?.lua;]] .. package.path" -l yunit.work_in_vs -l yunit.default_test_run -e \"run([[${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/$(Configuration)/cppunit.t.dll]])\"
                      )
else(WIN32)
    add_dependencies(cppunit.t cppunit lua51int)
endif(WIN32)
#
# sample.t
#
add_library(sample.t SHARED sample.t.cpp)
target_link_libraries(sample.t cppunit)
if(NOT WIN32)
    add_dependencies(sample.t cppunit lua51int)
else(NOT WIN32)
    add_dependencies(sample.t cppunit trace lua51int)
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
