set(LUA_VERSION 51)
set(LUA_LIB_FILES lapi.c lauxlib.c lbaselib.c lcode.c ldblib.c ldebug.c ldo.c ldump.c lfunc.c lgc.c linit.c liolib.c llex.c lmathlib.c lmem.c loadlib.c lobject.c lopcodes.c loslib.c lparser.c lstate.c lstring.c lstrlib.c ltable.c ltablib.c ltm.c lundump.c lvm.c lzio.c print.c)
#
# lua library
set(LUA_LIB_TARGET_NAME lua_lib_${LUA_VERSION})
set(LUA_LIB_OUT_NAME lua${LUA_VERSION})

# Lua library must be shared (DLL), because lua interpreter executable file won't be ableto use Lua binding module, built as DLL and returning something,
# created on heap, because process will crash during try to delete such objects in own (other then module) heap
add_library(${LUA_LIB_TARGET_NAME} SHARED ${LUA_LIB_FILES})
set_target_properties(${LUA_LIB_TARGET_NAME} PROPERTIES OUTPUT_NAME ${LUA_LIB_OUT_NAME})

if(WIN32)
    set_target_properties(${LUA_LIB_TARGET_NAME} PROPERTIES 
                                        OUTPUT_NAME ${LUA_LIB_OUT_NAME}
                                        COMPILE_DEFINITIONS "LUA_BUILD_AS_DLL;_CRT_SECURE_NO_WARNINGS"
                                        LINK_FLAGS "/PDB:${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_CFG_INTDIR}/liblua${LUA_VERSION}.pdb")
else(WIN32)
    if(UNIX)
        set_target_properties(${LUA_LIB_TARGET_NAME} PROPERTIES 
                                            OUTPUT_NAME ${LUA_LIB_OUT_NAME}
                                            COMPILE_DEFINITIONS "LUA_USE_LINUX")
        target_link_libraries(${LUA_LIB_TARGET_NAME} dl ncurses)
    else(UNIX)
        if(APPLE)
            set_target_properties(${LUA_LIB_TARGET_NAME} PROPERTIES 
                                                OUTPUT_NAME ${LUA_LIB_OUT_NAME}
                                                COMPILE_DEFINITIONS "LUA_USE_LINUX")
            target_link_libraries(${LUA_LIB_TARGET_NAME} dl readline)
        endif(APPLE)
    endif(UNIX)
endif(WIN32)

