set(CMAKE_INCLUDE_CURRENT_DIR ON)
#
# lua51lib
#
add_library(lua51lib SHARED lapi.c lauxlib.c lbaselib.c lcode.c ldblib.c ldebug.c ldo.c ldump.c lfunc.c lgc.c linit.c  liolib.c llex.c lmathlib.c lmem.c loadlib.c lobject.c lopcodes.c loslib.c lparser.c  lstate.c lstring.c lstrlib.c ltable.c ltablib.c ltm.c lundump.c lvm.c lzio.c version_lib.rc)
set_target_properties(lua51lib PROPERTIES OUTPUT_NAME lua5.1)

if(WIN32)
    set_target_properties(lua51lib PROPERTIES 
                                        OUTPUT_NAME lua5.1
                                        COMPILE_DEFINITIONS "LUA_COMPAT_OPENLIB;_CRT_SECURE_NO_WARNINGS;LUA_BUILD_AS_DLL"
                                        LINK_FLAGS "/PDB:${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_CFG_INTDIR}/lua51lib.pdb")
else(WIN32)
    set_target_properties(lua51lib PROPERTIES 
                                        OUTPUT_NAME lua5.1
                                        COMPILE_DEFINITIONS "LUA_COMPAT_OPENLIB;")
endif(WIN32)
#
# lua51proxy
#
add_library(lua51proxy SHARED lua_proxy.c version_proxy.rc)
target_link_libraries(lua51proxy lua5.1)
add_dependencies(lua51proxy lua51lib)
if(WIN32)
    set_target_properties(lua51proxy PROPERTIES
                                        OUTPUT_NAME lua51
                                        COMPILE_DEFINITIONS "LUA_COMPAT_OPENLIB;"
                                        LINK_FLAGS "/PDB:${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_CFG_INTDIR}/lua51proxy.pdb")
else(WIN32)
    set_target_properties(lua51proxy PROPERTIES
                                        OUTPUT_NAME lua51
                                        COMPILE_DEFINITIONS "LUA_COMPAT_OPENLIB;")
endif(WIN32)
#
# lua51int
#
add_executable(lua51int lua.c version_int.rc)
if(WIN32)
    set_target_properties(lua51int PROPERTIES 
                                        OUTPUT_NAME lua5.1
                                        COMPILE_DEFINITIONS "LUA_COMPAT_OPENLIB;_CRT_SECURE_NO_WARNINGS;LUA_BUILD_AS_DLL"
                                        LINK_FLAGS "/PDB:${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_CFG_INTDIR}/lua51int.pdb")
    target_link_libraries(lua51int lua5.1)
else(WIN32)
    set_target_properties(lua51int PROPERTIES 
                                        OUTPUT_NAME lua5.1
                                        COMPILE_DEFINITIONS "LUA_COMPAT_OPENLIB;")
    target_link_libraries(lua51int lua5.1 m)
endif(WIN32)
add_dependencies(lua51int lua51lib)
#
# Installation
#
if(WIN32)
    install(TARGETS lua51int lua51lib lua51proxy
            RUNTIME DESTINATION 5.1
            LIBRARY DESTINATION 5.1/lib
            ARCHIVE DESTINATION 5.1/lib)
    install(FILES 
                "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/RelWithDebInfo/lua51int.pdb"
                "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/RelWithDebInfo/lua51lib.pdb"
                "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/RelWithDebInfo/lua51proxy.pdb"
                CONFIGURATIONS RelWithDebInfo
                DESTINATION 5.1)
    install(FILES lauxlib.h ldebug.h lua.h luaconf.h lualib.h DESTINATION 5.1/include)
else(WIN32)
    install(TARGETS lua51int lua51lib lua51proxy
            RUNTIME DESTINATION bin
            LIBRARY DESTINATION lib
            ARCHIVE DESTINATION lib)
    install(FILES lua.h lualib.h lauxlib.h luaconf.h ldebug.h DESTINATION include/lua5.1)
endif(WIN32)