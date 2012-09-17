//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// @file test_engine.h
// 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef _TEST_ENGINE_HEADER_
#define _TEST_ENGINE_HEADER_

#include "lua_wrapper.h"
#include "test_engine_interface.h"

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
    
};

#endif // _TEST_ENGINE_HEADER_