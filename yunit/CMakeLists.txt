if(WIN32)
    find_path(LUA_INCLUDE_DIR lua.h
                   PATHS ../../lua/src
                         $ENV{PROGRAMFILES}/lua/5.2/include
                         $ENV{PROGRAMFILES}/lua/5.1/include
    )
    include_directories(${LUA_INCLUDE_DIR}
    )
    find_library(LUA_LIBRARY
                      NAMES lua5.2 lua52 lua5.1 lua51 lua
                      PATHS ../../lua/src
                            $ENV{PROGRAMFILES}/lua/5.2/lib
                            $ENV{PROGRAMFILES}/lua/5.1/lib
    )
	find_program(LUA_EXE
					NAMES lua5.2.exe lua5.1.exe lua.exe
				    PATHS ../../lua/src
                          $ENV{PROGRAMFILES}/lua/5.2
				          $ENV{PROGRAMFILES}/lua/5.1
    )
else(WIN32)
    find_path(LUA_INCLUDE_DIR lua.h
                PATH_SUFFIXES lua5.2
                              lua5.1
    )
    include_directories(${LUA_INCLUDE_DIR} ${LUA_INCLUDE_DIR}/lua5.2
    ) 
    find_library(LUA_LIBRARY NAMES lua5.2 lua lua5.1
                PATH_SUFFIXES i386-linux-gnu
    )
	find_program(LUA_EXE
					NAMES lua5.2 lua lua5.1 
    )
endif(WIN32)
#
# Enable C++ exceptions
#
if(MSVC)
    add_definitions(/EHsc)
else(MSVC)
    add_definitions(-fexceptions -std=c++0x)
endif(MSVC)
#
# yunit
#
add_library(yunit SHARED cppunit.cpp lfs.cpp yunit.h cppunit.h lua_wrapper.h)
target_link_libraries(yunit ${LUA_LIBRARY})
set_target_properties(yunit PROPERTIES 
                      PREFIX "")
#
# trace
#
if(WIN32)
    add_library(trace SHARED trace.c)
    target_link_libraries(trace ${LUA_LIBRARY})
endif(WIN32)
#
# yunit.t
#
add_library(yunit.t SHARED cppunit.t.cpp)
target_link_libraries(yunit.t yunit)
set_target_properties(yunit.t PROPERTIES PREFIX "")
if(WIN32)
    add_dependencies(yunit.t yunit trace)
else(WIN32)
    add_dependencies(yunit.t yunit)
endif(WIN32)
#
# Tests
#
if(MSVC)
    set(WORK_IN "yunit.work_in_vs")
else(MSVC)
    set(WORK_IN "yunit.work_in_scite")
endif(MSVC)

if(WIN32)
    set(SHARED_LIB_EXT "dll")
    set(SHARED_LIB_OUT_DIR "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
else(WIN32)
    set(SHARED_LIB_EXT "so")
    set(SHARED_LIB_OUT_DIR "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
endif(WIN32)



if(WIN32)
# we copy target files (*.dll) outside $(Configuration) directory, because on WIN32 value of 
# ${CMAKE_CFG_INTDIR} is equal $(Configuration), i.e. not substituted by real name (Debug, Release, etc).
# So we cannot use value ${CMAKE_CFG_INTDIR} in test commands
    add_custom_command(TARGET yunit
                       POST_BUILD
                       COMMAND copy $(TargetPath) $(TargetDir)\\..)
    add_custom_command(TARGET yunit.t
                       POST_BUILD
                       COMMAND copy $(TargetPath) $(TargetDir)\\..)
endif(WIN32)
#
# This test run test from all test container of project
#
add_test(all_cppunit_tests ${LUA_EXE} -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -e "package.cpath=[[${SHARED_LIB_OUT_DIR}/?.${SHARED_LIB_EXT};]]..package.cpath" -l ${WORK_IN} -l yunit.all_test_run -e "runFrom{[[${CMAKE_LIBRARY_OUTPUT_DIRECTORY}]], [[${CMAKE_CURRENT_SOURCE_DIR}]]}")
#
# Installation rules
#
if(WIN32)
    set(YUNIT_TARGETS yunit trace minidump)
    set(YUNIT_RUNTIME_DIR 5.1)
    set(YUNIT_LIBRARY_DIR 5.1/lib)
    set(YUNIT_ARCHIVE_DIR 5.1/lib)
    install(FILES 
                "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/RelWithDebInfo/yunit.pdb"
                "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/RelWithDebInfo/trace.pdb"
                "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/RelWithDebInfo/minidump.pdb"
                CONFIGURATIONS RelWithDebInfo
                DESTINATION 5.1)
    set(YUNIT_HEADERS_DIR 5.1/include/yunit)
    set(YUNIT_LUA_MODULES_DIR 5.1/lua/yunit)
else(WIN32)
    set(YUNIT_TARGETS yunit)
    set(YUNIT_RUNTIME_DIR local/lib/lua/5.1)
    set(YUNIT_LIBRARY_DIR local/lib/lua/5.1)
    set(YUNIT_ARCHIVE_DIR local/lib/lua/5.1)
    set(YUNIT_HEADERS_DIR include/lua5.2/yunit)
    set(YUNIT_LUA_MODULES_DIR local/lib/lua/5.1/yunit)
endif(WIN32)

install(TARGETS ${YUNIT_TARGETS} 
        RUNTIME DESTINATION ${YUNIT_RUNTIME_DIR}
        LIBRARY DESTINATION ${YUNIT_LIBRARY_DIR}
        ARCHIVE DESTINATION ${YUNIT_ARCHIVE_DIR})
install(DIRECTORY . 
          DESTINATION ${YUNIT_HEADERS_DIR}
          FILES_MATCHING 
          PATTERN "*.h")
install(DIRECTORY . 
          DESTINATION ${YUNIT_LUA_MODULES_DIR}
          FILES_MATCHING 
            PATTERN "*.lua"
            PATTERN "*.t.lua" EXCLUDE)
