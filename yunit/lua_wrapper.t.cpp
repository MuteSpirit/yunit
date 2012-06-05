//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// lua_wrapper.t.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "cppunit.h"
#include "lua_wrapper.h"

namespace Lua {

LUA_CLASS(Object)
{
    ADD_CONSTRUCTOR(Object);
    ADD_DESTRUCTOR(Object);

    ADD_METHOD(Object, name);
}

LUA_CONSTRUCTOR(Object)
{
    return 0;
}

LUA_DESTRUCTOR(Object)
{
    return 0;
}

LUA_METHOD(Object, name)
{
    return 0;
}

test(exposing_cpp_object_into_lua)
{
    StateGuard lua;

    LUA_REGISTER(Object)(lua);

    if(lua.dostring(
        "errmsg = 'create Object" "\r\n"
        "local obj = Object('objName')" "\r\n"
        "if not obj then return; end" "\r\n"

        "errmsg = 'call Object method'" "\r\n"
        "if 'objName' ~= obj:name() then return; end" "\r\n"

        "errmsg = 'ok'" "\r\n"))
        areEq(lua.to<const char*>(), "");

    lua.getglobal("errmsg");
    areEq("ok", lua.to<const char*>());
}

} // namespace Lua
