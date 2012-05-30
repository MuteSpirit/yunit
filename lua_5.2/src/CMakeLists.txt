set(LUA_VERSION 5.2)
set(LUA_LIB_FILES lapi.c lauxlib.c lbaselib.c lbitlib.c lcode.c lcorolib.c lctype.c ldblib.c ldebug.c ldo.c ldump.c lfunc.c lgc.c linit.c liolib.c llex.c lmathlib.c lmem.c loadlib.c lobject.c lopcodes.c loslib.c lparser.c lstate.c lstring.c lstrlib.c ltable.c ltablib.c ltm.c lundump.c lvm.c lzio.c)
set(LUA_FILES lua.c)

#
# lua library
set(LUA_LIB_TARGET_NAME lua_lib_${LUA_VERSION})
set(LUA_LIB_OUT_NAME lua${LUA_VERSION})

add_library(${LUA_LIB_TARGET_NAME} ${LUA_LIB_FILES})
set_target_properties(${LUA_LIB_TARGET_NAME} PROPERTIES OUTPUT_NAME ${LUA_LIB_OUT_NAME})

if(WIN32)
    set_target_properties(${LUA_LIB_TARGET_NAME} PROPERTIES 
                                        OUTPUT_NAME ${LUA_LIB_OUT_NAME}
                                        COMPILE_DEFINITIONS "LUA_COMPAT_OPENLIB;_CRT_SECURE_NO_WARNINGS"
                                        LINK_FLAGS "/PDB:${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_CFG_INTDIR}/liblua${LUA_VERSION}.pdb")
else(WIN32)
    set_target_properties(${LUA_LIB_TARGET_NAME} PROPERTIES 
                                        OUTPUT_NAME ${LUA_LIB_OUT_NAME}
                                        COMPILE_DEFINITIONS "LUA_COMPAT_OPENLIB;")
endif(WIN32)

if(WIN32)
    # we copy target files (*.dll, *.pdb, *.lib) outside $(Configuration) directory, because on WIN32 value of 
    # ${CMAKE_CFG_INTDIR} is equal to '$(Configuration)' and not substituted by real name (Debug, Release, etc).
    # So we cannot use value ${CMAKE_CFG_INTDIR} in test and install commands
    add_custom_command(TARGET ${LUA_LIB_TARGET_NAME}
                       POST_BUILD
                       COMMAND copy /b /y $(TargetPath) $(TargetDir)\\..
                       COMMAND copy /b /y $(TargetDir)\\$(TargetName).pdb $(TargetDir)\\..
    )
endif(WIN32)

#
# lua interpretator
set(LUA_INT_TARGET_NAME lua_int_${LUA_VERSION})
set(LUA_INT_OUT_NAME lua${LUA_VERSION})

add_executable(${LUA_INT_TARGET_NAME} ${LUA_FILES})
if(WIN32)
    set_target_properties(${LUA_INT_TARGET_NAME} PROPERTIES 
                                 OUTPUT_NAME ${LUA_INT_OUT_NAME}
                                 COMPILE_DEFINITIONS "LUA_COMPAT_OPENLIB;_CRT_SECURE_NO_WARNINGS"
                                 LINK_FLAGS "/PDB:${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_CFG_INTDIR}/lua${LUA_VERSION}.pdb")
    target_link_libraries(${LUA_INT_TARGET_NAME} ${LUA_LIB_OUT_NAME})
else(WIN32)
    set_target_properties(${LUA_INT_TARGET_NAME} PROPERTIES 
                                 OUTPUT_NAME ${LUA_INT_OUT_NAME}
                                 COMPILE_DEFINITIONS "LUA_COMPAT_OPENLIB;")
    target_link_libraries(${LUA_INT_TARGET_NAME} ${LUA_LIB_OUT_NAME} m)
endif(WIN32)
add_dependencies(${LUA_INT_TARGET_NAME} ${LUA_LIB_TARGET_NAME})

if(WIN32)
    # we copy target files (*.dll, *.pdb) outside $(Configuration) directory, because on WIN32 value of 
    # ${CMAKE_CFG_INTDIR} is equal to '$(Configuration)' and not substituted by real name (Debug, Release, etc).
    # So we cannot use value ${CMAKE_CFG_INTDIR} in test and install commands
    add_custom_command(TARGET ${LUA_INT_TARGET_NAME}
                       POST_BUILD
                       COMMAND copy /b /y $(TargetPath) $(TargetDir)\\..
                       COMMAND copy /b /y $(TargetDir)\\$(TargetName).pdb $(TargetDir)\\..
    )
endif(WIN32)
