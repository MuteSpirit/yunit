#include "test_unit_engine.h"
#include <dlfcn.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifdef WIN32
#  define ENDLINE "\r\n"
#else
#  define ENDLINE "\r\n"
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

static void success(TestLogger* logger)
{
    TestPtr test = logger->currentTest_;
    printf("%s::%s is Ok" ENDLINE, (*test->name_)(test->self_), stepName(logger->step_));
}

void testLoggerSuccess(void *self)
{
    success((TestLogger*)self);
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
            
        typedef Test** (*LoadTestContainer)(const char*);
        LoadTestContainer loadTestContainer = (LoadTestContainer)funcPtr;

        TestLogger testLogger;

        Logger logger;
        memset(&logger, 0, sizeof(logger));
        logger.self_ = &testLogger;
        logger.success_ = testLoggerSuccess;

        TestPtr *tests = loadTestContainer("");
        TestPtr test;
        
        for (; *tests; ++tests)
        {
            test = *tests;
            
            testLogger.currentTest_ = test;
           
            testLogger.step_ = stepSetUp;
            (*test->setUp_)(test, &logger);
            
            testLogger.step_ = stepTest;
            (*test->test_)(test, &logger);
            
            testLogger.step_ = stepTearDown;
            (*test->test_)(test, &logger);
        }
    }
    
    dlclose(hTue);
    
#endif // WIN32

    return 0;
}
