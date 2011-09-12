if(WIN32)
    find_path(LUA51_INCLUDE_DIR lua.h
                   PATHS $ENV{PROGRAMFILES}/lua/5.1/include)
    include_directories(${LUA51_INCLUDE_DIR})
    find_library(LUA51_LIBRARY
                      NAMES lua5.1 lua51
                      PATHS $ENV{PROGRAMFILES}/lua/5.1/lib)
	find_program(LUA51_EXE
					NAMES lua5.1.exe lua.exe
				    PATHS $ENV{PROGRAMFILES}/lua/5.1)
else(WIN32)
    find_path(LUA51_INCLUDE_DIR lua5.1/lua.h)
    include_directories(${LUA51_INCLUDE_DIR}/lua5.1)
    
    find_library(LUA51_LIBRARY lua5.1)
	find_program(LUA51_EXE 
					NAMES lua5.1 lua)
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
add_library(yunit SHARED cppunit.cpp cppunit.h)
target_link_libraries(yunit ${LUA51_LIBRARY})
set_target_properties(yunit PROPERTIES 
                                    PREFIX "")
#
# trace
#
if(WIN32)
    add_library(trace SHARED trace.c)
    target_link_libraries(trace ${LUA51_LIBRARY})
endif(WIN32)
#
# minidump
#
if(WIN32)
    add_library(minidump SHARED minidump.c)
    target_link_libraries(minidump dbghelp ${LUA51_LIBRARY})
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
   set(SHARED_LIB_OUT_DIR "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_CFG_INTDIR}")
else(WIN32)
   set(SHARED_LIB_EXT "so")
   set(SHARED_LIB_OUT_DIR "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
endif(WIN32)

if(WIN32)
    add_custom_command(TARGET yunit.t
                       POST_BUILD
                       COMMAND ${LUA51_EXE} -e \"package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path\" -e \"package.cpath=[[${SHARED_LIB_OUT_DIR}/?.${SHARED_LIB_EXT};]]..package.cpath\" -l ${WORK_IN} -l yunit.default_test_run -e \"run([[${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_CFG_INTDIR}/yunit.t.${SHARED_LIB_EXT}]])\"
                       )
else(WIN32)
    add_test(yunit.t ${LUA51_EXE} -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -e "package.cpath=[[${SHARED_LIB_OUT_DIR}/?.${SHARED_LIB_EXT};]]..package.cpath" -l ${WORK_IN} -l yunit.default_test_run -e "run([[${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/yunit.t.${SHARED_LIB_EXT}]])")
endif(WIN32)


add_test(cppunit.t.lua ${LUA51_EXE} -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -e "package.cpath=[[${SHARED_LIB_OUT_DIR}/?.${SHARED_LIB_EXT};]]..package.cpath" -l ${WORK_IN} -l yunit.lua_test_run -e "run([[${CMAKE_CURRENT_SOURCE_DIR}/cppunit.t.lua]])")

add_test(filesystem.t.lua ${LUA51_EXE} -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -e "package.cpath=[[${SHARED_LIB_OUT_DIR}/?.${SHARED_LIB_EXT};]]..package.cpath" -l ${WORK_IN} -l yunit.lua_test_run -e "run([[${CMAKE_CURRENT_SOURCE_DIR}/filesystem.t.lua]])")

add_test(aux_test_func.t.lua ${LUA51_EXE} -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -e "package.cpath=[[${SHARED_LIB_OUT_DIR}/?.${SHARED_LIB_EXT};]]..package.cpath" -l ${WORK_IN} -l yunit.lua_test_run -e "run([[${CMAKE_CURRENT_SOURCE_DIR}/aux_test_func.t.lua]])")

add_test(lua_ext.t.lua ${LUA51_EXE} -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -e "package.cpath=[[${SHARED_LIB_OUT_DIR}/?.${SHARED_LIB_EXT};]]..package.cpath" -l ${WORK_IN} -l yunit.lua_test_run -e "run([[${CMAKE_CURRENT_SOURCE_DIR}/lua_ext.t.lua]])")

add_test(test_result_handlers.t.lua ${LUA51_EXE} -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -e "package.cpath=[[${SHARED_LIB_OUT_DIR}/?.${SHARED_LIB_EXT};]]..package.cpath" -l ${WORK_IN} -l yunit.lua_test_run -e "run([[${CMAKE_CURRENT_SOURCE_DIR}/test_result_handlers.t.lua]])")

add_test(luaunit.t.lua ${LUA51_EXE} -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -e "package.cpath=[[${SHARED_LIB_OUT_DIR}/?.${SHARED_LIB_EXT};]]..package.cpath" -l ${WORK_IN} -l yunit.lua_test_run -e "run([[${CMAKE_CURRENT_SOURCE_DIR}/luaunit.t.lua]])")

add_test(test_runner.t.lua ${LUA51_EXE} -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -e "package.cpath=[[${SHARED_LIB_OUT_DIR}/?.${SHARED_LIB_EXT};]]..package.cpath" -l ${WORK_IN} -l yunit.lua_test_run -e "run([[${CMAKE_CURRENT_SOURCE_DIR}/test_runner.t.lua]])")
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
    set(YUNIT_HEADERS_DIR include/lua5.1/yunit)
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
