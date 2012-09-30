#include "test_engine_interface.h"
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
    
    const char* mainScript = NULL;
    
    for (int argIdx = 1/* skip program path */; argIdx < argc; ++argIdx)
    {
        /// @todo It is needed to use customized argument parser instead of many ::strcmp calls for more performance
        if (0 == ::strcmp("--test-unit-engine", argv[argIdx])
           || 0 == ::strcmp("-e", argv[argIdx]))
        {
            /// @todo Add checking that path is really file path
            lua.push(++testEnginePathIdx);
            lua.push(argv[++argIdx]);
            lua.settable(testEnginePathTableIdx);
        }
        else if (0 == ::strcmp("--test-container", argv[argIdx])
                || 0 == ::strcmp("-t", argv[argIdx]))
        {
            /// @todo Add checking that path is really file path
            lua.push(++testContainerPathIdx);
            lua.push(argv[++argIdx]);
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
        ST_MAIN_SCRIPT_FAIL = -4,
        ST_NO_SET_MAIN_SCRIPT = -5
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
    
    if (NULL == mainScript)
    {
        perror("Not set Lua script for execution");
        return ST_NO_SET_MAIN_SCRIPT;
    }
    
    lua.openlibs();
    
    LUA_REGISTER(TestEngine)(lua);
    LUA_REGISTER(UnitTest)(lua);
    
    int rc = lua.dofile(mainScript);
    if (0 != rc)
    {
        perror(lua.to<const char*>());
        return ST_MAIN_SCRIPT_FAIL;
    }
    
    return ST_SUCCESS;
}
