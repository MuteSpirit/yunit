//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// @file test_engine.h
// 
/// @todo Rename UnitTest -> TestCase
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef _TEST_ENGINE_HEADER_
#define _TEST_ENGINE_HEADER_

#include "lua_wrapper.h"
#include "test_engine_interface.h"

#ifdef _WIN32
#  define ENDL "\r\n"
#else
#  define ENDL "\n"
#endif

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class DinamicLinkLibrary
{
public:
    virtual void* load(const char *path) = 0;
    virtual void* resolve(const char *functionName) = 0;
    virtual const char* error() const = 0;
    virtual void unload() = 0;
}; 

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class TestEngine
{
public:
    virtual bool initialize() = 0;
    virtual const char *error() const = 0;
    virtual const char** supportedExtensions() = 0;
    virtual TestPtr load(const char* testContainerPath) = 0;
    virtual ~TestEngine() {}
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class TestEngineFactory
{
public:
    static TestEngine *create(const char *filePath);
    static void destroy(TestEngine*);
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
LUA_CLASS(TestEngine)
{
    /// @param path Path to dynamic link library file with Test Engine feature and some C API functions:
    /// TUE_API const char** testContainerExtensions();
    /// TUE_API Test* loadTestContainer(const char *path);
    /// @return object or nil and error message
    ADD_CONSTRUCTOR(TestEngine);

    /// @return Table with supported test container file extensions
    ADD_METHOD(TestEngine, supportedExtensions);

    /// @fn load(testContainerPath)
    ADD_METHOD(TestEngine, load);
            
    /// @param path Path to possible test container file
    /// @return true if this file is supported and this TUE may initialize tests from it
    //ADD_METHOD(TestEngine, supportFile);
    
    /// @param path Path to supported test container file
    /// @return array with unit tests, contained by test container file
    //ADD_METHOD(TestEngine, loadFile);
    
    /// @param array with unit tests, returned from 'loadFile' method call
    /// @brief Free memory allocated for unit test objects, so you must NOT even try to use that test objects
    //ADD_METHOD(TestEngine, freeTests);
};

DEFINE_LUA_TO(TestEngine)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
LUA_CLASS(UnitTest)
{
    ADD_METHOD(UnitTest, start);
    
    ADD_METHOD(UnitTest, setUp);
    ADD_METHOD(UnitTest, test);
    ADD_METHOD(UnitTest, tearDown);

    ADD_METHOD(UnitTest, isIgnored);
    
    ADD_METHOD(UnitTest, name);
    ADD_METHOD(UnitTest, source);
    ADD_METHOD(UnitTest, line);
};

DEFINE_LUA_TO(Test)

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
LUA_CLASS(Logger)
{
};

DEFINE_LUA_TO(Logger)

#endif // _TEST_ENGINE_HEADER_