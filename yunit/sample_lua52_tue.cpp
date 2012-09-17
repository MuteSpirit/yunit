//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// @file sample_lua_tue.cpp
/// @brief Engine for unit test on Lua 5.2 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#include "test_engine_interface.h"
#include "lua_wrapper.h"
#include <assert.h>

using namespace Lua;

static const char* supportedExts[] = {"t.lua", NULL};

const char** testContainerExtensions()
{
    return supportedExts;
}

Test* loadTestContainer(const char *path)
{
//    Lua::State lua(Lua::State::newstate());
//    lua.loadfile(path);
//    int rc = lua.call();
//    if (0 == rc)
//    {
//        lua.pushglobaltable();
//        lua.push(nil);
//        while (lua.next())
//        {
//            enum {keyIdx = -2, valueIdx = -1};
//            if (lua.is<lua_CFunction>(valueIdx))
//            {
//                
//            }
//            lua.pop(1);
//        }
//    }
//    else
        return NULL;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class LuaTest
{
    typedef LuaTest Self;    
public:
    LuaTest(Lua::State&, const std::string& testFuncName);
    Test *test();
    
    void setUp(LoggerPtr);
    void test(LoggerPtr);
    void tearDown(LoggerPtr);

	int isIgnored() const;

	const char* name() const;
	const char* source() const;
    int line() const;
    
private:
    Lua::State lua_;
    std::string funcName_;
    int isIgnored_;
    std::string source_;
    int line_;
    
    Test test_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename T, void (T::*method)(LoggerPtr)>
void callAdapter(void *t, LoggerPtr logger)
{
    (static_cast<T*>(t)->*method)(logger);
}

template<typename RetType, typename T, RetType (T::*method)() const>
RetType callAdapter(const void *self)
{
    return (static_cast<const T*>(self)->*method)();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
LuaTest::LuaTest(Lua::State &lua, const std::string& testFuncName)
: lua_(lua)
, funcName_(testFuncName)
{
    assert(!testFuncName.empty());
    isIgnored_ = ('_' == testFuncName[0]) ? 1 : 0;
    
    test_.self_ = this;
    test_.setUp_ = callAdapter<Self, &Self::setUp>;
    test_.test_ = callAdapter<Self, &Self::test>;
    test_.tearDown_ = callAdapter<Self, &Self::tearDown>;
    test_.name_ = callAdapter<const char*, Self, &Self::name>;
    test_.source_ = callAdapter<const char*, Self, &Self::source>;
    test_.line_ = callAdapter<int, Self, &Self::line>;
    test_.isIgnored_ = callAdapter<int, Self, &Self::isIgnored>;

    lua_Debug ar;
    lua_.getglobal(funcName_.c_str());
    lua_.getinfo("S", &ar);
    line_ = ar.lastlinedefined;
    source_ = ar.source;
}

Test* LuaTest::test()
{
    return &test_;
}

void LuaTest::setUp(LoggerPtr logger)
{
    success(logger);
}

void LuaTest::test(LoggerPtr logger)
{
    lua_.getglobal(funcName_.c_str());
    int rc = lua_.call();
    if (0 != rc)
        failure(logger, lua_.to<const char*>());
    else
        success(logger);
}

void LuaTest::tearDown(LoggerPtr logger)
{
    success(logger);
}

int LuaTest::isIgnored() const
{
    return isIgnored_;
}

const char* LuaTest::name() const
{
    return funcName_.c_str();
}

const char* LuaTest::source() const
{
    return source_.c_str();
}

int LuaTest::line() const
{
    return line_;
}

