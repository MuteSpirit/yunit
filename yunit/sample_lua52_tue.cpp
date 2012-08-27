//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// @file sample_lua_tue.cpp
/// @brief Engine for unit test on Lua 5.2 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#include "test_unit_engine.h"
#include "lua_wrapper.h"

using namespace Lua;

static const char* supportedExts[] = {"t.lua", NULL};

const char** testContainerExtensions()
{
    return supportedExts;
}

Test* loadTestContainer(const char *path)
{
    return NULL;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class LuaTest
{
    typedef LuaTest Self;    
public:
    LuaTest(lua_State *, const std::string& testFuncName);
    Test *test();
    
    void setUp(LoggerPtr);
    void test(LoggerPtr);
    void tearDown(LoggerPtr);
    
private:
    State lua_;
    std::string funcName_;
    Test test_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename T, void (T::*method)(LoggerPtr)>
void callAdapter(void *t, LoggerPtr logger)
{
    (static_cast<T*>(t)->*method)(logger);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
LuaTest::LuaTest(lua_State *lua, const std::string& testFuncName);
: lua_(lua)
, funcName_(testFuncName)
{
    test_.self_ = this;
    test_.setUp_ = callAdapter<Self, &Self::setUp>;
    test_.test_ = callAdapter<Self, &Self::test>;
    test_.tearDown_ = callAdapter<Self, &Self::tearDown>;
    test_.name_ = callAdapter<Self, &Self::name>;
    test_.source_ = callAdapter<Self, &Self::source>;
    test_.line_ = callAdapter<Self, &Self::line>;
    test_.isIgnored_ = callAdapter<Self, &Self::isIgnored>;
}

Test* LuaTest::test()
{
    return &test_;
}

