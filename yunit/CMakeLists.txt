find_path(LUA51_INCLUDE_DIR lua5.1/lua.h)
include_directories(${LUA51_INCLUDE_DIR}/lua5.1)

find_library(LUA51_LIBRARY lua5.1)
#
# Enable C++ exceptions
#
if(MSVC)
    add_definitions(/EHsc)
else(MSVC)
    add_definitions(-fexceptions)
endif(MSVC)
#
# cppunit
#
add_library(cppunit SHARED test.cpp test.h)
target_link_libraries(cppunit ${LUA51_LIBRARY})
#
# trace
#
if(WIN32)
    add_library(trace SHARED trace.c)
    target_link_libraries(trace lua5.1)
endif(WIN32)
#
# minidump
#
if(WIN32)
    add_library(minidump SHARED minidump.c)
    target_link_libraries(minidump dbghelp lua5.1)
endif(WIN32)
#
# cppunit.t
#
add_library(cppunit.t SHARED test.t.cpp)
target_link_libraries(cppunit.t cppunit)
if(WIN32)
    add_dependencies(cppunit.t cppunit trace)
    add_custom_command(TARGET cppunit.t 
                       POST_BUILD
                       COMMAND "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/$(Configuration)/lua5.1.exe" -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;${CMAKE_CURRENT_SOURCE_DIR}/../ts_modules/?.lua;]] .. package.path" -l yunit.work_in_vs -l yunit.default_test_run -e \"run([[${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/$(Configuration)/cppunit.t.dll]])\"
                      )
else(WIN32)
    add_dependencies(cppunit.t cppunit)
#    message(${CMAKE_CURRENT_SOURCE_DIR})
#    message(${CMAKE_LIBRARY_OUTPUT_DIRECTORY})
    add_test(cppunit.t lua5.1 -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -e "package.cpath=[[${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/lib?.so;]]..package.cpath" -l yunit.work_in_scite -l yunit.default_test_run -e "run[[$<TARGET_FILE:cppunit.t>]]")
endif(WIN32)
#
# Tests
#
add_test(filesystem.t.lua lua5.1 -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -l yunit.lua_test_run -l yunit.work_in_scite -e "run[[${CMAKE_CURRENT_SOURCE_DIR}/filesystem.t.lua]]")

add_test(aux_test_func.t.lua lua5.1 -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -l yunit.lua_test_run -l yunit.work_in_scite -e "run[[${CMAKE_CURRENT_SOURCE_DIR}/aux_test_func.t.lua]]")

add_test(lua_ext.t.lua lua5.1 -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -l yunit.lua_test_run -l yunit.work_in_scite -e "run[[${CMAKE_CURRENT_SOURCE_DIR}/lua_ext.t.lua]]")

add_test(test_result_handlers.t.lua lua5.1 -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -l yunit.lua_test_run -l yunit.work_in_scite -e "run[[${CMAKE_CURRENT_SOURCE_DIR}/test_result_handlers.t.lua]]")

add_test(luaunit.t.lua lua5.1 -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -l yunit.lua_test_run -l yunit.work_in_scite -e "run[[${CMAKE_CURRENT_SOURCE_DIR}/luaunit.t.lua]]")

add_test(test_runner.t.lua lua5.1 -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -l yunit.lua_test_run -l yunit.work_in_scite -e "run[[${CMAKE_CURRENT_SOURCE_DIR}/test_runner.t.lua]]")

add_test(cppunit.t.lua lua5.1 -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;]]..package.path" -l yunit.lua_test_run -l yunit.work_in_scite -e "run[[${CMAKE_CURRENT_SOURCE_DIR}/cppunit.t.lua]]")
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
          FILES_MATCHING 
          PATTERN "*.h")
install(DIRECTORY . 
          DESTINATION ${YUNIT_LUA_MODULES_DIR}
          FILES_MATCHING 
            PATTERN "*.lua"
            PATTERN "*.t.lua" EXCLUDE)
