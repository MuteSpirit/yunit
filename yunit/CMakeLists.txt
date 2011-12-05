# We need to link Lua as dynamic library(ies)
# If we link lua statically, then lua command interpreter and yunit DLL will have 
# own copy of lua core copy. So when Lua of yunit.cppunit will allocate new TestCase objects and return
# them from 'loadTestContainer' call, then Lua of command interpreter will try to delete them after 
# finish usage and will crash with 'HEAP CORRUPTION' error

if(WIN32)
    set(LUA_VERSION 5.2)
    find_library(LUA_LIBRARY NAMES lua5.2 lua52 lua
                            $ENV{PROGRAMFILES}/lua/5.2/lib
    )
    if(NOT LUA_LIBRARY)
        set(LUA_VERSION 5.2)
        find_library(LUA_CORE_LIBRARY NAMES lua_core
                                PATHS $ENV{PROGRAMFILES}/lua/5.2/lib
        )
        find_library(LUA_LIB_LIBRARY NAMES lua_lib
                                PATHS $ENV{PROGRAMFILES}/lua/5.2/lib
        )
        set(LUA_LIBRARY ${LUA_CORE_LIBRARY} ${LUA_LIB_LIBRARY})
        
        if(NOT LUA_LIBRARY)
            set(LUA_VERSION 5.1)
            find_library(LUA_LIBRARY NAMES lua5.1 lua51 lua
                                    $ENV{PROGRAMFILES}/lua/5.1/lib
            )
        endif(NOT LUA_LIBRARY)
    endif(NOT LUA_LIBRARY)
    
    if(LUA_VERSION EQUAL 5.2)
        find_path(LUA_INCLUDE_DIR lua.h
                        $ENV{PROGRAMFILES}/lua/5.2/include
        )
        include_directories(${LUA_INCLUDE_DIR})
        
        find_program(LUA_EXE
                     NAMES lua5.2.exe lua.exe
                              $ENV{PROGRAMFILES}/lua/5.2
        )
    else(LUA_VERSION EQUAL 5.2)
        find_path(LUA_INCLUDE_DIR lua.h
                  PATHS $ENV{PROGRAMFILES}/lua/5.1/include
        )
        include_directories(${LUA_INCLUDE_DIR})
        
        find_program(LUA_EXE
                     NAMES lua5.1.exe
                     PATHS $ENV{PROGRAMFILES}/lua/5.1
        )
    endif(LUA_VERSION EQUAL 5.2)
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
add_library(yunit SHARED yunit.h cppunit.h cppunit.cpp lua_wrapper.h lua_wrapper.cpp lfs.cpp trace.h trace.cpp)
target_link_libraries(yunit ${LUA_LIBRARY})
set_target_properties(yunit PROPERTIES 
                      PREFIX "")
#
# yunit.t
#
add_library(yunit.t SHARED cppunit.t.cpp trace.t.cpp lua_wrapper.t.cpp)
target_link_libraries(yunit.t yunit)
set_target_properties(yunit.t PROPERTIES PREFIX "")
add_dependencies(yunit.t yunit)
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
# we copy target files (*.dll, *.pdb) outside $(Configuration) directory, because on WIN32 value of 
# ${CMAKE_CFG_INTDIR} is equal to '$(Configuration)' and not substituted by real name (Debug, Release, etc).
# So we cannot use value ${CMAKE_CFG_INTDIR} in test and install commands
    add_custom_command(TARGET yunit
                       POST_BUILD
                       COMMAND copy /b /y $(TargetPath) $(TargetDir)\\..
                       COMMAND copy /b /y $(TargetDir)\\$(TargetName).pdb $(TargetDir)\\..
                       )
    add_custom_command(TARGET yunit.t
                       POST_BUILD
                       COMMAND copy /b /y $(TargetPath) $(TargetDir)\\..
                       COMMAND copy /b /y $(TargetDir)\\$(TargetName).pdb $(TargetDir)\\..
                       )
endif(WIN32)
#
# This test run test from all test container of project

set(SET_LUA_PATH -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path")
set(SET_LUA_CPATH -e "package.cpath=[[${SHARED_LIB_OUT_DIR}/?.${SHARED_LIB_EXT};]]..package.cpath")

add_test(all_cppunit_tests ${LUA_EXE} ${SET_LUA_PATH} ${SET_LUA_CPATH} -l ${WORK_IN} -l yunit.default_test_run -e "use{'yunit.cppunit', 'yunit.luaunit'}" -e "runFrom{[[${SHARED_LIB_OUT_DIR}]], [[${CMAKE_CURRENT_SOURCE_DIR}]]}")

#
# Installation rules
if(WIN32)
    set(YUNIT_TARGETS yunit)
    set(YUNIT_RUNTIME_DIR ${LUA_VERSION})
    set(YUNIT_LIBRARY_DIR ${LUA_VERSION}/lib)
    set(YUNIT_ARCHIVE_DIR ${LUA_VERSION}/lib)
    install(FILES "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/yunit.pdb"
            DESTINATION ${LUA_VERSION})
    set(YUNIT_HEADERS_DIR ${LUA_VERSION}/include/yunit)
    set(YUNIT_LUA_MODULES_DIR ${LUA_VERSION}/lua/yunit)
else(WIN32)
    set(YUNIT_TARGETS yunit)
    set(YUNIT_RUNTIME_DIR local/lib/lua/${LUA_VERSION})
    set(YUNIT_LIBRARY_DIR local/lib/lua/${LUA_VERSION})
    set(YUNIT_ARCHIVE_DIR local/lib/lua/${LUA_VERSION})
    set(YUNIT_HEADERS_DIR include/lua5.2/yunit)
    set(YUNIT_LUA_MODULES_DIR local/lib/lua/${LUA_VERSION}/yunit)
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
