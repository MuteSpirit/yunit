if(WIN32)
#
else(WIN32)
    install(FILES atd.lua aux_test_func.lua clean.lua filesystem.lua lopt.lua lua_ext.lua DESTINATION ${CMAKE_INSTALL_PREFIX}/lib/lua/yunit)
endif(WIN32)