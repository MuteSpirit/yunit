//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// lua_wrapper.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#include "lua_wrapper.h"


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
namespace Lua {

State::State(lua_State* L)
: l_(L)
{
}

State::operator lua_State*()
{
    return l_;
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
    lua_pop(l_, n);
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

} // namespace Lua