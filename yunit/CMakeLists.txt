# We need to link Lua as dynamic library(ies)
# If we link lua statically, then lua command interpreter and yunit DLL will have 
# own copy of lua core copy. So when Lua of yunit.cppunit will allocate new TestCase objects and return
# them from 'loadTestContainer' call, then Lua of command interpreter will try to delete them after 
# finish usage and will crash with 'HEAP CORRUPTION' error

if(NOT WIN32)
# use Ptreads library
    find_package (Threads)
endif(NOT WIN32)
#
# Enable C++ exceptions
#
if(MSVC)
    add_definitions(/EHsc /D_CRT_SECURE_NO_WARNINGS)
else(MSVC)
    add_definitions(-fexceptions -std=c++0x)
endif(MSVC)
#
# yunit
#
set(YUNIT_FILES yunit.h cppunit.h cppunit.cpp lua_wrapper.h lua_wrapper.cpp lfs.cpp trace.h trace.cpp mine.h mine.cpp aux.h aux.cpp)
if(WIN32)
    set(YUNIT_COMMON_LIBS )
else(WIN32)
    set(YUNIT_COMMON_LIBS ${CMAKE_THREAD_LIBS_INIT})
endif(WIN32)
#
# yunit.t
#
set(YUNIT_T_FILES cppunit.t.cpp trace.t.cpp lua_wrapper.t.cpp mine.t.cpp)
#
# Tests
#
if(WIN32)
    set(SHARED_LIB_EXT "dll")
    set(SHARED_LIB_OUT_DIR "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
else(WIN32)
    set(SHARED_LIB_EXT "so")
    set(SHARED_LIB_OUT_DIR "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
endif(WIN32)
set(SET_LUA_PATH -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;${CMAKE_CURRENT_SOURCE_DIR}/../?/init.lua;]]..package.path")

#####################################################################################################################################
# using Lua 5.1
#####################################################################################################################################
set(LUA_VERSION 5.1)

    find_library(LUA_51_LIBRARY     NAMES lua       PATHS ../lua_${LUA_VERSION}/src)
    find_path(LUA_51_INCLUDE_DIR    lua.h           PATHS ../lua_${LUA_VERSION}/src)
if(WIN32)
    find_program(LUA_51_EXEC        NAMES lua.exe   PATHS ../lua_${LUA_VERSION}/src)
else(WIN32)
    find_program(LUA_51_EXEC        NAMES lua       PATHS ../lua_${LUA_VERSION}/src)
endif(WIN32)
    include_directories(${LUA_51_INCLUDE_DIR})
#
#  yunit with Lua 5.1:
#
add_library(yunit_lua51 SHARED ${YUNIT_FILES})
target_link_libraries(yunit_lua51 ${YUNIT_COMMON_LIBS} ${LUA_51_LIBRARY})
set_target_properties(yunit_lua51 PROPERTIES 
                                  PREFIX ""
                                  LIBRARY_OUTPUT_NAME yunit
                                  LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/lua_${LUA_VERSION})
#
# yunit.t with Lua 5.1:
#
add_library(yunit_t_lua51 SHARED ${YUNIT_T_FILES})
target_link_libraries(yunit_t_lua51 yunit_lua51)
set_target_properties(yunit_t_lua51 PROPERTIES
                                    PREFIX ""
                                    LIBRARY_OUTPUT_NAME yunit.t
                                    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/lua_${LUA_VERSION})
add_dependencies(yunit_t_lua51 yunit_lua51)

set(SET_LUA_51_CPATH -e "package.cpath=[[${SHARED_LIB_OUT_DIR}/lua_${LUA_VERSION}/?.${SHARED_LIB_EXT};]]..package.cpath")

add_test(all_cppunit_lua_51_tests ${LUA_51_EXEC} ${SET_LUA_PATH} ${SET_LUA_51_CPATH} -l yunit -e "use{'yunit.cppunit', 'yunit.luaunit'}" -e "run{[[${SHARED_LIB_OUT_DIR}/lua_${LUA_VERSION}]], [[${CMAKE_CURRENT_SOURCE_DIR}]]}")

if(WIN32)
 # we copy target files (*.dll, *.pdb) outside $(Configuration) directory, because on WIN32 value of 
 # ${CMAKE_CFG_INTDIR} is equal to '$(Configuration)' and not substituted by real name (Debug, Release, etc).
 # So we cannot use value ${CMAKE_CFG_INTDIR} in test and install commands
    add_custom_command(TARGET yunit_lua51
                       POST_BUILD
                       COMMAND copy /b /y $(TargetPath) $(TargetDir)\\..
                       COMMAND copy /b /y $(TargetDir)\\$(TargetName).pdb $(TargetDir)\\..
                       )
    add_custom_command(TARGET yunit_t_lua51
                       POST_BUILD
                       COMMAND copy /b /y $(TargetPath) $(TargetDir)\\..
                       COMMAND copy /b /y $(TargetDir)\\$(TargetName).pdb $(TargetDir)\\..
                       )
endif(WIN32)

#
# Installation rules:
#
set(YUNIT_TARGETS yunit_lua51)
if(WIN32)
    set(YUNIT_RUNTIME_DIR ${LUA_VERSION})
    set(YUNIT_LIBRARY_DIR ${LUA_VERSION}/lib)
    set(YUNIT_ARCHIVE_DIR ${LUA_VERSION}/lib)
    install(FILES "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/yunit.pdb"
            DESTINATION ${LUA_VERSION})
    set(YUNIT_HEADERS_DIR ${LUA_VERSION}/include/yunit)
    set(YUNIT_LUA_MODULES_DIR ${LUA_VERSION}/lua/yunit)
else(WIN32)
    set(YUNIT_RUNTIME_DIR local/lib/lua/${LUA_VERSION})
    set(YUNIT_LIBRARY_DIR local/lib/lua/${LUA_VERSION})
    set(YUNIT_ARCHIVE_DIR local/lib/lua/${LUA_VERSION})
    set(YUNIT_HEADERS_DIR include/lua${LUA_VERSION}/yunit)
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
#####################################################################################################################################
# using Lua 5.2
#####################################################################################################################################
set(LUA_VERSION 5.2)

    find_library(LUA_52_LIBRARY     NAMES lua     PATHS ../lua_${LUA_VERSION}/src)
    find_path(LUA_52_INCLUDE_DIR    lua.h         PATHS ../lua_${LUA_VERSION}/src)
if(WIN32)
    find_program(LUA_52_EXEC        NAMES lua.exe PATHS ../lua_${LUA_VERSION}/src)
else(WIN32)
    find_program(LUA_52_EXEC        NAMES lua     PATHS ../lua_${LUA_VERSION}/src)
endif(WIN32)
    include_directories(${LUA_52_INCLUDE_DIR})
#
# yunit with Lua 5.2:
#
add_library(yunit_lua52 SHARED ${YUNIT_FILES})
target_link_libraries(yunit_lua52 ${YUNIT_COMMON_LIBS} ${LUA_52_LIBRARY})
set_target_properties(yunit_lua52 PROPERTIES 
                      PREFIX ""
                      LIBRARY_OUTPUT_NAME yunit
                      LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/lua_${LUA_VERSION})
#
# yunit.t with Lua 5.2:
#
add_library(yunit_t_lua52 SHARED ${YUNIT_T_FILES})
target_link_libraries(yunit_t_lua52 yunit_lua52)
set_target_properties(yunit_t_lua52 PROPERTIES
                                    PREFIX ""
                                    LIBRARY_OUTPUT_NAME yunit.t
                                    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/lua_${LUA_VERSION})
add_dependencies(yunit_t_lua52 yunit_lua52)

set(SET_LUA_52_CPATH -e "package.cpath=[[${SHARED_LIB_OUT_DIR}/lua_${LUA_VERSION}/?.${SHARED_LIB_EXT};]]..package.cpath")

add_test(all_cppunit_lua_52_tests ${LUA_52_EXEC} ${SET_LUA_PATH} ${SET_LUA_52_CPATH} -l yunit -e "use{'yunit.cppunit', 'yunit.luaunit'}" -e "run{[[${SHARED_LIB_OUT_DIR}/lua_${LUA_VERSION}]], [[${CMAKE_CURRENT_SOURCE_DIR}]]}")

if(WIN32)
 # we copy target files (*.dll, *.pdb) outside $(Configuration) directory, because on WIN32 value of 
 # ${CMAKE_CFG_INTDIR} is equal to '$(Configuration)' and not substituted by real name (Debug, Release, etc).
 # So we cannot use value ${CMAKE_CFG_INTDIR} in test and install commands
    add_custom_command(TARGET yunit_lua52
                       POST_BUILD
                       COMMAND copy /b /y $(TargetPath) $(TargetDir)\\..
                       COMMAND copy /b /y $(TargetDir)\\$(TargetName).pdb $(TargetDir)\\..
                       )
    add_custom_command(TARGET yunit_t_lua52
                       POST_BUILD
                       COMMAND copy /b /y $(TargetPath) $(TargetDir)\\..
                       COMMAND copy /b /y $(TargetDir)\\$(TargetName).pdb $(TargetDir)\\..
                       )
endif(WIN32)
#
# Installation rules:
#
set(YUNIT_TARGETS yunit_lua52)
if(WIN32)
    set(YUNIT_RUNTIME_DIR ${LUA_VERSION})
    set(YUNIT_LIBRARY_DIR ${LUA_VERSION}/lib)
    set(YUNIT_ARCHIVE_DIR ${LUA_VERSION}/lib)
    install(FILES "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/yunit.pdb"
            DESTINATION ${LUA_VERSION})
    set(YUNIT_HEADERS_DIR ${LUA_VERSION}/include/yunit)
    set(YUNIT_LUA_MODULES_DIR ${LUA_VERSION}/lua/yunit)
else(WIN32)
    set(YUNIT_RUNTIME_DIR local/lib/lua/${LUA_VERSION})
    set(YUNIT_LIBRARY_DIR local/lib/lua/${LUA_VERSION})
    set(YUNIT_ARCHIVE_DIR local/lib/lua/${LUA_VERSION})
    set(YUNIT_HEADERS_DIR include/lua${LUA_VERSION}/yunit)
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
