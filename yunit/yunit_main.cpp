#include "test_unit_engine.h"
#include "lua_wrapper.h"

#include <dlfcn.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifdef WIN32
#  define ENDLINE "\r\n"
#else
#  define ENDLINE "\n"
#endif

#define stepSetUp 1
#define stepTest 2
#define stepTearDown 3

struct _TestLogger
{
    Test *currentTest_;
    int step_;
};
typedef struct _TestLogger TestLogger;

static const char* stepName(const int step)
{
    switch (step)
    {
    case stepSetUp:
        return "setUp";
    case stepTest:
        return "test";
    case stepTearDown:
        return "tearDown";
    default:
        abort(); /* unknown step type */
    }
}

static void success(TestLogger *logger)
{
    TestPtr test = logger->currentTest_;
    printf("%s::%s is Ok" ENDLINE, (*test->name_)(test->self_), stepName(logger->step_));
}

static void testLoggerSuccess(void *self)
{
    success((TestLogger*)self);
}

static void fail(TestLogger *logger, const char *message)
{
    TestPtr test = logger->currentTest_;
    printf("%s::%s is Fail" ENDLINE, (*test->name_)(test->self_), stepName(logger->step_));
}

static void testLoggerFail(void *self, const char *message)
{
    fail((TestLogger*)self, message);
}

int main(int argc, char **argv)
{
#if defined(_WIN32)
#else
    void *hTue = dlopen(argv[1], RTLD_NOW | RTLD_GLOBAL);
    if (NULL == hTue)
        return 1;
    //
    // ask about supported extensions    
    {
        //dlerror(); /// @todo use it for error detection
        void *funcPtr = dlsym(hTue, "testContainerExtensions");
        if (NULL == funcPtr)
            return 1;
        
        typedef const char** (*TestContainerExtensions)();
        
        TestContainerExtensions testContainerExtensions = (TestContainerExtensions)funcPtr;
        
        printf("extension is \"%s\"" ENDLINE, testContainerExtensions()[0]);
    }
    //
    // run test
    {
        void *funcPtr = dlsym(hTue, "loadTestContainer");
        if (NULL == funcPtr)
            return 1;
            
        typedef Test* (*LoadTestContainer)(const char*);
        LoadTestContainer loadTestContainer = (LoadTestContainer)funcPtr;

        TestLogger testLogger;

        Logger logger;
        memset(&logger, 0, sizeof(logger));
        logger.self_ = &testLogger;
        logger.success_ = &testLoggerSuccess;
        logger.failure_ = &testLoggerFail;

        TestPtr test = loadTestContainer("");
        for (; test; test = test->next_)
        {
            testLogger.currentTest_ = test;
           
            testLogger.step_ = stepSetUp;
            (*test->setUp_)(test, &logger);
            
            testLogger.step_ = stepTest;
            (*test->test_)(test, &logger);
            
            testLogger.step_ = stepTearDown;
            (*test->tearDown_)(test, &logger);
        }
    }
    
    dlclose(hTue);
    
#endif // WIN32

    return 0;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
LUA_CLASS(TestUnitEngine)
{
    /// @param path Path to dynamic link library file with Test Unit Engine feature and some C API functions:
    /// TUE_API const char** testContainerExtensions();
    /// TUE_API Test* loadTestContainer(const char *path);
    ADD_CONSTRUCTOR(TestUnitEngine);

    /// @param path Path to possible test container file
    /// @return true if this file is supported and this TUE may load tests from it
    ADD_METHOD(TestUnitEngine, supportFile);
    
    /// @param path Path to supported test container file
    /// @return array with unit tests, contained by test container file
    ADD_METHOD(TestUnitEngine, loadFile);
    
    /// @param array with unit tests, returned from 'loadFile' method call
    /// @brief Free memory allocated for unit test objects, so you must NOT even try to use that test objects
    ADD_METHOD(TestUnitEngine, freeTests);
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
LUA_CLASS(UnitTest)
{
    ADD_METHOD(UnitTest, name);
    
    /// @return String with path to source file, containing test definition
    ADD_METHOD(UnitTest, source);
    
    /// @return Test definition first line number
    ADD_METHOD(UnitTest, line);
    
    /// @return true, if test must be ignored and not executed
    ADD_METHOD(UnitTest, isIgnored);

    ADD_METHOD(UnitTest, setUp);
    ADD_METHOD(UnitTest, test);
    ADD_METHOD(UnitTest, tearDown);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

