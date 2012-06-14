//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// lua_wrapper.h
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if _MSC_VER > 1000
#  pragma once
#endif

#ifndef _YUNIT_LUA_WRAPPER_HEADER_
#define _YUNIT_LUA_WRAPPER_HEADER_

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

#include "yunit.h"
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
namespace Lua {

class State;
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class YUNIT_API Table
{
    friend class State;
public:
    Table(int narr = 0, int nrec = 0)
    : narr_(narr)
    , nrec_(nrec)
    {
    }
private:
    int narr_;
    int nrec_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class YUNIT_API Value
{
    friend class State;
public:
    Value(int idx)
    : idx_(idx)
    {
    }
private:
    int idx_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class YUNIT_API Userdata
{
    friend class State;
public:
    Userdata(size_t size)
    : size_(size)
    {
    }
private:
    size_t size_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class YUNIT_API LuaCclosure
{
    friend class State;
public:
    LuaCclosure(lua_CFunction fn, int numOfUpvalues)
    : fn_(fn)
    , numOfUpvalues_(numOfUpvalues)
    {}

private:
    lua_CFunction fn_;
    int numOfUpvalues_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class YUNIT_API String
{
public:
    String(const char *s = nullptr, size_t size = 0)
    : s_(s)
    , size_(size)
    {}

public:
    const char *s_;
    size_t size_;
};


enum _Nil { Nil };
        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class YUNIT_API State
{
public:
    enum {topIdx = -1};

public:
    State(lua_State* L);
    
    operator lua_State*()
    {
        return l_;
    }
    
    void push(int v);
    void push(long v);
    void push(unsigned v);
    void push(unsigned long v);
    void push(double v);
    void push(bool value);
    void push(const char* s);
    void push(const std::string& s);
    void push(const char* s, size_t len);
    void pushf(const char* fmt, ...); /// @todo Сделать push(String) и переделать функции по добавлению строки в набор конструкторов
    void push(lua_CFunction func);
    void push(void *ptr);
    void push(Value v);
    void push(Table t);
    void push(_Nil);
    void push(Userdata ud);
    
    void pushglobaltable();

    template<typename CppType>
    void push(CppType* cppObj, const char* mtName);
    
    void pop(unsigned n);
    void remove(int idx);
    
    const char* typeName(int idx);
    bool isstring(int idx);
    bool istable(int idx);
    bool isuserdata(int idx);
    bool isinteger(int idx);
    bool isnumber(int idx);
    bool isnil(int idx);
    
    void getglobal(const char* name);
    void setglobal(const char* name);

    void getfield(int idx, const char* key);
    void setfield(int idx, const char* key);

    void settable(int idx);

    void rawseti(int idx, int n);
    
    int top();    
    void top(int idx);
    
    const char* to(int idx, size_t* len);
    void to(int idx, const char** str, size_t* len);
    void to(int idx, const char** str);

    template<typename CppType> void to(int idx, CppType** cppObj); /// @todo It is not place for that function
    template<typename T>  T  to(int idx = topIdx);

    void getinfo(const char *what, lua_Debug *ar);

    void insert(int idx);

    int error(const char* fmt, ...);

    int dostring(const char *luaCode);
    int dostring(String luaCode);

    enum {multiRetValues = -1};
    int call(unsigned int numberOfArgs = 0, int numberOfReturnValues = multiRetValues);

protected:
    lua_State* l_;    
};

template<> unsigned long State::to<unsigned long>(int idx);
template<> const char*   State::to<const char*>(int idx);
template<> void*         State::to<void*>(int idx);


/////////////////////////////////////////////////////////////////////////////////////////////////////////////
class YUNIT_API StateGuard /* rename to StateLiveGuard */ : public State
{
    typedef State Parent;
public:
    StateGuard();   // create a new lua_State
    ~StateGuard();  // close it's lua_State, if it is not closed previously

    void close();   // close it's lua_State
};

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
class CppClassWrapperForLuaImpl;
//
// делаем локализованную "корзинку" для складывания метаметодов => не будет конфликта имен на глобальном уровне, 
// например, между разными библиотеками.
// метаметоды будут добавлены на этапе выполнения => объявления этих методов в классе не нужны.
// нужно только определение метода создания метатаблицы класса. Нужен какой-то уникальный указатель, 
// созданный на этапе компиляции, чтобы сохранить с таким ключом метатаблицу класса в реестре Lua
//
// used pattern: "Template Method"
/// @todo Добавить еще property, чтобы можно было делать так: "obj.var_ = value"

class YUNIT_API CppClassWrapperForLua
{
public:
    void addMethod(const char *name, lua_CFunction method);
    void makeClassMetatable(State &lua);

protected:
    lua_CFunction getMethod(const char *name);

    virtual void setClassMetatableContent(State &lua, const int classMtIdx) = 0;

private:
    CppClassWrapperForLuaImpl *impl_;
};

/// @brief Declaration new wrapper for C++ class into Lua.
/// Usage example:
///     LUA_CLASS(Object)
///     {
///         ADD_CONSTRUCTOR(Object);
///         ADD_DESTRUCTOR(Object);
///
///         ADD_METHOD(Object, name);
///     }

#define LUA_CLASS(className) \
    class LUA_WRAPPER_NAME(className) : public CppClassWrapperForLua\
    {\
    public:\
        static LUA_WRAPPER_NAME(className) *instance()\
        {\
            static LUA_WRAPPER_NAME(className) instance;\
            return &instance;\
        }\
    protected:\
        inline virtual void setClassMetatableContent(State &lua, const int classMtIdx);\
    };\
    \
    inline void className ## WrapperForLua::setClassMetatableContent(State &lua, const int classMtIdx)\

#define LUA_WRAPPER_NAME(className) className ## WrapperForLua


#define ADD_CONSTRUCTOR(className) \
    lua.push(getMethod(TOSTR(LUA_WRAPPER_CTOR_NAME(className))));\
    lua.setglobal(#className);\
    (void)classMtIdx; // avoid compiler warning about unused variable

#define LUA_WRAPPER_CTOR_NAME(className) className ## _ ## className


/// @details Don't use symbol tilda (~) in 'className' parameter
#define ADD_DESTRUCTOR(className) \
    lua.push(getMethod(TOSTR(LUA_WRAPPER_DTOR_NAME(className))));\
    lua.setfield(classMtIdx, "__gc");

#define LUA_WRAPPER_DTOR_NAME(className) className ## _ ## __gc


#define ADD_METHOD(className, methodName) \
    lua.push(getMethod(TOSTR(LUA_WRAPPER_METHOD_NAME(className, methodName))));\
    lua.setfield(classMtIdx, #methodName);

#define LUA_WRAPPER_METHOD_NAME(className, methodName) className ## _ ## methodName


/// @brief Use this macro to avoid using specific class in lua_State, for example,
///     StateGuard lua;
///     LUA_REGISTER(CppClass)(lua);
#define LUA_REGISTER(className) LUA_WRAPPER_NAME(className)::instance()->makeClassMetatable

/// @brief Define State::to<T*> method, used for wrapped C++ objects in local paradigm of C++ storaging in Lua
#define DEFINE_LUA_TO(T) \
    template<> \
    T* Lua::State::to<T*>(int idx)\
    {\
        return static_cast<T*>(*reinterpret_cast<void**>(to<void*>(idx)));\
    }

/// @details Create new userdata in Lua with size equal sizeof(void**) to store C++ object pointer, because
/// 1) client code may control memory allocating 
/// 2) userdata may have individual metatable
#define LUA_PUSH(cppObjPtr, className) \
    lua.push(Userdata(sizeof(void**)));\
    *reinterpret_cast<void**>(lua.to<void*>(topIdx)) = cppObjPtr;
/// @todo Доделать получение и установку метатаблицы
//    lua.push(reinterpret_cast<void*>(LUA_WRAPPER_NAME(className)::instance));\

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename LuaWrapperClass>
struct AddWrapperMethod
{
    AddWrapperMethod(const char *name, lua_CFunction func)
    {
        LuaWrapperClass::instance()->addMethod(name, func);
    }
};


/// Constructor/destructor/method definition of C++ class wrapper into Lua
#define LUA_CONSTRUCTOR(className) \
    static inline int LUA_WRAPPER_CTOR_NAME(className)##_Impl(Lua::State&);\
    static int LUA_WRAPPER_CTOR_NAME(className)(lua_State *L)\
    {\
        return LUA_WRAPPER_CTOR_NAME(className)##_Impl(Lua::State(L));\
    }\
    static AddWrapperMethod<LUA_WRAPPER_NAME(className)> addConstructorTo ## className ## Wrapper(TOSTR(LUA_WRAPPER_CTOR_NAME(className)), LUA_WRAPPER_CTOR_NAME(className));\
    static inline int LUA_WRAPPER_CTOR_NAME(className)##_Impl(Lua::State &lua)

#define LUA_DESTRUCTOR(className) \
    static inline int LUA_WRAPPER_DTOR_NAME(className)##_Impl(Lua::State&);\
    static int LUA_WRAPPER_DTOR_NAME(className)(lua_State *L)\
    {\
        return LUA_WRAPPER_DTOR_NAME(className)##_Impl(Lua::State(L));\
    }\
    static AddWrapperMethod<LUA_WRAPPER_NAME(className)> addDestructorTo ## className ## Wrapper(TOSTR(LUA_WRAPPER_DTOR_NAME(className)), LUA_WRAPPER_DTOR_NAME(className));\
    static inline int LUA_WRAPPER_DTOR_NAME(className)##_Impl(Lua::State &lua)
    
#define LUA_METHOD(className, methodName) \
    static inline int LUA_WRAPPER_METHOD_NAME(className, methodName)##_Impl(Lua::State&);\
    static int LUA_WRAPPER_METHOD_NAME(className, methodName)(lua_State *L)\
    {\
        return LUA_WRAPPER_METHOD_NAME(className, methodName)##_Impl(Lua::State(L));\
    }\
    static AddWrapperMethod<LUA_WRAPPER_NAME(className)> addMethod ## methodName ## To ## className ## Wrapper(TOSTR(LUA_WRAPPER_METHOD_NAME(className, methodName)), LUA_WRAPPER_METHOD_NAME(className, methodName));\
    static inline int LUA_WRAPPER_METHOD_NAME(className, methodName)##_Impl(Lua::State &lua)

} // namespace Lua

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename CppType>
class ClassMetatable
{
public:
    static ClassMetatable& instance();

    void addMethod(const char *name, lua_CFunction func);
    /// @todo replace next 2 method with registerInTable
    void makeMetatable(lua_State* L, const char* mtName);
    void regLib(lua_State* L, const char* name);
    
private:
    ClassMetatable();
    
    typedef std::vector<luaL_Reg> Methods;
    Methods methods_;
};

template<typename CppType>
ClassMetatable<CppType>& luaWrapper();

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
inline ClassMetatable<CppType>::ClassMetatable()
{
}

template<typename CppType>
inline ClassMetatable<CppType>& ClassMetatable<CppType>::instance()
{
    static ClassMetatable<CppType> wrapper;
    return wrapper;
}

template<typename CppType>
inline void ClassMetatable<CppType>::addMethod(const char *name, lua_CFunction func)
{
    methods_.resize(methods_.size() + 1);
    methods_.back().name = name;
    methods_.back().func = func;
}

template<typename CppType>
inline void ClassMetatable<CppType>::makeMetatable(lua_State* L, const char* mtName)
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
inline void ClassMetatable<CppType>::regLib(lua_State* L, const char* name)
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
ClassMetatable<CppType>& luaWrapper()
{
    return ClassMetatable<CppType>::instance();
}

template<typename CppType>
AddMethod<CppType>::AddMethod(const char *name, lua_CFunction func)
{
    ClassMetatable<CppType>::instance().addMethod(name, func);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
namespace Lua {

template<typename CppType>
inline void State::push(CppType* cppObj, const char* mtName)
{
    lua_State* L = l_;
    
    // Lua userdata will keep only C++ object pointer, not whole object, because object memory allocation is
    // responsibility of client code
    CppType** res = (CppType**)lua_newuserdata(L, sizeof(CppType*));
    luaL_getmetatable(L, mtName);
	lua_setmetatable(L, -2);
    *res = cppObj;
}

template<typename CppType>
inline void State::to(int idx, CppType** cppObj)
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

/// @todo Disadvantage of State's template methods is it's definition location in header file
/// So, we cannot incapsulate native Lua API from client

template<> 
inline unsigned long State::to<unsigned long>(int idx)
{
#if LUA_VERSION_NUM == 501
    return lua_tointeger(l_, idx);
#elif LUA_VERSION_NUM == 502
    return lua_tounsigned(l_, idx);
#else
#  error Unsupported Lua version
#endif
}

template<>
inline const char* State::to<const char*>(int idx)
{
    return lua_tostring(l_, idx);
}

template<>
inline void* State::to<void*>(int idx)
{
    return lua_touserdata(l_, idx);
}

} // namespace Lua

#endif // _YUNIT_LUA_WRAPPER_HEADER_
