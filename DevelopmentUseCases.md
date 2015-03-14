== Working on Windows
  * I use command
```
cmake ..\yunit -G "Visual Studio 10"
```
to receive project and solution files for Visual Studio 2010 and work in convenient IDE

  * Usually, when there are failed tests during building project RUN\_TESTS, you don't see any output from yUnit execution. Simply define environment variable CTEST\_OUTPUT\_ON\_FAILURE, it is analog to usage CTest command line option --output-on-failure