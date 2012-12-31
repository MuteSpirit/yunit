add_executable(asserts_test asserts.test.cpp asserts.cpp)
add_test(asserts_smoke_test ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/asserts_test)
