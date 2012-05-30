# We need to link Lua as dynamic library(ies)
#? If we link lua statically, then lua command interpreter and yunit DLL will have 
#? own copy of lua core copy. So when Lua of yunit.cppunit will allocate new TestCase objects and return
#? them from 'loadTestContainer' call, then Lua of command interpreter will try to delete them after 
#? finish usage and will crash with 'HEAP CORRUPTION' error

if(NOT WIN32)
# use Ptreads library
    find_package (Threads)
endif(NOT WIN32)
#
# Enable C++ exceptions
#
if(MSVC)
    add_definitions(/EHsc /D_CRT_SECURE_NO_WARNINGS)
else(MSVC)
    add_definitions(-fexceptions -std=c++0x)
endif(MSVC)
#
# yunit
#
set(YUNIT_FILES yunit.h cppunit.h cppunit.cpp lua_wrapper.h lua_wrapper.cpp lfs.cpp trace.h trace.cpp mine.h mine.cpp auxlib.h auxlib.cpp)
if(WIN32)
    set(YUNIT_COMMON_LIBS )
else(WIN32)
    set(YUNIT_COMMON_LIBS ${CMAKE_THREAD_LIBS_INIT})
endif(WIN32)
#
# yunit.t

set(YUNIT_T_FILES cppunit.t.cpp trace.t.cpp lua_wrapper.t.cpp mine.t.cpp)
#
# Tests

if(WIN32)
    set(SHARED_LIB_EXT "dll")
    set(SHARED_LIB_OUT_DIR "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
else(WIN32)
    set(SHARED_LIB_EXT "so")
    set(SHARED_LIB_OUT_DIR "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
endif(WIN32)
set(SET_LUA_PATH -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;${CMAKE_CURRENT_SOURCE_DIR}/../?/init.lua;]]..package.path")

#####################################################################################################################################
# function to add yunit project, linking concrete version of Lua library
#####################################################################################################################################
function(yunitProject LUA_VERSION)
    set(YUNIT_LIB_TARGET_NAME yunit_lua_${LUA_VERSION})
    set(LUA_LIB_TARGET_NAME lua_lib_${LUA_VERSION})
    set(LUA_LIB_OUT_NAME lua${LUA_VERSION})
    
    find_path(LUA_${LUA_VERSION}_INCLUDE_DIR        NAMES lua.h                PATHS ${CMAKE_CURRENT_SOURCE_DIR}/../lua_${LUA_VERSION}/src)
### @todo Попытаться как-то получать из настроект TARGET-а проекта сборки интерпретатора lua, его выходную директорию
    if(WIN32)
        find_program(LUA_${LUA_VERSION}_EXEC        NAMES lua${LUA_VERSION}.exe   PATHS ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
    else(WIN32)
        find_program(LUA_${LUA_VERSION}_EXEC        NAMES lua${LUA_VERSION}       PATHS ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
    endif(WIN32)

    add_library(${YUNIT_LIB_TARGET_NAME} SHARED ${YUNIT_FILES})
    add_dependencies(${YUNIT_LIB_TARGET_NAME} ${LUA_LIB_TARGET_NAME})
    
    target_link_libraries(${YUNIT_LIB_TARGET_NAME} ${YUNIT_COMMON_LIBS} ${LUA_LIB_OUT_NAME})

#    set_property(TARGET ${YUNIT_LIB_TARGET_NAME}
#                 #APPEND 
#                 PROPERTY INCLUDE_DIRECTORIES "E:/_works/w_yunit/yunit/lua_5.2/src")

    set_target_properties(${YUNIT_LIB_TARGET_NAME}
                            PROPERTIES 
                                PREFIX ""
                                COMPILE_FLAGS "/I\"${LUA_${LUA_VERSION}_INCLUDE_DIR}\" /I\"%(AdditionalIncludeDirectories)\""
                                LIBRARY_OUTPUT_NAME ${YUNIT_LIB_TARGET_NAME}
    )

    message("!!!")
    message(${LUA_${LUA_VERSION}_INCLUDE_DIR})
    message("!!!")

    if(WIN32)
        # we copy target files (*.dll, *.pdb) outside $(Configuration) directory, because on WIN32 value of 
        # ${CMAKE_CFG_INTDIR} is equal to '$(Configuration)' and not substituted by real name (Debug, Release, etc).
        # So we cannot use value ${CMAKE_CFG_INTDIR} in test and install commands
        add_custom_command(TARGET ${YUNIT_LIB_TARGET_NAME}
                           POST_BUILD
                           COMMAND copy /b /y $(TargetPath) $(TargetDir)\\..
                           COMMAND copy /b /y $(TargetDir)\\$(TargetName).pdb $(TargetDir)\\..
        )
    endif(WIN32)
    
    #
    # yunit.t
    set(YUNIT_T_TARGET_NAME yunit_t_lua_${LUA_VERSION})
    set(YUNIT_T_OUT_NAME yunit_lua_${LUA_VERSION}.t)
    
    add_library(${YUNIT_T_TARGET_NAME} SHARED ${YUNIT_T_FILES})
    target_link_libraries(${YUNIT_T_TARGET_NAME} ${YUNIT_LIB_TARGET_NAME})
    set_target_properties(${YUNIT_T_TARGET_NAME}
                            PROPERTIES
                                PREFIX ""
                                LIBRARY_OUTPUT_NAME ${YUNIT_T_OUT_NAME}
                                LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/lua_${LUA_VERSION}
    )
    set_property(TARGET ${YUNIT_T_TARGET_NAME}
                 APPEND
                 PROPERTY INCLUDE_DIRECTORIES ${LUA_${LUA_VERSION}_INCLUDE_DIR})

    add_dependencies(${YUNIT_T_TARGET_NAME} ${YUNIT_LIB_TARGET_NAME})

    
    set(SET_LUA_CPATH -e "package.cpath=[[${SHARED_LIB_OUT_DIR}/?.${SHARED_LIB_EXT};]]..package.cpath")

    add_test(all_cppunit_lua_${LUA_VERSION}_tests ${LUA_51_EXEC} ${SET_LUA_PATH} ${SET_LUA_CPATH} -l yunit -e "use{'yunit.cppunit', 'yunit.luaunit'}" -e "run{[[${SHARED_LIB_OUT_DIR}/lua_${LUA_VERSION}]], [[${CMAKE_CURRENT_SOURCE_DIR}]]}")

    if(WIN32)
        # we copy target files (*.dll, *.pdb) outside $(Configuration) directory, because on WIN32 value of 
        # ${CMAKE_CFG_INTDIR} is equal to '$(Configuration)' and not substituted by real name (Debug, Release, etc).
        # So we cannot use value ${CMAKE_CFG_INTDIR} in test and install commands
        add_custom_command(TARGET ${YUNIT_T_TARGET_NAME}
                           POST_BUILD
                           COMMAND copy /b /y $(TargetPath) $(TargetDir)\\..
                           COMMAND copy /b /y $(TargetDir)\\$(TargetName).pdb $(TargetDir)\\..
        )
    endif(WIN32)

#    #
#    # Installation rules:
#    #
#    set(YUNIT_TARGETS yunit_lua51)
#    if(WIN32)
#        set(YUNIT_RUNTIME_DIR ${LUA_VERSION})
#        set(YUNIT_LIBRARY_DIR ${LUA_VERSION}/lib)
#        set(YUNIT_ARCHIVE_DIR ${LUA_VERSION}/lib)
#        install(FILES "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/yunit.pdb"
#                DESTINATION ${LUA_VERSION})
#        set(YUNIT_HEADERS_DIR ${LUA_VERSION}/include/yunit)
#        set(YUNIT_LUA_MODULES_DIR ${LUA_VERSION}/lua/yunit)
#    else(WIN32)
#        set(YUNIT_RUNTIME_DIR local/lib/lua/${LUA_VERSION})
#        set(YUNIT_LIBRARY_DIR local/lib/lua/${LUA_VERSION})
#        set(YUNIT_ARCHIVE_DIR local/lib/lua/${LUA_VERSION})
#        set(YUNIT_HEADERS_DIR include/lua${LUA_VERSION}/yunit)
#        set(YUNIT_LUA_MODULES_DIR local/lib/lua/${LUA_VERSION}/yunit)
#    endif(WIN32)
#
#    install(TARGETS ${YUNIT_TARGETS} 
#            RUNTIME DESTINATION ${YUNIT_RUNTIME_DIR}
#            LIBRARY DESTINATION ${YUNIT_LIBRARY_DIR}
#            ARCHIVE DESTINATION ${YUNIT_ARCHIVE_DIR})
#    install(DIRECTORY . 
#              DESTINATION ${YUNIT_HEADERS_DIR}
#              FILES_MATCHING 
#              PATTERN "*.h")
#    install(DIRECTORY . 
#              DESTINATION ${YUNIT_LUA_MODULES_DIR}
#              FILES_MATCHING 
#                PATTERN "*.lua"
#                PATTERN "*.t.lua" EXCLUDE)
endfunction(yunitProject)

set(LUA_VERSIONS 5.1 5.2)
foreach(LUA_VERSION ${LUA_VERSIONS})
    yunitProject(${LUA_VERSION})
endforeach(LUA_VERSION)    