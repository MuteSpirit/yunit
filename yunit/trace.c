//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// trace.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifdef __cplusplus
extern "C" {
#endif
#include <lua/lua.h>
#ifdef __cplusplus
}
#endif

#ifdef _WIN32
#  include <windows.h>
#else
#  include <syslog.h>
#endif

#ifndef TRACE_API
#	if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#		define TRACE_API __declspec(dllexport)
#	elif defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
#		define TRACE_API __attribute__ ((visibility("default")))
#	else
#		define TRACE_API
#	endif
#endif

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
int ltrace(lua_State* L)
{
    const int msgArgInd = -1;
    if (lua_isstring(L, msgArgInd))
    {
        const char* msg = lua_tostring(L, msgArgInd);
        lua_pop(L, 1);
#ifdef WIN32
        OutputDebugStringA(msg);
#else
        syslog(LOG_USER, "%s", msg); 
#endif
    }
    return 0;
}

#ifdef __cplusplus
extern "C"
#endif
int TRACE_API luaopen_trace(lua_State *L)
{
	lua_register(L, "trace", ltrace);
	return 0;
}
