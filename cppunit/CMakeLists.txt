if(MSVC)
    add_definitions(/EHsc /D_CRT_SECURE_NO_WARNINGS)
else (MSVC)
    add_definitions(-fexceptions -std=c++0x -Wall) 
endif(MSVC)

include_directories(${PROJECT_SOURCE_DIR}/yunit) 
add_library(cpp_test_engine SHARED cpp_test_engine.cpp)

add_executable(asserts_test asserts.test.cpp asserts.cpp)
add_test(asserts_smoke_test ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/asserts_test)

add_executable(tests_test tests.test.cpp tests.cpp asserts.cpp)
add_test(tests_smoke_test ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/tests_test)
