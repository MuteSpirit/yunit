#
# Output binaries directories are situated one level up, then build directory.
# Reason: we can access to built files, without information about name of build directory
#
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/../_bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${PROJECT_BINARY_DIR}/../_lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")

link_directories("${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}")

#
# lua library
#
add_library(lualib SHARED lapi.c lauxlib.c lbaselib.c lcode.c ldblib.c ldebug.c ldo.c ldump.c lfunc.c lgc.c linit.c  liolib.c llex.c lmathlib.c lmem.c loadlib.c lobject.c lopcodes.c loslib.c lparser.c  lstate.c lstring.c lstrlib.c ltable.c ltablib.c ltm.c lundump.c lvm.c lzio.c)
set_target_properties(lualib PROPERTIES OUTPUT_NAME lua5.1)

if(WIN32)
    set_target_properties(lualib PROPERTIES 
                                        OUTPUT_NAME lua5.1
                                        COMPILE_DEFINITIONS "LUA_COMPAT_OPENLIB;_CRT_SECURE_NO_WARNINGS;LUA_BUILD_AS_DLL"
                                        LINK_FLAGS "/PDB:${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_CFG_INTDIR}/lualib.pdb")
else(WIN32)
    set_target_properties(lualib PROPERTIES 
                                        OUTPUT_NAME lua5.1
                                        COMPILE_DEFINITIONS "LUA_COMPAT_OPENLIB;")
endif(WIN32)
#
# lua interpretator
#
add_executable(luaint lua.c)
if(WIN32)
    set_target_properties(luaint PROPERTIES 
                                        OUTPUT_NAME lua5.1
                                        COMPILE_DEFINITIONS "LUA_COMPAT_OPENLIB;_CRT_SECURE_NO_WARNINGS;LUA_BUILD_AS_DLL"
                                        LINK_FLAGS "/PDB:${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_CFG_INTDIR}/luaint.pdb")
    target_link_libraries(luaint lua5.1)
else(WIN32)
    set_target_properties(luaint PROPERTIES 
                                        OUTPUT_NAME lua5.1
                                        COMPILE_DEFINITIONS "LUA_COMPAT_OPENLIB;")
    target_link_libraries(luaint lua5.1 m)
endif(WIN32)
add_dependencies(luaint lualib)
