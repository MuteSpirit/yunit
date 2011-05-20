set(CMAKE_INCLUDE_CURRENT_DIR ON)
INCLUDE_DIRECTORIES(${PROJECT_BINARY_DIR})

### \todo use in future
# if(WIN32)
#    set_target_properties(WindowApplicationExample PROPERTIES LINK_FLAGS_DEBUG "/SUBSYSTEM:CONSOLE")
#    set_target_properties(WindowApplicationExample PROPERTIES COMPILE_DEFINITIONS_DEBUG "_CONSOLE")
#    set_target_properties(WindowApplicationExample PROPERTIES LINK_FLAGS_RELWITHDEBINFO "/SUBSYSTEM:CONSOLE")
#    set_target_properties(WindowApplicationExample PROPERTIES COMPILE_DEFINITIONS_RELWITHDEBINFO "_CONSOLE")
#    set_target_properties(WindowApplicationExample PROPERTIES LINK_FLAGS_RELEASE "/SUBSYSTEM:WINDOWS")
#    set_target_properties(WindowApplicationExample PROPERTIES LINK_FLAGS_MINSIZEREL "/SUBSYSTEM:WINDOWS")
# endif(WIN32)

# ADD_DEFINITIONS(-Wall -Wextra -pedantic -O3 -std=c++0x -fno-implicit-templates)
ADD_LIBRARY(cppunit SHARED test.cpp ltest.cpp)

TARGET_LINK_LIBRARIES(cppunit lua5.1)
ADD_DEPENDENCIES(cppunit lua51lib)

if(WIN32)
    ADD_LIBRARY(trace SHARED trace.c)
    ADD_LIBRARY(minidump SHARED minidump.c)
endif(WIN32)

### \todo Compile under Linux with GCC
# ADD_LIBRARY(cppunit.t SHARED test.t.cpp)
# TARGET_LINK_LIBRARIES(cppunit.t cppunit)

ADD_LIBRARY(sample.t SHARED sample.t.cpp)
TARGET_LINK_LIBRARIES(sample.t cppunit)
ADD_DEPENDENCIES(sample.t cppunit)

# add_test (sampleTest ${EXECUTABLE_OUTPUT_PATH}/lua5.1 -e "package.path=[[${PROJECT_BINARY_DIR}/?.lua;${PROJECT_BINARY_DIR}/ts_modules/?.lua;]] .. package.path" -l yunit.work_in_vs -l yunit.default_test_run -e "run([[${LIBRARY_OUTPUT_PATH}/libsample.t.so]])")
# set_tests_properties (sampleTest PROPERTIES PASS_REGULAR_EXPRESSION "Errors:.*0")
#
# Installation rules
#
if(WIN32)
    install(TARGETS trace minidump DESTINATION /set/path)
else(WIN32)
    install(TARGETS cppunit DESTINATION /usr/lib/lua/5.1)
    install(FILES test.h DESTINATION /usr/include/lua5.1/yunit)
    install(FILES default_test_run.lua lua_test_run.lua luaunit.lua test_result_handlers.lua test_runner.lua work_in_scite.lua DESTINATION /usr/lib/lua/5.1/lua/yunit)
endif(WIN32)