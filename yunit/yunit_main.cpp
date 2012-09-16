#include "test_unit_engine.h"
#include "test_engine.h"
#include "lua_wrapper.h"

#ifdef _WIN32
#  include <io.h>
#  define ACCESS_FUNC _access
#else
#  include <unistd.h> 
#  define ACCESS_FUNC access
#endif

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <list>


#ifdef WIN32
#  define ENDL "\r\n"
#else
#  define ENDL "\n"
#endif

#define stepSetUp 1
#define stepTest 2
#define stepTearDown 3

//struct _TestLogger
//{
//    Test *currentTest_;
//    int step_;
//};
//typedef struct _TestLogger TestLogger;
//
//static const char* stepName(const int step)
//{
//    switch (step)
//    {
//    case stepSetUp:
//        return "setUp";
//    case stepTest:
//        return "test";
//    case stepTearDown:
//        return "tearDown";
//    default:
//        abort(); /* unknown step type */
//    }
//}
//
//static void success(TestLogger *logger)
//{
//    TestPtr test = logger->currentTest_;
//    printf("%s::%s is Ok" ENDL, (*test->name_)(test->self_), stepName(logger->step_));
//}
//
//static void testLoggerSuccess(void *self)
//{
//    success((TestLogger*)self);
//}
//
//static void fail(TestLogger *logger, const char *message)
//{
//    TestPtr test = logger->currentTest_;
//    printf("%s::%s is Fail" ENDL, (*test->name_)(test->self_), stepName(logger->step_));
//}
//
//static void testLoggerFail(void *self, const char *message)
//{
//    fail((TestLogger*)self, message);
//}

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
int main(int argc, char **argv)
{
    using namespace Lua;
    
    Lua::StateLiveGuard lua;
    
    const char *testEnginePathTableNameInLua = "testEnginePaths";
    lua.push(Table());
    const int testEnginePathTableIdx = lua.top();
    int testEnginePathIdx = 0;

    const char *testContainerPathTableNameInLua = "testContainerPaths";
    lua.push(Table());
    const int testContainerPathTableIdx = lua.top();
    int testContainerPathIdx = 0;
    
    const char* mainScript;
    
    for (int argIdx = 1/* skip program path */; argIdx < argc; ++argIdx)
    {
        /// @todo It is needed to use customized argument parser instead of many ::strcmp calls for more performance
        if (0 == ::strcmp("--test-unit-engine", argv[argIdx])
           || 0 == ::strcmp("-e", argv[argIdx]))
        {
            /// @todo Add checking that path is really file path
            lua.push(argv[++argIdx]);
            lua.push(++testEnginePathIdx);
            lua.settable(testEnginePathTableIdx);
        }
        else if (0 == ::strcmp("--test-container", argv[argIdx])
                || 0 == ::strcmp("-t", argv[argIdx]))
        {
            /// @todo Add checking that path is really file path
            lua.push(argv[++argIdx]);
            lua.push(++testContainerPathIdx);
            lua.settable(testContainerPathTableIdx);
        }
        else
            mainScript = argv[argIdx];
    }
    
    enum ReturnStatus
    {
        ST_SUCCESS = 0,
        ST_ERROR = -1,
        ST_NO_ANY_TUE = -2,
        ST_NO_ANY_TEST_CONTAINER = -3,
        ST_MAIN_SCRIPT_FAIL = -4
    };
    
    if (0 == testEnginePathIdx)
    {
        perror("No one test unit engine set" ENDL);
        return ST_NO_ANY_TUE;
    }
    
    lua.push(Value(testEnginePathTableIdx));
    lua.setglobal(testEnginePathTableNameInLua);
    
    if (0 == testContainerPathIdx)
    {
        perror("No one test container set" ENDL);
        return ST_NO_ANY_TEST_CONTAINER;
    }

    lua.push(Value(testContainerPathTableIdx));
    lua.setglobal(testContainerPathTableNameInLua);
    
    lua.openlibs();
    
    LUA_REGISTER(TestEngine)(lua);
//    LUA_REGISTER(UnitTest)(lua);

    int rc = lua.dofile(mainScript);
    if (0 != rc)
    {
        perror(lua.to<const char*>());
        return ST_MAIN_SCRIPT_FAIL;
    }
    
    return ST_SUCCESS;
}
    
//#if defined(_WIN32)
//#else
//    void *hTue = dlopen(testEnginePath_.front(), RTLD_NOW | RTLD_GLOBAL);
//    if (NULL == hTue)
//        return 1;
//    //
//    // ask about supported extensions    
//    {
//        //dlerror(); /// @todo use it for error detection
//        void *funcPtr = dlsym(hTue, "testContainerExtensions");
//        if (NULL == funcPtr)
//            return 1;
//        
//        typedef const char** (*TestContainerExtensions)();
//        
//        TestContainerExtensions testContainerExtensions = (TestContainerExtensions)funcPtr;
//        
//        printf("extension is \"%s\"" ENDL, testContainerExtensions()[0]);
//    }
//    //
//    // run test
//    {
//        void *funcPtr = dlsym(hTue, "loadTestContainer");
//        if (NULL == funcPtr)
//            return 1;
//            
//        typedef Test* (*LoadTestContainer)(const char*);
//        LoadTestContainer loadTestContainer = (LoadTestContainer)funcPtr;
//
//        TestLogger testLogger;
//
//        Logger logger;
//        memset(&logger, 0, sizeof(logger));
//        logger.self_ = &testLogger;
//        logger.success_ = &testLoggerSuccess;
//        logger.failure_ = &testLoggerFail;
//
//        TestPtr test = loadTestContainer("");
//        for (; test; test = test->next_)
//        {
//            testLogger.currentTest_ = test;
//           
//            testLogger.step_ = stepSetUp;
//            (*test->setUp_)(test, &logger);
//            
//            testLogger.step_ = stepTest;
//            (*test->test_)(test, &logger);
//            
//            testLogger.step_ = stepTearDown;
//            (*test->tearDown_)(test, &logger);
//        }
//    }
//    
//    dlclose(hTue);
//    
//#endif // WIN32
