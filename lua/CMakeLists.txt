set(CMAKE_INCLUDE_CURRENT_DIR ON)

add_library(lua51lib SHARED lapi.c lauxlib.c lbaselib.c lcode.c ldblib.c ldebug.c ldo.c ldump.c lfunc.c lgc.c linit.c  liolib.c llex.c lmathlib.c lmem.c loadlib.c lobject.c lopcodes.c loslib.c lparser.c  lstate.c lstring.c lstrlib.c ltable.c ltablib.c ltm.c lundump.c lvm.c lzio.c)

add_executable(lua51int lua.c)
target_link_libraries(lua51int lua5.1 m)
add_dependencies(lua51int lua5.1)