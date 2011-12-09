//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// lua_wrapper.t.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "cppunit.h"


namespace Lua {

static int cClosure(lua_State*)
{
    return 0;
}

test1(lua_state_stack_manipulations, UseLua)
{
    State lua(L);
    int top = 0;
    {
        lua.push(1U); ++top;

        unsigned int v = lua.to<unsigned int>(-1);
        areEq(1, v);
    }
    {
        lua.push(1UL); ++top;

        unsigned long v = lua.to<unsigned long>(-1);
        areEq(1, v);
    }
    {
        lua.push(1L); ++top;
        
        long v = lua.to<long>(-1);
        areEq(1, v);
    }
    {
        lua.push((int)1); ++top;
        
        int v = lua.to<int>(-1);
        areEq(1, v);
    }
    {
        lua.push(1.f); ++top;
        
        double v = lua.to<double>(-1);
        areDoubleEq(1., v, 0.0000001);
    }
    lua.push(1.); ++top;
    {
        lua.push(true); ++top;

        bool v = lua.to<bool>(-1);
        isTrue(v);
    }
    {
        lua.push("const char*"); ++top;
        
        const char* s = lua.to<const char*>(-1);
        areEq("const char*", s);
    }
    {
        lua.push(std::string("std::string")); ++top;

        std::string s = lua.to<std::string>(-1);
        areEq("std::string", s);
    }
    lua.push(Nil); ++top;
    isTrue(lua_isnil(L, -1));

    lua.push(Value, -1); ++top;
    isTrue(lua_isnil(L, -1));

    lua.push(Globaltable); ++top;
    {
        static void *p = &p;
        lua.push(p); ++top;

        void *t = lua.to<void *>(-1);
        areEq(p, t);

        const void *q = lua.to<const void *>(-1);
        areEq(q, t);
    }
    {
        lua.push(cClosure); ++top;

        lua_CFunction fn = lua.to<lua_CFunction>(-1);
        areEq(cClosure, fn);
    }

    areEq(top, lua.top());

    lua.pop(top - 1);
    lua.remove(-1);
    areEq(0, lua.top());
}


test1(lua_state_initialization, UseLuaWithoutStdLibs)
{
    Lua::State lua(L);
    {
        lua_getglobal(L, "_G");
        isTrue(lua_isnil(L, -1));
        lua_pop(L, 1);

        lua.openbase();

        lua_getglobal(L, "_G");
        isTrue(lua_istable(L, -1));
        lua_pop(L, 1);
    }
    {
        lua_getglobal(L, LUA_TABLIBNAME);
        isTrue(lua_isnil(L, -1));
        lua_pop(L, 1);

        lua.opentable();

        lua_getglobal(L, LUA_TABLIBNAME);
        isTrue(lua_istable(L, -1));
        lua_pop(L, 1);
    }
    {
        lua_getglobal(L, LUA_IOLIBNAME);
        isTrue(lua_isnil(L, -1));
        lua_pop(L, 1);

        lua.openio();

        lua_getglobal(L, LUA_IOLIBNAME);
        isTrue(lua_istable(L, -1));
        lua_pop(L, 1);
    }
    {
        lua_getglobal(L, LUA_STRLIBNAME);
        isTrue(lua_isnil(L, -1));
        lua_pop(L, 1);

        lua.openstring();

        lua_getglobal(L, LUA_STRLIBNAME);
        isTrue(lua_istable(L, -1));
        lua_pop(L, 1);
    }
    {
        lua_getglobal(L, LUA_BITLIBNAME);
        isTrue(lua_isnil(L, -1));
        lua_pop(L, 1);

        lua.openbit32();

        lua_getglobal(L, LUA_BITLIBNAME);
        isTrue(lua_istable(L, -1));
        lua_pop(L, 1);
    }
    {
        lua_getglobal(L, LUA_MATHLIBNAME);
        isTrue(lua_isnil(L, -1));
        lua_pop(L, 1);

        lua.openmath();

        lua_getglobal(L, LUA_MATHLIBNAME);
        isTrue(lua_istable(L, -1));
        lua_pop(L, 1);
    }
}

test1(lua_state_call_func, UseLuaWithoutStdLibs)
{
    struct _
    {
        static int cfunc(lua_State* L)
        {
            Lua::State(L).push(true);
            return 1;
        }
    };

    Lua::State lua(L);
    
    int topBefore = lua.top();
    lua.push(_::cfunc);
    int rc = lua.call(0, 1);
    areEq(1, lua.top() - topBefore);
    areEq(0, rc);

    isTrue(1 == lua_isboolean(L, -1));
    bool cfuncRc = lua.to<bool>(-1);
    isTrue(cfuncRc);
}

} // namespace Lua

