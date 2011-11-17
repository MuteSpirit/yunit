//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// trace.c
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define YUNIT_DLL_EXPORTS
#include "yunit.h"
#include "lua_wrapper.h"

#ifdef _WIN32
#  include <windows.h>
#else
#  include <syslog.h>
#endif

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct Trace {};

extern "C"
int YUNIT_API luaopen_yunit_trace(lua_State *L)
{
    luaWrapper<Trace>().regLib(L, "yunit.trace");
	return 1;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
LUA_METHOD(Trace, trace)
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
static lua_State *getthread (lua_State *L, int *arg);
static int countlevels (lua_State *L);
static void luaL_traceback_ex (lua_State *L, lua_State *L1, const char *msg, int level);

LUA_METHOD(Trace, traceback)
{
    return 0;
}

int ltr(lua_State* L)
{
  int arg;
  lua_State *L1 = getthread(L, &arg);
  const char *msg = lua_tostring(L, arg + 1);
  if (msg == NULL && !lua_isnoneornil(L, arg + 1))  /* non-string 'msg'? */
    lua_pushvalue(L, arg + 1);  /* return it untouched */
  else {
    int level = luaL_optint(L, arg + 2, (L == L1) ? 1 : 0);
    luaL_traceback_ex(L, L1, msg, level);
  }
  return 1;
}

static lua_State *getthread (lua_State *L, int *arg) {
  if (lua_isthread(L, 1)) {
    *arg = 1;
    return lua_tothread(L, 1);
  }
  else {
    *arg = 0;
    return L;
  }
}

#define LEVELS1	12	/* size of the first part of the stack */
#define LEVELS2	10	/* size of the second part of the stack */

static void luaL_traceback_ex (lua_State *L, lua_State *L1,
                     const char *msg, int level)
{
    int top = lua_gettop(L);
    int numlevels = countlevels(L1);
    int mark = (numlevels > LEVELS1 + LEVELS2) ? LEVELS1 : 0;

    lua_pushstring(L, msg);
 
    int i = 0;
    lua_newtable(L); int retTableIdx = lua_gettop(L);
    
    lua_Debug debInfo;
    
    while (lua_getstack(L1, level, &debInfo))
    {
        if (level == mark)
        {  /* too many levels? */
            level = numlevels - LEVELS2;  /* and skip to last ones */
        }
        else
        {
            lua_getinfo(L1, "Slnt", &debInfo);
            lua_Debug* ar = (lua_Debug *)lua_newuserdata(L, sizeof(lua_Debug));
            *ar = debInfo;
            lua_rawseti(L, -2, ++i);
        }
    }
}

static int countlevels (lua_State *L)
{
  lua_Debug ar;
  int li = 1, le = 1;
  /* find an upper bound */
  while (lua_getstack(L, le, &ar)) { li = le; le *= 2; }
  /* do a binary search */
  while (li < le)
  {
    int m = (li + le)/2;
    if (lua_getstack(L, m, &ar)) li = m + 1;
    else le = m;
  }
  return le - 1;
}
