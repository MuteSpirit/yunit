//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// lua_wrapper.h
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef _YUNIT_LUA_WRAPPER_HEADER_
#define _YUNIT_LUA_WRAPPER_HEADER_

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

#include <vector>
#include <string>

/// @todo use simple method: make a'la "require" function with defines

#define LUA_META_METHOD(CppType, method)\
    static int method##CppType(lua_State* L);\
    static AddMethod<CppType> add##method##to##CppType##Wrapper(#method, &method##CppType);\
    static int method##CppType(lua_State* L)

/// @todo More good idea is store metatable with some pointer (i.e. global function, ... ) as key in registry
/// so name is not needed
#define MT_NAME(CppType) #CppType "Metatable"

#define LUA_CHECK_ARG(luaType, idx)\
    if (!lua.is##luaType(idx))\
        lua.error("invalid argument №%d, " #luaType " expected, but was %s\r\n", (idx), lua.typeName(1));
        
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
    void pushnil(); /// @todo add special struct Nil and make void push(Nil)
    void pushglobaltable();

    template<typename CppType>
    void push(CppType* cppObj, const char* mtName);
    
    void pop(int n);
    void remove(int idx);
    
    void rawseti(int idx, int n);
    
    const char* typeName(int idx);
    bool isstring(int idx);
    bool istable(int idx);
    bool isuserdata(int idx);
    bool isinteger(int idx);
    bool isnumber(int idx);
    bool isnil(int idx);
    
    void getglobal(const char* name);
    void getfield(int idx, const char* key);
    
    int gettop();    
    void settop(int idx);
    
    const char* to(int idx, size_t* len);
    void to(int idx, const char** str, size_t* len);
    void to(int idx, const char** str);

    template<typename CppType>
    void to(int idx, CppType** cppObj);
    
    void getinfo(const char *what, lua_Debug *ar);
    
private:
    lua_State* l_;    
};


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename CppType>
class LuaWrapper /// @todo Rename to ClassMetatable
{
public:
    static LuaWrapper& instance();

    void addMethod(const char *name, lua_CFunction func);
    /// @todo replace next 2 method with registerInTable
    void makeMetatable(lua_State* L, const char* mtName);
    void regLib(lua_State* L, const char* name);
    
private:
    LuaWrapper();
    
    typedef std::vector<luaL_Reg> Methods;
    Methods methods_;
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
inline LuaWrapper<CppType>::LuaWrapper()
{
}

template<typename CppType>
inline LuaWrapper<CppType>& LuaWrapper<CppType>::instance()
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
    
    Methods::const_iterator it = methods_.begin(), endIt = methods_.end();
    for (; it != endIt; ++it)
    {
        lua_pushcfunction(L, it->func);
        lua_setfield(L, -2, it->name);
    }

    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index"); // metatable.__index = metatable
    
    lua_pop(L, 1); // remove new metatable from stack
}

template<typename CppType>
inline void LuaWrapper<CppType>::regLib(lua_State* L, const char* name)
{
    // we have to avoid usage luaL_register and luaL_setfuncs, because we want
    // to support Lua 5.1 and Lua 5.2
    lua_newtable(L);
    
    Methods::const_iterator it = methods_.begin(), endIt = methods_.end();
    for (; it != endIt; ++it)
    {
        lua_pushcfunction(L, it->func);
        lua_setfield(L, -2, it->name);
    }
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
template<typename CppType>
inline void LuaState::push(CppType* cppObj, const char* mtName)
{
    lua_State* L = l_;
    
    CppType** res = (CppType**)lua_newuserdata(L, sizeof(CppType*));
    luaL_getmetatable(L, mtName);
	lua_setmetatable(L, -2);
    *res = cppObj;
}

template<typename CppType>
inline void LuaState::to(int idx, CppType** cppObj)
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

#endif // _YUNIT_LUA_WRAPPER_HEADER_
