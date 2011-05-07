set(CMAKE_INCLUDE_CURRENT_DIR ON)
INCLUDE_DIRECTORIES(..)

# additional compiler flags
add_definitions(-Wall -Wextra -pedantic -std=c++0x)

ADD_LIBRARY(cppunit SHARED test.cpp ltest.cpp)
ADD_LIBRARY(cppunit.t SHARED test.t.cpp)
TARGET_LINK_LIBRARIES(cppunit.t cppunit)
