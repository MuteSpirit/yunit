# yUnit Design #

## Introduction ##

There are main design assumes and aspects of yUnit project. It will contain already implemented and future implemented features and API. This test cannot be naturally situated in source code comments, because it describe whole project, different parts integration,  solutions reasons and so on.

## Fix Design for issues 3, 8, 12, 24 ##
Try to design implementation for fix next issues:
  * [Issue 3](https://code.google.com/p/yunit/issues/detail?id=3) Test create one more thread, that raise exception, test run process crash
  * [Issue 8](https://code.google.com/p/yunit/issues/detail?id=8) TestRunner set right working directory only, when run 1 test container
  * [Issue 12](https://code.google.com/p/yunit/issues/detail?id=12) Need time limit for unit test execution
  * [Issue 24](https://code.google.com/p/yunit/issues/detail?id=24) Need function for run all project tests

If we want to avoid whole process crash, when slave thread, created by main thread raise unhandled exception during test execution ([issue 3](https://code.google.com/p/yunit/issues/detail?id=3)), we need to run tests into separate process. Also such schema allow to set time limit for test ([issue 12](https://code.google.com/p/yunit/issues/detail?id=12)). It is too expensive to run every unit test into separated process, also we cannot load only one test from whole test container, so we will run all tests from one test container into separate process. In this case we may set write working directory, i.e. directory, where test container file situated, for that new process ([issue 8](https://code.google.com/p/yunit/issues/detail?id=8)). solving all above issues allow to fix [issue 24](https://code.google.com/p/yunit/issues/detail?id=24), because in current yUnit architecture such function cannot set write working directory for tests, because during loading test containers, it does not know what unit tests were loaded from concrete test container, and Test Case object hasn't such information.

In case of usage separate process, we have opportunity to miss unit test, crashed process by unhandled exception. How? We must remember all finished test by "head process" and in rerunning tests from test container, containing such problem test, but say child process to ignore it.

There is new problem with interprocess communication in new architecture. Try to implement simple scheme. Head process must share REST-interface over HTTP protocol, "child processed" may send information about their execution progress. This scheme is enough scalable, i.e. it is possible to run several child test runs, which asynchronously info "head".

I will try to use Xavante and LuaSocket projects. Also i will look for log server, written in Lua.



&lt;think&gt;

Maybe it is good idea now to build cppunit as static library (maybe not whole part of cppunit). Test containers will be linked into DLL, but contain independent global test registry, so different test containers will not know about alien tests. For exeple, getTestExtension... and loadTestContainer will be inside yunit.cppunit, but getTestList... - inside every test container DLL

&lt;/think&gt;





&lt;think&gt;


Чем неудобны Fixture в виде отдельных объектов, создаваемых в теле класса (у таких Fixture ctor() аля setUp(), а ~dtor() аля tearDown()), так это тем, что при возникновении Structed Exception не будут вызвады деструкторы таких объектов и не произойдет необходимая зачистка.


&lt;/think&gt;

