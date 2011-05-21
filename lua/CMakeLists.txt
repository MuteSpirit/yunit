set(CMAKE_INCLUDE_CURRENT_DIR ON)

ADD_LIBRARY(lua51lib SHARED lapi.c lauxlib.c lbaselib.c lcode.c ldblib.c ldebug.c ldo.c ldump.c lfunc.c lgc.c linit.c  liolib.c llex.c lmathlib.c lmem.c loadlib.c lobject.c lopcodes.c loslib.c lparser.c  lstate.c lstring.c lstrlib.c ltable.c ltablib.c ltm.c lundump.c lvm.c lzio.c)
SET_TARGET_PROPERTIES(lua51lib PROPERTIES OUTPUT_NAME lua5.1)

ADD_LIBRARY(lua51proxy SHARED lua_proxy.c)
SET_TARGET_PROPERTIES(lua51proxy PROPERTIES OUTPUT_NAME lua51)

ADD_EXECUTABLE(lua51int lua.c)
SET_TARGET_PROPERTIES(lua51int PROPERTIES OUTPUT_NAME lua5.1)
TARGET_LINK_LIBRARIES(lua51int lua5.1 m)
ADD_DEPENDENCIES(lua51int lua51lib)

if(WIN32)
else(WIN32)
    install(TARGETS lua51lib DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)
    install(TARGETS lua51proxy DESTINATION ${CMAKE_INSTALL_PREFIX}/lib)
    install(TARGETS lua51int DESTINATION ${CMAKE_INSTALL_PREFIX}/bin)
    install(FILES lua.h lualib.h lauxlib.h luaconf.h ldebug.h DESTINATION ${CMAKE_INSTALL_PREFIX}/include/lua5.1)
endif(WIN32)