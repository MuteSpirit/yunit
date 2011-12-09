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
#if LUA_VERSION_NUM == 501
    lua_pushvalue(l_, LUA_GLOBALSINDEX);
#elif LUA_VERSION_NUM == 502
    lua_pushglobaltable(l_);
#else
#  error Unsupported Lua version
#endif
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

namespace Lua {

State::State(lua_State* L)
: l_(L)
{
}

State::operator lua_State*()
{
    return l_;
}

void State::close()
{
    lua_close(l_);
}

void State::push(int v)
{
    lua_pushinteger(l_, v);
}

void State::push(long v)
{
    lua_pushinteger(l_, v);
}

void State::push(unsigned int v)
{
    lua_pushunsigned(l_, v);
}

void State::push(unsigned long v)
{
    lua_pushunsigned(l_, v);
}

void State::push(double v)
{
    lua_pushnumber(l_, v);
}

void State::push(bool v)
{
    lua_pushboolean(l_, v ? 1 : 0);
}

void State::push(const char* s)
{
    lua_pushstring(l_, s);
}

void State::push(const std::string& s)
{
    lua_pushlstring(l_, s.c_str(), s.size());
}

void State::push(_Nil)
{
    lua_pushnil(l_);
}

void State::push(_Value, int idx)
{
    lua_pushvalue(l_, idx);
}

void State::push(_Globaltable)
{
    lua_pushglobaltable(l_);
}

void State::push(lua_CFunction fn, int numOfUpvalues)
{
    lua_pushcclosure(l_, fn, numOfUpvalues);
}

void State::push(void* lightuserdata)
{
    lua_pushlightuserdata(l_, lightuserdata);
}

void State::pop(int n)
{
    lua_pop(l_, n);
}

void State::remove(int idx)
{
    lua_remove(l_, idx);
}

template<> 
int State::to<int>(int idx)
{
    return lua_tointeger(l_, idx);
}

template<> 
unsigned int State::to<unsigned int>(int idx)
{
    return lua_tounsigned(l_, idx);
}

template<> 
long State::to<long>(int idx)
{
    return lua_tointeger(l_, idx);
}

template<> 
unsigned long State::to<unsigned long>(int idx)
{
    return lua_tounsigned(l_, idx);
}

template<> 
double State::to<double>(int idx)
{
    return lua_tonumber(l_, idx);
}

template<> 
bool State::to<bool>(int idx)
{
    return lua_toboolean(l_, idx) == 1 ? true : false;
}

template<> 
const char* State::to<const char*>(int idx)
{
    return lua_tostring(l_, idx);
}

template<> 
std::string State::to<std::string>(int idx)
{
    return lua_tostring(l_, idx);
}

template<> 
void* State::to<void*>(int idx)
{
    return lua_touserdata(l_, idx);
}

template<> 
const void* State::to<const void*>(int idx)
{
    return lua_topointer(l_, idx);
}

template<> 
lua_CFunction State::to<lua_CFunction>(int idx)
{
    return lua_tocfunction(l_, idx);
}

int State::top()
{
    return lua_gettop(l_);
}

/// @todo used function with luaL_ name prefix, replace with our function
void State::openpackage()
{
    luaL_requiref(l_, LUA_LOADLIBNAME, luaopen_package, 1);
    pop(1); /* remove lib */
}

void State::opencoroutine()
{
    luaL_requiref(l_, LUA_COLIBNAME, luaopen_coroutine, 1);
    pop(1); /* remove lib */
}

void State::openbase()
{
    luaL_requiref(l_, "_G", luaopen_base, 1);
    pop(1); /* remove lib */
}

void State::opentable()
{
    luaL_requiref(l_, LUA_TABLIBNAME, luaopen_table, 1);
    pop(1); /* remove lib */
}

void State::openio()
{
    luaL_requiref(l_, LUA_IOLIBNAME, luaopen_io, 1);
    pop(1); /* remove lib */
}

void State::openos()
{
    luaL_requiref(l_, LUA_OSLIBNAME, luaopen_os, 1);
    pop(1); /* remove lib */
}

void State::openstring()
{
    luaL_requiref(l_, LUA_STRLIBNAME, luaopen_string, 1);
    pop(1); /* remove lib */
}

void State::openbit32()
{
    luaL_requiref(l_, LUA_BITLIBNAME, luaopen_bit32, 1);
    pop(1); /* remove lib */
}

void State::openmath()
{
    luaL_requiref(l_, LUA_MATHLIBNAME, luaopen_math, 1);
    pop(1); /* remove lib */
}

void State::opendebug()
{
    luaL_requiref(l_, LUA_DBLIBNAME, luaopen_debug, 1);
    pop(1); /* remove lib */
}

int State::call(int numOfArgs, int numOfRetValues)
{
    enum {funcIdx = 1};

	push(db_traceback);
    const int errorHandlerFunctionIdx = top();
    push(Value, funcIdx);
    int rc = lua_pcall(l_, numOfArgs, numOfRetValues, errorHandlerFunctionIdx);
    
    lua_remove(l_, errorHandlerFunctionIdx);
    lua_remove(l_, funcIdx);
    
    return rc;
}

int State::dofile(const char* filename)
{
	push(db_traceback);  // push error handle function on stack
    const int errorHandlerFunctionIdx = top();

    int rc = luaL_loadfile(l_, filename);
    if (0 == rc)
        rc = lua_pcall(l_, 0, LUA_MULTRET, errorHandlerFunctionIdx);

    remove(errorHandlerFunctionIdx);

    return rc;
}

void* State::userdata(size_t size)
{
    return lua_newuserdata(l_, size);
}

void State::table()
{
    lua_newtable(l_);
}

void State::settable(int idx)
{
    lua_settable(l_, idx);
}

void State::gettable(int idx)
{
    lua_gettable(l_, idx);
}

void State::getfield(int idx, const char* key)
{
    lua_getfield(l_, idx, key);
}

void State::setfield(int idx, const char* key)
{
    lua_setfield(l_, idx, key);
}

void State::getmetatable(int idx)
{
    lua_getmetatable(l_, idx);
}

void State::setmetatable(int idx)
{
    lua_setmetatable(l_, idx);
}

void State::rawset(int idx)
{
    lua_rawset(l_, idx);
}

void State::rawget(int idx)
{
    lua_rawget(l_, idx);
}

void State::getmetatable(int idx)
{
    lua_getmetatable(l_, idx);
}

void State::setmetatable(int idx)
{
    lua_setmetatable(l_, idx);
}

} // namespace Lua
