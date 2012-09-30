# We need to link Lua as dynamic library(ies)
#? If we link lua statically, then lua command interpreter and yunit DLL will have 
#? own copy of lua core copy. So when Lua of yunit.cppunit will allocate new TestCase objects and return
#? them from 'loadTestContainer' call, then Lua of command interpreter will try to delete them after 
#? finish usage and will crash with 'HEAP CORRUPTION' error

if(NOT WIN32)
# use Ptreads library
    find_package (Threads)
endif(NOT WIN32)

if(MSVC)
    set(CPP_DEFS "/EHsc /D_CRT_SECURE_NO_WARNINGS")
else (MSVC)
    set(CPP_DEFS "-fexceptions -std=c++0x -Wall") 
endif(MSVC)

if (MSVC)
    set(INC_DIR_FLAG "/I")
    set(DEFINE_FLAG "/D")
else (MSVC)
    set(INC_DIR_FLAG "-I")
    set(DEFINE_FLAG "-D")
endif(MSVC)

add_library(sample_cpp_tue SHARED sample_tue.cpp)
set_target_properties(sample_cpp_tue PROPERTIES 
                        PREFIX "" # remove 'lib' prefix on Linux
                        COMPILE_FLAGS "${DEFINE_FLAG}TUE_LIB ${CPP_DEFS}")

add_library(sample_cpp_tc SHARED sample_tc.cpp)
set_target_properties(sample_cpp_tc PROPERTIES 
                        PREFIX "" # remove 'lib' prefix on Linux
                        COMPILE_FLAGS "${CPP_DEFS}")
add_dependencies(sample_cpp_tc sample_cpp_tue)
if (WIN32)
    target_link_libraries(sample_cpp_tc sample_cpp_tue)
else (WIN32)
    target_link_libraries(sample_cpp_tc dl sample_cpp_tue)
endif (WIN32)


add_library(sample_c_tue SHARED sample_tue.c)
set_target_properties(sample_c_tue PROPERTIES 
                        PREFIX "" # remove 'lib' prefix on Linux
                        COMPILE_FLAGS "${DEFINE_FLAG}TUE_LIB")

add_library(sample_lua52_tue SHARED sample_lua52_tue.cpp)
find_path(LUA52_INCLUDE_DIR NAMES lua.h PATHS ${CMAKE_CURRENT_SOURCE_DIR}/../lua_52/src)
set_target_properties(sample_lua52_tue PROPERTIES
                        PREFIX "" # remove 'lib' prefix on Linux
                        COMPILE_FLAGS "${DEFINE_FLAG}TUE_LIB ${CPP_DEFS} ${INC_DIR_FLAG}\"${LUA52_INCLUDE_DIR}\"")

add_executable(yunit yunit_main.cpp lua_wrapper.cpp test_engine.cpp)
set_target_properties(yunit PROPERTIES COMPILE_FLAGS "${CPP_DEFS} ${INC_DIR_FLAG}\"${LUA52_INCLUDE_DIR}\"")
if (WIN32)
    add_dependencies(yunit lua_lib_52)
    target_link_libraries(yunit dl lua52)
else (WIN32)
    add_dependencies(yunit lua_lib_52)
    target_link_libraries(yunit dl lua52)
endif (WIN32)

if(WIN32)
    set(SHARED_LIB_EXT "dll")
    set(SHARED_LIB_OUT_DIR "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
else(WIN32)
    set(SHARED_LIB_EXT "so")
    set(SHARED_LIB_OUT_DIR "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
endif(WIN32)

add_test(run_cpp_tests ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/yunit -e "${SHARED_LIB_OUT_DIR}/sample_cpp_tue.so" -t "${SHARED_LIB_OUT_DIR}/sample_cpp_tc.so" yunit_main.lua)
set_tests_properties(run_cpp_tests PROPERTIES PASS_REGULAR_EXPRESSION "Ok")


