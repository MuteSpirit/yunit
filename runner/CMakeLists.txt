if(MSVC)
    add_definitions(/EHsc /D_CRT_SECURE_NO_WARNINGS)
else (MSVC)
    add_definitions(-fexceptions -std=c++0x -Wall) 
endif(MSVC)


include_directories(${PROJECT_SOURCE_DIR}/lua_52 ${PROJECT_SOURCE_DIR}/yunit) 
add_executable(yunit yunit_main.cpp ../yunit/lua_wrapper.cpp test_engine.cpp)
add_dependencies(yunit liblua52)
target_link_libraries(yunit liblua52)
