# **yUnit** (Yet another xUnit) #

## Features ##
  1. **C++** and **Lua** unit testing engines with:
    * Simple syntax
    * Fixtures (setUp and tearDown methods)
    * Ignoring unit test with "ground" symbol
  1. Compiler-like text output to integrate with Visual Studio, SciTE and NetBeans
  1. Protection of the endless tests
  1. Test runner written in Lua (5.1 and 5.2 supported)
  1. Test runner and test containers (`*.t.dll, *.t.so, *.t.lua`) are different essences
  1. Run test containers individualy and group (i.e. all in some folder)
  1. XML report with test results
  1. CMake used as build tool

## Roadmap ##
  * Usability improvement
  * Filter running tests
  * Creating minidump in case of test run crashing
  * Python unit test framework
  * Code coverage