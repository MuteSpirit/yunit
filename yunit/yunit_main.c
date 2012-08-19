#include "test_unit_engine.h"
#include <dlfcn.h>
#include <stdio.h>
#include <string.h>

#ifdef WIN32
#  define ENDLINE "\r\n"
#else
#  define ENDLINE "\r\n"
#endif

void logSuccess(void *self, Test *test)
{
    printf("test is Ok" ENDLINE);
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

        TestPtr test = loadTestContainer("")[0];

        Logger logger;
        memset(&logger, 0, sizeof(logger));
        logger.success_ = logSuccess;
       
        (*test->setUp_)(test, &logger);
        (*test->test_)(test, &logger);
    }
    dlclose(hTue);
    
#endif // WIN32

    return 0;
}
