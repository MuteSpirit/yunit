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
if(NOT WIN32)
    add_dependencies(cppunit.t cppunit)
else(NOT WIN32)
    add_dependencies(cppunit.t trace)
    add_custom_command(TARGET cppunit.t 
                       POST_BUILD
                       COMMAND "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/$(Configuration)/lua5.1.exe" -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;${CMAKE_CURRENT_SOURCE_DIR}/../ts_modules/?.lua;]] .. package.path" -l yunit.work_in_vs -l yunit.default_test_run -e \"run([[${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/$(Configuration)/cppunit.t.dll]])\"
                      )
endif(NOT WIN32)
#
# sample.t
#
add_library(sample.t SHARED sample.t.cpp)
target_link_libraries(sample.t cppunit)
if(NOT WIN32)
    add_dependencies(sample.t cppunit)
else(NOT WIN32)
    add_dependencies(sample.t cppunit trace)
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
#    install(TARGETS trace minidump DESTINATION /set/path)
else(WIN32)
    install(TARGETS cppunit DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/lua/5.1)
    install(FILES test.h DESTINATION ${CMAKE_INSTALL_PREFIX}/include/lua5.1/yunit)
    install(FILES default_test_run.lua lua_test_run.lua luaunit.lua test_result_handlers.lua test_runner.lua work_in_scite.lua DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/lua/5.1/lua/yunit)
endif(WIN32)