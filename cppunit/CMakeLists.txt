if(MSVC)
    add_definitions(/EHsc /D_CRT_SECURE_NO_WARNINGS)
else (MSVC)
    add_definitions(-fexceptions -std=c++0x -Wall) 
endif(MSVC)

include_directories(${PROJECT_SOURCE_DIR}/yunit) 
add_library(cpp_test_engine SHARED cpp_test_engine.cpp)
