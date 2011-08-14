cmake_minimum_required(VERSION 2.6)
cmake_policy(VERSION 2.6)

enable_testing()

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/_bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/_lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")

if(WIN32)
    find_path(CPPUNIT_INCLUDE_DIR yunit/test.h
                   PATHS $ENV{PROGRAMFILES}/lua/5.1/include)
    include_directories(${CPPUNIT_INCLUDE_DIR})
    find_library(CPPUNIT_LIBRARY cppunit.lib
                      PATHS $ENV{PROGRAMFILES}/lua/5.1/lib)
	find_program(LUA51_EXE
					NAMES lua5.1.exe lua.exe
				    PATHS $ENV{PROGRAMFILES}/lua/5.1)
else(WIN32)
    find_path(CPPUNIT_INCLUDE_DIR yunit/test.h
                        PATH_SUFFIXES lua5.1/)
    include_directories(${CPPUNIT_INCLUDE_DIR})
    find_library(CPPUNIT_LIBRARY NAMES cppunit.so PATH_SUFFIXES lua/5.1/)
    find_program(LUA51_EXE 
					NAMES lua5.1 lua)
endif(WIN32)

if(MSVC)
    set(WORK_IN "yunit.work_in_vs")
else(MSVC)
    set(WORK_IN "yunit.work_in_scite")
endif(MSVC)

if(WIN32)
   set(SHARED_LIB_EXT "dll")
   set(SHARED_LIB_OUT_DIR "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_CFG_INTDIR}")
else(WIN32)
   set(SHARED_LIB_EXT "so")
   set(SHARED_LIB_OUT_DIR "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
endif(WIN32)
#
# Sample project
#
add_library(sample.t SHARED sample.t.cpp)
target_link_libraries(sample.t ${CPPUNIT_LIBRARY})
if(MSVC)
    set_target_properties(sample.t PROPERTIES 
                                        PREFIX ""
                                        COMPILE_FLAGS "/EHsc" # Enable C++ exceptions
                                        )
else(MSVC)
    set_target_properties(sample.t PROPERTIES 
                                        PREFIX ""
                                        COMPILE_FLAGS "-fexceptions" # Enable C++ exceptions
                                        )
endif(MSVC)

if(WIN32)
    add_custom_command(TARGET sample.t
                       POST_BUILD
                       COMMAND ${LUA51_EXE} -l ${WORK_IN} -l yunit.default_test_run -e \"run([[${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_CFG_INTDIR}/sample.t.${SHARED_LIB_EXT}]])\"
                       )
else(WIN32)
    add_test(sample.t ${LUA51_EXE} -l ${WORK_IN} -l yunit.default_test_run -e "run([[${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/sample.t.${SHARED_LIB_EXT}]])")
endif(WIN32)
