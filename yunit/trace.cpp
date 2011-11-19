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
static void pushfuncname (lua_State *L, lua_Debug *ar);

#define LEVELS1	12	/* size of the first part of the stack */
#define LEVELS2	10	/* size of the second part of the stack */


LUA_METHOD(Trace, traceback)
{
    LuaState lua(L); /// @todo Add 'LuaState lua(L)' in macro as function argument
    
    int arg;
    lua_State *L1 = getthread(L, &arg);
    int level = luaL_optint(L, arg + 2, (L == L1) ? 1 : 0);
    int numlevels = countlevels(L1);
    int mark = (numlevels > LEVELS1 + LEVELS2) ? LEVELS1 : 0;

    const char *msg;
    lua.to(arg + 1, &msg);

    lua.newtable(); // return value
    int retValIdx = lua.gettop();
    
    lua.push(msg);
    lua.setfield(retValIdx, "message");

    lua_Debug debInfo;

    lua.newtable(); // step table
    int stepsIdx = lua.gettop();
    
    unsigned int cStep = 0;
    
    while (lua_getstack(L1, level++, &debInfo))
    {
        if (level == mark)
        {  // too many levels?
            level = numlevels - LEVELS2;  // and skip to last ones
        }
        else
        {
            lua_getinfo(L1, "Slnt", &debInfo);

            lua.newtable();
            int stepIdx = lua.gettop();
            
            if (debInfo.namewhat != '\0')
            {
                pushfuncname(L, &debInfo);
                lua.setfield(stepIdx, "funcname");
            }

            lua.push(debInfo.source);
            lua.setfield(stepIdx, "source");

            lua.push(debInfo.currentline);
            lua.setfield(stepIdx, "line");

            lua.rawseti(stepsIdx, ++cStep);
        }
    }
    
    lua.setfield(retValIdx, "step");
  
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

/*
** search for 'objidx' in table at index -1.
** return 1 + string at top if find a good name.
*/
static int findfield (lua_State *L, int objidx, int level) {
  int found = 0;
  if (level == 0 || !lua_istable(L, -1))
    return 0;  /* not found */
  lua_pushnil(L);  /* start 'next' loop */
  while (!found && lua_next(L, -2)) {  /* for each pair in table */
    if (lua_type(L, -2) == LUA_TSTRING) {  /* ignore non-string keys */
      if (lua_rawequal(L, objidx, -1)) {  /* found object? */
        lua_pop(L, 1);  /* remove value (but keep name) */
        return 1;
      }
      else if (findfield(L, objidx, level - 1)) {  /* try recursively */
        lua_remove(L, -2);  /* remove table (but keep name) */
        lua_pushliteral(L, ".");
        lua_insert(L, -2);  /* place '.' between the two names */
        lua_concat(L, 3);
        return 1;
      }
    }
    lua_pop(L, 1);  /* remove value */
  }
  return 0;  /* not found */
}


static int pushglobalfuncname (lua_State *L, lua_Debug *ar) {
  int top = lua_gettop(L);
  lua_getinfo(L, "f", ar);  /* push function */
  lua_pushglobaltable(L);
  if (findfield(L, top + 1, 2)) {
    lua_copy(L, -1, top + 1);  /* move name to proper place */
    lua_pop(L, 2);  /* remove pushed values */
    return 1;
  }
  else {
    lua_settop(L, top);  /* remove function and global table */
    return 0;
  }
}


static void pushfuncname (lua_State *L, lua_Debug *ar)
{
  if (*ar->namewhat != '\0')  /* is there a name? */
    lua_pushfstring(L, "function " LUA_QS, ar->name);
  else if (*ar->what == 'm')  /* main? */
      lua_pushfstring(L, "main chunk");
  else if (*ar->what == 'C' || *ar->what == 't') {
    if (pushglobalfuncname(L, ar)) {
      lua_pushfstring(L, "function " LUA_QS, lua_tostring(L, -1));
      lua_remove(L, -2);  /* remove name */
    }
    else
      lua_pushliteral(L, "?");
  }
  else
    lua_pushfstring(L, "function <%s:%d>", ar->short_src, ar->linedefined);
}

