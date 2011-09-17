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
template<typename CppType>
CppType* to(lua_State* L, int index)
{
    if (!lua_isuserdata(L, index))
        luaL_error(L, "cannot use 'self' object, userdata expected, but was %s", lua_typename(L, lua_type(L, index)));
    
    CppType** pp = reinterpret_cast<CppType**>(lua_touserdata(L, index));
    if (NULL == pp)
        luaL_error(L, "cannot use 'self' object, it equals to NULL");
    
    CppType* p = *pp;
    if (NULL == pp)
        luaL_error(L, "cannot use 'self' object, it points to NULL value");

    return p;
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

template<typename CppType>
int push(lua_State *L, CppType* cppObj, const char* mtName)
{
    CppType** res = (CppType**)lua_newuserdata(L, sizeof(CppType*));
    luaL_getmetatable(L, mtName);
	lua_setmetatable(L, -2);
    *res = cppObj;

    return 1;
}

#endif // _YUNIT_LUA_CLASS_WRAPPER_HEADER_


