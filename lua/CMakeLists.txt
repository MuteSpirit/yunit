set(CMAKE_INCLUDE_CURRENT_DIR ON)

### \todo use in future
# if(WIN32)
#    set_target_properties(WindowApplicationExample PROPERTIES LINK_FLAGS_DEBUG "/SUBSYSTEM:CONSOLE")
#    set_target_properties(WindowApplicationExample PROPERTIES COMPILE_DEFINITIONS_DEBUG "_CONSOLE")
#    set_target_properties(WindowApplicationExample PROPERTIES LINK_FLAGS_RELWITHDEBINFO "/SUBSYSTEM:CONSOLE")
#    set_target_properties(WindowApplicationExample PROPERTIES COMPILE_DEFINITIONS_RELWITHDEBINFO "_CONSOLE")
#    set_target_properties(WindowApplicationExample PROPERTIES LINK_FLAGS_RELEASE "/SUBSYSTEM:WINDOWS")
#    set_target_properties(WindowApplicationExample PROPERTIES LINK_FLAGS_MINSIZEREL "/SUBSYSTEM:WINDOWS")
# endif(WIN32)

add_library(lua5.1lib SHARED lapi.c lauxlib.c lbaselib.c lcode.c ldblib.c ldebug.c ldo.c ldump.c lfunc.c lgc.c linit.c  liolib.c llex.c lmathlib.c lmem.c loadlib.c lobject.c lopcodes.c loslib.c lparser.c  lstate.c lstring.c lstrlib.c ltable.c ltablib.c ltm.c lundump.c lvm.c lzio.c)

add_library(lua51 SHARED lua_proxy.c)

add_executable(lua5.1 lua.c)
target_link_libraries(lua5.1 lua5.1lib m)
add_dependencies(lua5.1 lua5.1lib)