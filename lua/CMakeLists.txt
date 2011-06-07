set(CMAKE_INCLUDE_CURRENT_DIR ON)
#
# lua51lib
#
add_definitions(-DLUA_COMPAT_OPENLIB)
if(WIN32)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS -DLUA_BUILD_AS_DLL -DLUA_COMPAT_OPENLIB)
endif(WIN32)
add_library(lua51lib SHARED lapi.c lauxlib.c lbaselib.c lcode.c ldblib.c ldebug.c ldo.c ldump.c lfunc.c lgc.c linit.c  liolib.c llex.c lmathlib.c lmem.c loadlib.c lobject.c lopcodes.c loslib.c lparser.c  lstate.c lstring.c lstrlib.c ltable.c ltablib.c ltm.c lundump.c lvm.c lzio.c version_lib.rc)
set_target_properties(lua51lib PROPERTIES OUTPUT_NAME lua5.1)
get_property(LIB_OUT_DIR TARGET lua51lib PROPERTY LIBRARY_OUTPUT_DIRECTORY)
#
# lua51proxy
#
add_library(lua51proxy SHARED lua_proxy.c version_proxy.rc)
set_target_properties(lua51proxy PROPERTIES OUTPUT_NAME lua51)
target_link_libraries(lua51proxy lua5.1)
add_dependencies(lua51proxy lua51lib)
#
# lua51int
#
add_executable(lua51int lua.c version_int.rc)
set_target_properties(lua51int PROPERTIES OUTPUT_NAME lua5.1)
if(WIN32)
    target_link_libraries(lua51int lua5.1)
else(WIN32)
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
    install(FILES lauxlib.h ldebug.h lua.h luaconf.h lualib.h DESTINATION 5.1/include)
else(WIN32)
    install(TARGETS lua51lib DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)
    install(TARGETS lua51proxy DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)
    install(TARGETS lua51int DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
    install(FILES lua.h lualib.h lauxlib.h luaconf.h ldebug.h DESTINATION ${CMAKE_INSTALL_PREFIX}/include/lua5.1)
endif(WIN32)