//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// class_wrapper.h
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef _YUNIT_LUA_CLASS_WRAPPER_HEADER_
#define _YUNIT_LUA_CLASS_WRAPPER_HEADER_

#include <vector>

#ifdef __cplusplus
extern "C" {
#endif

#include "lua.h"
#include "lauxlib.h"

#ifdef __cplusplus
}
#endif

#define LUA_METHOD(CppType, method)\
    static int method##CppType(lua_State* L);\
    static AddMethod<CppType> add##method##to##CppType##Wrapper(#method, &method##CppType);\
    static int method##CppType(lua_State* L)

#define MT_NAME(CppType) #CppType "Metatable"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class LuaState
{
public:
    LuaState(lua_State* L);
    
    operator lua_State*();
    
    void newtable();
    void settable(int idx);
    void setfield(int idx, const char* key);
    
    void push(lua_Number value);
    void push(lua_Integer value);
    void push(bool value);
    void push(const char* s);
    void push(const char* s, size_t len);
    void pushvalue(int idx);
    void pushnil();

    template<typename CppType>
    void push(CppType* cppObj, const char* mtName);
    
    void pop(int n);
    
    void rawseti(int idx, int n);
    
    bool isstring(int idx);
    bool istable(int idx);
    bool isuserdata(int idx);
    bool isinteger(int idx);
    bool isnumber(int idx);
    bool isnil(int idx);
    
    void getglobal(const char* name);
    void getfield(int idx, const char* key);
    
    const char* to(int idx, size_t* len);

    template<typename CppType>
    void to(int idx, CppType** cppObj);
    
    void remove(int idx);
    
private:
    lua_State* l_;    
};


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename CppType>
class LuaWrapper
{
public:
    static LuaWrapper& instance();

    void addMethod(const char *name, lua_CFunction func);

    void makeMetatable(lua_State* L, const char* mtName);
    void regLib(lua_State* L, const char* name);
    
private:
    LuaWrapper();
    
    static const luaL_Reg endMethodsSign_;
    std::vector<luaL_Reg> methods_;
};

template<typename CppType>
LuaWrapper<CppType>& luaWrapper();

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename CppType>
struct AddMethod
{
    AddMethod(const char *name, lua_CFunction func);
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Implementation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

template<typename CppType>
const luaL_Reg LuaWrapper<CppType>::endMethodsSign_ = {NULL, NULL};

template<typename CppType>
LuaWrapper<CppType>::LuaWrapper()
{
}

template<typename CppType>
LuaWrapper<CppType>& LuaWrapper<CppType>::instance()
{
    static LuaWrapper<CppType> wrapper;
    return wrapper;
}

template<typename CppType>
inline void LuaWrapper<CppType>::addMethod(const char *name, lua_CFunction func)
{
    methods_.resize(methods_.size() + 1);
    methods_.back().name = name;
    methods_.back().func = func;
}

template<typename CppType>
inline void LuaWrapper<CppType>::makeMetatable(lua_State* L, const char* mtName)
{
    luaL_newmetatable(L, mtName);
    
    methods_.push_back(endMethodsSign_);
    luaL_register(L, NULL, methods_.data());
    methods_.resize(methods_.size() - 1);

    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index"); // metatable.__index = metatable
    
    lua_pop(L, 1); // remove new metatable from stack
}

template<typename CppType>
inline void LuaWrapper<CppType>::regLib(lua_State* L, const char* name)
{
    methods_.push_back(endMethodsSign_);
    luaL_register(L, name, methods_.data());
    methods_.resize(methods_.size() - 1);
}

template<typename CppType>
LuaWrapper<CppType>& luaWrapper()
{
    return LuaWrapper<CppType>::instance();
}

template<typename CppType>
AddMethod<CppType>::AddMethod(const char *name, lua_CFunction func)
{
    LuaWrapper<CppType>::instance().addMethod(name, func);
}

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

template<typename CppType>
void LuaState::push(CppType* cppObj, const char* mtName)
{
    lua_State* L = l_;
    
    CppType** res = (CppType**)lua_newuserdata(L, sizeof(CppType*));
    luaL_getmetatable(L, mtName);
	lua_setmetatable(L, -2);
    *res = cppObj;
}

void LuaState::pop(int n)
{
    lua_pop(l_, n);
}

void LuaState::rawseti(int idx, int n)
{
    lua_rawseti(l_, idx, n);
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

const char* LuaState::to(int idx, size_t* len)
{
    return lua_tolstring(l_, idx, len);
}

template<typename CppType>
void LuaState::to(int idx, CppType** cppObj)
{
    lua_State* L = l_;
    
    if (!lua_isuserdata(L, idx))
        luaL_error(L, "cannot use 'self' object, userdata expected, but was %s", lua_typename(L, lua_type(L, idx)));
    
    CppType** pp = reinterpret_cast<CppType**>(lua_touserdata(L, idx));
    if (NULL == pp)
        luaL_error(L, "cannot use 'self' object, it equals to NULL");
    
    CppType* p = *pp;
    if (NULL == pp)
        luaL_error(L, "cannot use 'self' object, it points to NULL value");

    *cppObj = p;
}

void LuaState::remove(int idx)
{
    lua_remove(l_, idx);
}

template<typename CppType>
int dtor(lua_State* L)
{
    if (lua_gettop(L) >= 1)
    {
        CppType** pp = reinterpret_cast<CppType**>(lua_touserdata(L, 1));
        if (NULL == pp)
            luaL_error(L, "cannot use 'self' object, it equals to NULL");
        
        delete *pp;
        *pp = NULL; // to avoid deleting object twice, if __gc metametod will be called more then once
    }
}

#endif // _YUNIT_LUA_CLASS_WRAPPER_HEADER_


