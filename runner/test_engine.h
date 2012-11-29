//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// @file test_engine.h
// 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef _TEST_ENGINE_HEADER_
#define _TEST_ENGINE_HEADER_

#include "lua_wrapper.h"

/// @todo add end of line in MacOS X style
#ifdef _WIN32
#  define ENDL "\r\n"
#else
#  define ENDL "\n"
#endif

class TestEngine;
class TestContainer;
class TestCase;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
LUA_CLASS(TestEngine)
{
    /// @param path Path to dynamic link library file with Test Engine feature and some C API functions:
    /// @return object or nil and error message
    ADD_CONSTRUCTOR(TestEngine);

	ADD_DESTRUCTOR(TestEngine);

    /// @fn load(testContainerPath)
    ADD_METHOD(TestEngine, load);

    /// @fn unload()
    ADD_METHOD(TestEngine, unload);
};

DEFINE_LUA_TO(TestEngine)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
LUA_CLASS(TestContainer)
{
	/// @fn tests()
	/// @return Table with all TestCase object of current test container
	ADD_METHOD(TestContainer, tests);

	/// @fn load()
	/// @return none
	ADD_METHOD(TestContainer, load);

	/// @fn unload()
	/// @return none
	ADD_METHOD(TestContainer, unload);

	ADD_DESTRUCTOR(TestContainer);
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
LUA_CLASS(TestCase)
{
    ADD_METHOD(TestCase, start);
    
    ADD_METHOD(TestCase, setUp);
    ADD_METHOD(TestCase, test);
    ADD_METHOD(TestCase, tearDown);

    ADD_METHOD(TestCase, isIgnored);
    
    ADD_METHOD(TestCase, name);
    ADD_METHOD(TestCase, source);
    ADD_METHOD(TestCase, line);
};

DEFINE_LUA_TO(TestCase)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class SimpleLogger
{
    typedef SimpleLogger Self;
    struct Step 
    {
        enum {setUp, test, tearDown};
    };
    
public:
    SimpleLogger();
    LoggerPtr logger();
    
    // work with Test Engine:
    void startWorkWithTestEngine(const char *path);
    void startLoadTe();
    void startGetExt();
    void startUnloadTe();
    
    // work with Test Container:
    void startWorkWithTestContainer(const char *path);
    void startLoadTc();
    void startUnloadTc();
    
    // work with Unit Test:
    void startWorkWithTest(TestPtr);
    void startSetUp();
    void startTest();
    void startTearDown();

    void success();
    void failure(const char *message);
    void error(const char *message);
    
private:
    static const char* stepName(const int step);
    static void destroy(void*);
    
private:
    Logger logger_;
    TestPtr currentTest_;
    int step_;
};
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// LUA_CLASS(Logger)
// {
// };
// 
// DEFINE_LUA_TO(Logger)

#endif // _TEST_ENGINE_HEADER_
