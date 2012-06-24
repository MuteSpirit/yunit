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
    set(CPP_DEFS "/EHsc /D_CRT_SECURE_NO_WARNINGS")
else (MSVC)
    set(CPP_DEFS "-fexceptions -std=c++0x") 
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
set(RUN_YUNIT_CPP_TESTS_SRC_FILE_TEMPLATE run_cpp_tests.c.in)

#####################################################################################################################################
# function to add yunit project, linking concrete version of Lua library
#####################################################################################################################################
function(yunitProject LUA_VERSION)
    set(YUNIT_LIB_TARGET_NAME yunit_lua_${LUA_VERSION})
    set(LUA_LIB_TARGET_NAME lua_lib_${LUA_VERSION})
    set(LUA_LIB_OUT_NAME lua${LUA_VERSION}) # @todo ����� ����� �� �������� �������
    set(LUA_INT_TARGET_NAME lua_int_${LUA_VERSION})

    find_path(LUA_${LUA_VERSION}_INCLUDE_DIR NAMES lua.h PATHS ${CMAKE_CURRENT_SOURCE_DIR}/../lua_${LUA_VERSION}/src)
    #
    # autogeneration of yuni_lua_??.h config file
    # !!! you must quotes around the variable, keeped file content, to save semicolon (;) from original file text.
    # !!! This is strange CMake behaviour (bug #10107, http://public.kitware.com/Bug/view.php?id=10107)
    set(YUNIT_CONFIG_FILE_HEADER ${YUNIT_LIB_TARGET_NAME}.h)
    file(READ ${YUNIT_CONFIG_FILE_TEMPLATE} YUNIT_LUA_CONFIG_HEADER_TEXT)
    string(REGEX REPLACE "OUTPUT_NAME" "${YUNIT_LIB_TARGET_NAME}" YUNIT_LUA_CONFIG_HEADER_TEXT "${YUNIT_LUA_CONFIG_HEADER_TEXT}")
    file(WRITE ${YUNIT_CONFIG_FILE_HEADER} "${YUNIT_LUA_CONFIG_HEADER_TEXT}")
    
    # we build yunit library as DLL, because it may be used by test container, linked with different (and maybe incompatible version of Lua)
    
    add_library(${YUNIT_LIB_TARGET_NAME} SHARED ${YUNIT_FILES} ${YUNIT_CONFIG_FILE_HEADER})
    add_dependencies(${YUNIT_LIB_TARGET_NAME} ${LUA_LIB_TARGET_NAME})
    target_link_libraries(${YUNIT_LIB_TARGET_NAME} ${YUNIT_COMMON_LIBS} ${LUA_LIB_OUT_NAME})
    
    # we have to set property COMPILE_FLAGS /I, because each of yunit projects, compiled with concrete Lua library version, so if we use command 'include_directories', then each yunit project will have paths of every Lua include directory in it's AdditionalIncludeDirectories and will use wrong lua.h file
    #
    # we set CONFIG_HEADER to use macro LUA_SUBMODULE from yunit_lua_${LUA_VERSION}.h
    # 
    if (MSVC)
        set(INC_DIR_FLAG "/I")
        set(DEFINE_FLAG "/D")
    else (MSVC)
        set(INC_DIR_FLAG "-I")
        set(DEFINE_FLAG "-D")
    endif(MSVC)
    
    set_target_properties(${YUNIT_LIB_TARGET_NAME} 
        PROPERTIES 
            PREFIX ""
            COMPILE_FLAGS "${CPP_DEFS} ${INC_DIR_FLAG}\"${CMAKE_CURRENT_SOURCE_DIR}\" ${INC_DIR_FLAG}\"${LUA_${LUA_VERSION}_INCLUDE_DIR}\" ${DEFINE_FLAG}\"CONFIG_HEADER=${YUNIT_CONFIG_FILE_HEADER}\""
            OUTPUT_NAME ${YUNIT_LIB_TARGET_NAME})
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
                                COMPILE_FLAGS "${CPP_DEFS} ${INC_DIR_FLAG}\"${CMAKE_CURRENT_SOURCE_DIR}\" ${INC_DIR_FLAG}\"${LUA_${LUA_VERSION}_INCLUDE_DIR}\" ${DEFINE_FLAG}\"OUTPUT_NAME=${YUNIT_T_OUT_NAME}\""
                                OUTPUT_NAME ${YUNIT_T_OUT_NAME}
                                LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/lua_${LUA_VERSION}
    )
    #
    # Tests
    # 
    if(WIN32)
        # we copy target files (*.dll, *.pdb) outside $(Configuration) directory, because on WIN32 value of 
        # ${CMAKE_CFG_INTDIR} is equal to '$(Configuration)' and not substituted by real name (Debug, Release, etc).
        #
        # !!! So we cannot use ${CMAKE_CFG_INTDIR} in tests and install commands !!!
                           
        add_custom_command(TARGET ${YUNIT_LIB_TARGET_NAME}
                           POST_BUILD
                           COMMAND ${COPY_TARGET_FILES})
                           
        add_custom_command(TARGET ${YUNIT_T_TARGET_NAME} 
                           POST_BUILD
                           COMMAND ${COPY_TARGET_FILES})
    endif(WIN32)

    if(WIN32)
        set(SHARED_LIB_EXT "dll")
        set(SHARED_LIB_OUT_DIR "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
    else(WIN32)
        set(SHARED_LIB_EXT "so")
        set(SHARED_LIB_OUT_DIR "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}")
    endif(WIN32)
    
    # use Lua interpretator utility, linked with the same version Lua library
    get_target_property(LUA_${LUA_VERSION}_EXEC_DIR ${LUA_INT_TARGET_NAME} RUNTIME_OUTPUT_DIRECTORY)
    get_target_property(LUA_${LUA_VERSION}_EXEC_FILENAME ${LUA_INT_TARGET_NAME} OUTPUT_NAME)
    set(LUA_${LUA_VERSION}_EXEC ${LUA_${LUA_VERSION}_EXEC_DIR}/${LUA_${LUA_VERSION}_EXEC_FILENAME})
    
    get_target_property(YUNIT_T_TARGET_DIR ${YUNIT_T_TARGET_NAME} RUNTIME_OUTPUT_DIRECTORY)
    set(YUNIT_T_TARGET_PATH ${YUNIT_T_TARGET_DIR}/${YUNIT_T_OUT_NAME}.${SHARED_LIB_EXT})

    # if run test with CTest then you will not have ability to debug some unit test code
    #    => we create separate executable to run tests under debugging
    # yUnit try to support several versions of Lua and they can't correctly run test projects of each other
    #    => we create separate executable for every Lua version
    ### @todo Add project to run *.t.lua tests
    
    set(YUNIT_LUA_${LUA_VERSION}_SRC_FILE yunit_lua_${LUA_VERSION}_cpp_tests_main.c)
    file(READ ${RUN_YUNIT_CPP_TESTS_SRC_FILE_TEMPLATE} RUN_TESTS_SOURCE_CODE)
    
    # string(REGEX REPLACE "ARGUMENTS" "${YUNIT_LUA_${LUA_VERSION}_TEST_CMD_ARG}" "${LUA_${LUA_VERSION}_EXEC}" RUN_TESTS_SOURCE_CODE "${RUN_TESTS_SOURCE_CODE}")
    # using customized package.path and package.cpath to used only binaries from working directory and not from system
    # string(REGEX REPLACE "LUA_PATH_ENV" "${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;${CMAKE_CURRENT_SOURCE_DIR}/../?/init.lua;" RUN_TESTS_SOURCE_CODE "${RUN_TESTS_SOURCE_CODE}")
    # string(REGEX REPLACE "LUA_CPATH_ENV" "${SHARED_LIB_OUT_DIR}/?.${SHARED_LIB_EXT};" RUN_TESTS_SOURCE_CODE "${RUN_TESTS_SOURCE_CODE}")
    # use four slashes to get one slash after REGEX REPLACE
    # set(YUNIT_LUA_${LUA_VERSION}_TEST_CMD_ARG "-l yunit -e \\\\\"use{'yunit.cppunit'}\\\\\" -e \\\\\"run[[${YUNIT_T_TARGET_PATH}]]\\\\\"")
    # string(REGEX REPLACE "CMD_LINE_ARG" "${YUNIT_LUA_${LUA_VERSION}_TEST_CMD_ARG}" RUN_TESTS_SOURCE_CODE "${RUN_TESTS_SOURCE_CODE}")
    
    set(CMD_ARG "\"${LUA_${LUA_VERSION}_EXEC}\"")
    
    # using customized package.path and package.cpath to used only binaries from working directory and not from system
    set(CMD_ARG "${CMD_ARG},\n\t\t\"-e\", \"package.path=[[${CMAKE_CURRENT_SOURCE_DIR}/../?.lua;${CMAKE_CURRENT_SOURCE_DIR}/../?/init.lua;]]..package.path\"")
    set(CMD_ARG "${CMD_ARG},\n\t\t\"-e\", \"package.cpath=[[${SHARED_LIB_OUT_DIR}/?.${SHARED_LIB_EXT};]]..package.cpath\"")
                                  
    set(CMD_ARG "${CMD_ARG},\n\t\t\"-l\", \"yunit\"")
    set(CMD_ARG "${CMD_ARG},\n\t\t\"-e\", \"use{'yunit.cppunit'}\"")         # use 4 slashes to get 1 slash after REGEX REPLACE                
    set(CMD_ARG "${CMD_ARG},\n\t\t\"-e\", \"run[[${YUNIT_T_TARGET_PATH}]]\"") # use 4 slashes to get 1 slash after REGEX REPLACE                

    string(REGEX REPLACE "ARGUMENTS" "${CMD_ARG}" RUN_TESTS_SOURCE_CODE "${RUN_TESTS_SOURCE_CODE}")
    file(WRITE ${YUNIT_LUA_${LUA_VERSION}_SRC_FILE} "${RUN_TESTS_SOURCE_CODE}")
    
    add_executable(yunit_lua_${LUA_VERSION}_cpp_tests ${YUNIT_LUA_${LUA_VERSION}_SRC_FILE})
    
    # set spectial include directory to use #include <lua.c> for concrete Lua version interpreter source code file
    set_target_properties(yunit_lua_${LUA_VERSION}_cpp_tests 
        PROPERTIES 
            COMPILE_FLAGS "${INC_DIR_FLAG}\"${LUA_${LUA_VERSION}_INCLUDE_DIR}\"")

    add_dependencies(yunit_lua_${LUA_VERSION}_cpp_tests ${LUA_INT_TARGET_NAME} ${YUNIT_T_TARGET_NAME})
    target_link_libraries(yunit_lua_${LUA_VERSION}_cpp_tests ${LUA_LIB_OUT_NAME})
    
    # ${LUA_${LUA_VERSION}_EXEC} ${SET_LUA_PATH} ${SET_LUA_CPATH} -l yunit -e "use{'yunit.cppunit'}" -e "run[[${YUNIT_T_TARGET_PATH}]]"
    
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

# we cannot use points in yunit shared library output file name, because it will not allow use it in Lua "require" command argument. So Lua version is 51 or 52 and no 5.1 and 5.2
foreach(LUA_VERSION 51 52)
    yunitProject(${LUA_VERSION})
endforeach(LUA_VERSION)    