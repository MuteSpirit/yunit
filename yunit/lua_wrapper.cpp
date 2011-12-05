//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// lua_wrapper.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#include "lua_wrapper.h"


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
LuaState::LuaState(lua_State* L)
: l_(L)
{
}

LuaState::operator lua_State*()
{
    return l_;
}

void LuaState::newtable()
{
    lua_newtable(l_);
}

void LuaState::settable(int idx)
{
    lua_settable(l_, idx);
}

void LuaState::setfield(int idx, const char* key)
{
    lua_setfield(l_, idx, key);
}

void LuaState::push(lua_Number value)
{
    lua_pushnumber(l_, value);
}

void LuaState::push(lua_Integer value)
{
    lua_pushinteger(l_, value);
}

void LuaState::push(bool value)
{
    lua_pushboolean(l_, value ? 1 : 0);
}

void LuaState::push(const char* s)
{
    lua_pushstring(l_, s);
}

void LuaState::push(const char* s, size_t len)
{
    lua_pushlstring(l_, s, len);
}

void LuaState::pushvalue(int idx)
{
    lua_pushvalue(l_, idx);
}

void LuaState::pushnil()
{
    lua_pushnil(l_);
}

void LuaState::pushglobaltable()
{
    lua_pushvalue(l_, LUA_GLOBALSINDEX);
}

void LuaState::pop(int n)
{
    lua_pop(l_, n);
}

void LuaState::rawseti(int idx, int n)
{
    lua_rawseti(l_, idx, n);
}

const char* LuaState::typeName(int idx)
{
    return lua_typename(l_, lua_type(l_, idx));
}
    
bool LuaState::isstring(int idx)
{
    return 1 == lua_isstring(l_, idx);
}

bool LuaState::istable(int idx)
{
    return 1 == lua_istable(l_, idx);
}

bool LuaState::isuserdata(int idx)
{
    return 1 == lua_isuserdata(l_, idx);
}

bool LuaState::isinteger(int idx)
{
    return 1 == lua_isnumber(l_, idx);
}

bool LuaState::isnumber(int idx)
{
    return 1 == lua_isnumber(l_, idx);
}

bool LuaState::isnil(int idx)
{
    return 1 == lua_isnil(l_, idx);
}

void LuaState::getglobal(const char* name)
{
    lua_getglobal(l_, name);
}

void LuaState::getfield(int idx, const char* key)
{
    lua_getfield(l_, idx, key);
}

int LuaState::gettop()
{
    return lua_gettop(l_);
}

void LuaState::settop(int idx)
{
    lua_settop(l_, idx);
}

void LuaState::to(int idx, const char** str, size_t* len)
{
    *str = lua_tolstring(l_, idx, len);
}

const char* LuaState::to(int idx, size_t* len)
{
    return lua_tolstring(l_, idx, len);
}

void LuaState::to(int idx, const char** str)
{
    *str = lua_tostring(l_, idx);
}

void LuaState::remove(int idx)
{
    lua_remove(l_, idx);
}

void LuaState::getinfo(const char *what, lua_Debug *ar)
{
    lua_getinfo(l_, what, ar);
}

