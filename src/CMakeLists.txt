find_path(LUA51_INCLUDE_DIR lua5.1/lua.h)
include_directories(${LUA51_INCLUDE_DIR}/lua5.1)

find_library(LUA51_LIBRARY lua5.1)

if(WIN32)
    add_definitions(/EHsc) # Enable C++ exceptions
else(WIN32)
    add_definitions(-fexceptions) # Enable C++ exceptions
endif(WIN32)
#
# cppunit
#
# ADD_DEFINITIONS(-Wall -Wextra -pedantic -O3 -std=c++0x -fno-implicit-templates)
add_library(cppunit SHARED test.cpp ltest.cpp test.h)
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
endif(WIN32)
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
