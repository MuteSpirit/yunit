//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// lua_wrapper.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define YUNIT_DLL_EXPORTS
#include "lua_wrapper.h"
#include <cassert>
#include <limits>

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
namespace Lua {

State::State(lua_State* L)
: l_(L)
{
}

void State::settable(int idx)
{
    lua_settable(l_, idx);
}

void State::setfield(int idx, const char* key)
{
    lua_setfield(l_, idx, key);
}

void State::push(double v)
{
    lua_pushnumber(l_, v);
}

void State::push(int v)
{
    lua_pushinteger(l_, v);
}

void State::push(long v)
{
    lua_pushinteger(l_, v);
}

void State::push(unsigned v)
{
#if LUA_VERSION_NUM == 501
    lua_pushinteger(l_, v);
#elif LUA_VERSION_NUM == 502
    lua_pushunsigned(l_, v);
#else
#  error Unsupported Lua version
#endif
}

void State::push(unsigned long v)
{
#if LUA_VERSION_NUM == 501
    lua_pushinteger(l_, v);
#elif LUA_VERSION_NUM == 502
    lua_pushunsigned(l_, v);
#else
#  error Unsupported Lua version
#endif
}

void State::push(bool v)
{
    lua_pushboolean(l_, v ? 1 : 0);
}

void State::push(const char* s)
{
    lua_pushstring(l_, s);
}

void State::push(const char* s, size_t len)
{
    lua_pushlstring(l_, s, len);
}

void State::pushf(const char* fmt, ...)
{
    va_list argp;
    va_start(argp, fmt);
    luaL_where(l_, 1);
    lua_pushvfstring(l_, fmt, argp);
    va_end(argp);
    lua_concat(l_, 2);
}

void State::push(lua_CFunction func)
{
    lua_pushcfunction(l_, func);
}

void State::push(void *ptr)
{
    lua_pushlightuserdata(l_, ptr);
}

void State::push(Value v)
{
    lua_pushvalue(l_, v.idx_);
}

void State::push(_Nil)
{
    lua_pushnil(l_);
}

void State::push(Table t)
{
    lua_createtable(l_, t.narr_, t.nrec_);
}

void State::pushglobaltable()
{
#if LUA_VERSION_NUM == 501
    lua_pushvalue(l_, LUA_GLOBALSINDEX);
#elif LUA_VERSION_NUM == 502
    lua_pushglobaltable(l_);
#else
#  error Unsupported Lua version
#endif
}

void State::pop(unsigned int n)
{
    lua_pop(l_, static_cast<int>(n)); // lua require signed int type of 'n'
}

void State::rawseti(int idx, int n)
{
    lua_rawseti(l_, idx, n);
}

const char* State::typeName(int idx)
{
    return lua_typename(l_, lua_type(l_, idx));
}
    
bool State::isstring(int idx)
{
    return 1 == lua_isstring(l_, idx);
}

bool State::istable(int idx)
{
    return 1 == lua_istable(l_, idx);
}

bool State::isuserdata(int idx)
{
    return 1 == lua_isuserdata(l_, idx);
}

bool State::isinteger(int idx)
{
    return 1 == lua_isnumber(l_, idx);
}

bool State::isnumber(int idx)
{
    return 1 == lua_isnumber(l_, idx);
}

bool State::isnil(int idx)
{
    return 1 == lua_isnil(l_, idx);
}

void State::getglobal(const char* name)
{
    lua_getglobal(l_, name);
}

void State::setglobal(const char* name)
{
    lua_setglobal(l_, name);
}

void State::getfield(int idx, const char* key)
{
    lua_getfield(l_, idx, key);
}

int State::top()
{
    return lua_gettop(l_);
}

void State::top(int idx)
{
    lua_settop(l_, idx);
}

void State::to(int idx, const char** str, size_t* len)
{
    *str = lua_tolstring(l_, idx, len);
}

const char* State::to(int idx, size_t* len)
{
    return lua_tolstring(l_, idx, len);
}

void State::to(int idx, const char** str)
{
    *str = lua_tostring(l_, idx);
}

void State::remove(int idx)
{
    lua_remove(l_, idx);
}

void State::getinfo(const char *what, lua_Debug *ar)
{
    lua_getinfo(l_, what, ar);
}


void State::insert(int idx)
{
    lua_insert(l_, idx);
}

int State::error(const char* fmt, ...)
{
    va_list argp;
    va_start(argp, fmt);
    luaL_where(l_, 1);
    lua_pushvfstring(l_, fmt, argp);
    va_end(argp);
    lua_concat(l_, 2);
    return lua_error(l_);
}

int State::dostring(const char *luaCode)
{
    int rc = luaL_loadstring(l_, luaCode);
    if (0 == rc)
        rc = call();

    return rc;
}

int State::dostring(String luaCode)
{
    int rc = luaL_loadbuffer(l_, luaCode.s_, luaCode.size_, luaCode.s_);
    if (0 == rc)
        rc = call();

    return rc;
}

static int db_errorfb(lua_State *L);

int State::call(unsigned int numberOfArgs, int numberOfReturnValues)
{
    // stack has such content on function call moment: ..., function, arg1, ..., argN
    
    assert(numberOfArgs <= std::numeric_limits<int>::max());
    int numOfArgs = static_cast<int>(numberOfArgs);

    assert(top() >= numOfArgs + 1);
    //
    // locating error handle function before calling function value
    push(db_errorfb);
    insert(top() - numOfArgs + 1);

    const int errHandleFuncIdx = top() - numOfArgs + 1;
    int rc = lua_pcall(l_, numOfArgs, numberOfReturnValues, errHandleFuncIdx);

    remove(errHandleFuncIdx);
    return rc;
}

// source code of db_errorfb and dependent function is copies from Lua 5.2 sources

#define LEVELS1	12	/* size of the first part of the stack */
#define LEVELS2	10	/* size of the second part of the stack */
static lua_State *getthread (lua_State *L, int *arg);

static int db_errorfb (lua_State *L) {
  int level;
  int firstpart = 1;  /* still before eventual `...' */
  int arg;
  lua_State *L1 = getthread(L, &arg);
  lua_Debug ar;
  if (lua_isnumber(L, arg+2)) {
    level = (int)lua_tointeger(L, arg+2);
    lua_pop(L, 1);
  }
  else
    level = (L == L1) ? 1 : 0;  /* level 0 may be this own function */
  if (lua_gettop(L) == arg)
    lua_pushliteral(L, "");
  else if (!lua_isstring(L, arg+1)) return 1;  /* message is not a string */
  else lua_pushliteral(L, "\n");
  lua_pushliteral(L, "stack traceback:");
  while (lua_getstack(L1, level++, &ar)) {
    if (level > LEVELS1 && firstpart) {
      /* no more than `LEVELS2' more levels? */
      if (!lua_getstack(L1, level+LEVELS2, &ar))
        level--;  /* keep going */
      else {
        lua_pushliteral(L, "\n\t...");  /* too many levels */
        while (lua_getstack(L1, level+LEVELS2, &ar))  /* find last levels */
          level++;
      }
      firstpart = 0;
      continue;
    }
    lua_pushliteral(L, "\n\t");
    lua_getinfo(L1, "Snl", &ar);
    lua_pushfstring(L, "%s:", ar.short_src);
    if (ar.currentline > 0)
      lua_pushfstring(L, "%d:", ar.currentline);
    if (*ar.namewhat != '\0')  /* is there a name? */
        lua_pushfstring(L, " in function " LUA_QS, ar.name);
    else {
      if (*ar.what == 'm')  /* main? */
        lua_pushfstring(L, " in main chunk");
      else if (*ar.what == 'C' || *ar.what == 't')
        lua_pushliteral(L, " ?");  /* C function or tail call */
      else
        lua_pushfstring(L, " in function <%s:%d>",
                           ar.short_src, ar.linedefined);
    }
    lua_concat(L, lua_gettop(L) - arg);
  }
  lua_concat(L, lua_gettop(L) - arg);
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
StateGuard::StateGuard()
: Parent(luaL_newstate())
{
}

StateGuard::~StateGuard()
{
    close();
}

void StateGuard::close()
{
    if (nullptr != l_)
    {
        lua_close(l_);
        l_ = nullptr;
    }
}

} // namespace Lua