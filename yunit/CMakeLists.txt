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
set(YUNIT_CONFIG_FILE_TEMPLATE yunit_lua_config.h.in)
set(YUNIT_FILES yunit.h cppunit.h cppunit.cpp lua_wrapper.h lua_wrapper.cpp lfs.cpp trace.h trace.cpp mine.h mine.cpp auxlib.h auxlib.cpp ${YUNIT_CONFIG_FILE_TEMPLATE})
if(WIN32)
    set(YUNIT_COMMON_LIBS )
else(WIN32)
    set(YUNIT_COMMON_LIBS ${CMAKE_THREAD_LIBS_INIT})
endif(WIN32)
#
# yunit.t
# 
set(YUNIT_T_FILES cppunit.t.cpp trace.t.cpp lua_wrapper.t.cpp mine.t.cpp)

#####################################################################################################################################
# function to add yunit project, linking concrete version of Lua library
#####################################################################################################################################
function(yunitProject LUA_VERSION)
    set(YUNIT_LIB_TARGET_NAME yunit_lua_${LUA_VERSION})
    set(LUA_LIB_TARGET_NAME lua_lib_${LUA_VERSION})
    set(LUA_LIB_OUT_NAME lua${LUA_VERSION}) # @todo брать прямо из настроек проекта
    set(LUA_INT_TARGET_NAME lua_int_${LUA_VERSION})

    find_path(LUA_${LUA_VERSION}_INCLUDE_DIR NAMES lua.h PATHS ${CMAKE_CURRENT_SOURCE_DIR}/../lua_${LUA_VERSION}/src)
    #
    # autogeneration of yuni_lua_??.h config file
    set(YUNIT_CONFIG_FILE_HEADER ${YUNIT_LIB_TARGET_NAME}.h)
    file(READ ${YUNIT_CONFIG_FILE_TEMPLATE} YUNIT_LUA_CONFIG_HEADER_TEXT)
    string(REGEX REPLACE "OUTPUT_NAME" "${YUNIT_LIB_TARGET_NAME}" YUNIT_LUA_CONFIG_HEADER_TEXT ${YUNIT_LUA_CONFIG_HEADER_TEXT})
    file(WRITE ${YUNIT_CONFIG_FILE_HEADER} ${YUNIT_LUA_CONFIG_HEADER_TEXT})
    
    add_library(${YUNIT_LIB_TARGET_NAME} SHARED ${YUNIT_FILES} ${YUNIT_CONFIG_FILE_HEADER})
    add_dependencies(${YUNIT_LIB_TARGET_NAME} ${LUA_LIB_TARGET_NAME})
    target_link_libraries(${YUNIT_LIB_TARGET_NAME} ${YUNIT_COMMON_LIBS} ${LUA_LIB_OUT_NAME})
    
    # we have to set property COMPILE_FLAGS /I, because each of yunit projects, compiled with concrete Lua library version, so if we use command 'include_directories', then each yunit project will have paths of every Lua include directory in it's AdditionalIncludeDirectories and will use wrong lua.h file
    #
    # we set CONFIG_HEADER to use macro LUA_SUBMODULE from yunit_lua_${LUA_VERSION}.h
    # 
    set_target_properties(${YUNIT_LIB_TARGET_NAME}
                            PROPERTIES 
                                PREFIX ""
                                COMPILE_FLAGS "/I\"${LUA_${LUA_VERSION}_INCLUDE_DIR}\" /D\"CONFIG_HEADER=${YUNIT_CONFIG_FILE_HEADER}\""
                                LIBRARY_OUTPUT_NAME ${YUNIT_LIB_TARGET_NAME}
    )
    #
    # yunit.t
    # 
    set(YUNIT_T_TARGET_NAME yunit_t_lua_${LUA_VERSION})
    set(YUNIT_T_OUT_NAME yunit_lua_${LUA_VERSION}.t)
    
    add_library(${YUNIT_T_TARGET_NAME} SHARED ${YUNIT_T_FILES})
    target_link_libraries(${YUNIT_T_TARGET_NAME} ${YUNIT_LIB_TARGET_NAME})
    add_dependencies(${YUNIT_T_TARGET_NAME} ${YUNIT_LIB_TARGET_NAME} ${LUA_INT_TARGET_NAME})
    
    set_target_properties(${YUNIT_T_TARGET_NAME}
                            PROPERTIES
                                PREFIX ""
                                COMPILE_FLAGS /I"${LUA_${LUA_VERSION}_INCLUDE_DIR}"
                                LIBRARY_OUTPUT_NAME ${YUNIT_T_OUT_NAME}
                                LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/lua_${LUA_VERSION}
    )
    #
    # Tests
    # 
    if(WIN32)
        set(SHARED_LIB_EXT "dll")
        set(SHARED_LIB_OUT_DIR "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
    else(WIN32)
        set(SHARED_LIB_EXT "so")
        set(SHARED_LIB_OUT_DIR "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
    endif(WIN32)
    
    # using customized package.path and package.cpath to used only binaries from working directory and not from system
    set(SET_LUA_PATH -e "package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;${CMAKE_CURRENT_SOURCE_DIR}/../?/init.lua;]]..package.path")
    
    set(SET_LUA_CPATH -e "package.cpath=[[${SHARED_LIB_OUT_DIR}/?.${SHARED_LIB_EXT};]]..package.cpath")
 
    # use Lua interpretator utility, linked with the same version Lua library
    get_target_property(LUA_${LUA_VERSION}_EXEC_DIR ${LUA_INT_TARGET_NAME} RUNTIME_OUTPUT_DIRECTORY)
    get_target_property(LUA_${LUA_VERSION}_EXEC_FILENAME ${LUA_INT_TARGET_NAME} OUTPUT_NAME)
    set(LUA_${LUA_VERSION}_EXEC ${LUA_${LUA_VERSION}_EXEC_DIR}/${LUA_${LUA_VERSION}_EXEC_FILENAME})
    
    get_target_property(YUNIT_T_TARGET_PATH ${YUNIT_T_TARGET_NAME} LOCATION)
    
    # we haven't to use <CONFIGURATION> directory in path to Lua interpreter executable file, because CTest will try to find in config subdirectory itself
    
    #add_test(cpp_tests ${LUA_${LUA_VERSION}_EXEC} -l yunit -e "use{'yunit.cppunit'}" -e "run[[${YUNIT_T_TARGET_PATH}]]")
    
#    add_test(all_cppunit_lua_${LUA_VERSION}_tests ${LUA_51_EXEC} ${SET_LUA_PATH} ${SET_LUA_CPATH} -l yunit -e "use{'yunit.cppunit', 'yunit.luaunit'}" -e "run{[[${SHARED_LIB_OUT_DIR}/lua_${LUA_VERSION}]], [[${CMAKE_CURRENT_SOURCE_DIR}]]}")

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

foreach(LUA_VERSION 51 52)
    yunitProject(${LUA_VERSION})
endforeach(LUA_VERSION)    