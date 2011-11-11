//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// trace.c
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#include <lua.h>

#define YUNIT_DLL_EXPORTS
#include "yunit.h"

#ifdef _WIN32
#  include <windows.h>
#else
#  include <syslog.h>
#endif

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
int ltrace(lua_State* L)
{
    const int msgArgInd = -1;
    if (lua_isstring(L, msgArgInd))
    {
        const char* msg = lua_tostring(L, msgArgInd);
#if defined(_WIN32)
        OutputDebugStringA(msg);
#else
        syslog(LOG_USER, "%s", msg); 
#endif
        lua_pop(L, 1); // remove msg from stack after using
    }
    return 0;
}

#ifdef __cplusplus
extern "C"
#endif
int YUNIT_API luaopen_yunit_trace(lua_State *L)
{
	lua_register(L, "trace", ltrace);
	return 0;
}
