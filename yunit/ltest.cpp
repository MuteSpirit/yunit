//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// \file ltest.cpp
/// \brief Bindings for Lua
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifdef _MSC_VER
	#define _CRT_SECURE_NO_WARNINGS 1
#endif

#include <stdio.h>

#ifdef _MSC_VER
#include <excpt.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#include "lua/lauxlib.h"
#include "lua/lualib.h"

#ifdef __cplusplus
}
#endif

#include "test.h"


namespace YUNIT_NS {

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
static int errorObjectTableToLuaStackTop(lua_State* L,
                                     const char* fileName,
                                     lua_Integer lineNumber,
                                     const char* message)
{
    enum {numberOfReturnValues = 1};
    // new Error Object (return value)
    lua_newtable(L);
    // source file with error
    lua_pushstring(L, fileName);
    lua_setfield(L, -2, "source");
    // number of line with error
    lua_pushinteger(L, lineNumber);
    lua_setfield(L, -2, "line");
    // error message
    lua_pushstring(L, message);
    lua_setfield(L, -2, "message");

    return numberOfReturnValues;
}

static bool wereCatchedCppExceptions(lua_State* L, TestCase* testCase, Thunk thunk, int& countReturnValues)
{
    countReturnValues = 0;
    try
    {
        thunk.invoke();
    }
	catch (TestException& ex)
    {
        // status code
		lua_pushboolean(L, false);
        ++countReturnValues;

		enum {bufferSize = 1024 * 5};
		char errorMessage[bufferSize] = {'\0'};
		ex.message(errorMessage, bufferSize);

        countReturnValues += errorObjectTableToLuaStackTop(
            L,
            ex.sourceLine().fileName(), ex.sourceLine().lineNumber(),
            errorMessage);

		return true;
    }
    catch(std::exception& ex)
    {
        lua_pushboolean(L, false);
        ++countReturnValues;

        enum {bufferSize = 1024 * 5};
        char errorMessage[bufferSize] = {'\0'};
        TS_SNPRINTF(errorMessage, bufferSize - 1, "Unexpected std::exception was caught: %s", ex.what());

        countReturnValues += errorObjectTableToLuaStackTop(
            L,
            testCase->source().fileName(), testCase->source().lineNumber(),
            errorMessage);

		return true;
    }
    catch(...)
    {
        lua_pushboolean(L, false);
        ++countReturnValues;

        countReturnValues += errorObjectTableToLuaStackTop(
            L,
            testCase->source().fileName(), testCase->source().lineNumber(),
            "Unexpected unknown C++ exception was caught");

		return true;
	}

	return false;
}

static int callTestCaseThunk(lua_State* L, TestCase* testCase, Thunk thunk)
{
    bool thereAreCppExceptions = false;
    int countReturnValues = 0;
#ifdef _MSC_VER
    __try
    {
        thereAreCppExceptions = wereCatchedCppExceptions(L, testCase, thunk, countReturnValues);
    }
    __except(EXCEPTION_EXECUTE_HANDLER)
    {
		lua_pushboolean(L, false); // status code
        countReturnValues = 1;

        countReturnValues += errorObjectTableToLuaStackTop(
            L,
            testCase->source().fileName(), testCase->source().lineNumber(),
            "Unexpected SEH exception was caught");
    }
#else // not defined _MSC_VER
    thereAreCppExceptions = wereCatchedCppExceptions(L, testCase, thunk, countReturnValues);
#endif
    if (!thereAreCppExceptions)
    {
        // status code
	    lua_pushboolean(L, true);
        ++countReturnValues;

        countReturnValues += errorObjectTableToLuaStackTop(
            L,
            testCase->source().fileName(), testCase->source().lineNumber(),
            "");
    }

    return countReturnValues;
}

static TestCase* getTestCaseFromSelf(lua_State* L)
{
    if (!lua_isuserdata(L, 1))
        luaL_error(L, "cannot use 'self' object, because userdata expected, but was %s", lua_typename(L, lua_type(L, 1)));
    
    TestCase** tcPp = reinterpret_cast<TestCase**>(lua_touserdata(L, 1));
    if (NULL == tcPp)
        luaL_error(L, "cannot use 'self' object, it equals NULL");
    
    TestCase* tc = *tcPp;
    if (NULL == tcPp)
        luaL_error(L, "cannot use 'self' object, it points to NULL value");

    return tc;
}

static int luaTestCaseSetUp(lua_State* L)
{
    TestCase* tc = getTestCaseFromSelf(L);
    return callTestCaseThunk(L, tc, tc->setUpThunk());
}

static int luaTestCaseTest(lua_State* L)
{
    TestCase* tc = getTestCaseFromSelf(L);
    return callTestCaseThunk(L, tc, tc->testThunk());
}

static int luaTestCaseTearDown(lua_State* L)
{
    TestCase* tc = getTestCaseFromSelf(L);
    return callTestCaseThunk(L, tc, tc->tearDownThunk());
}

static int luaTestCaseIsIgnored(lua_State* L)
{
    TestCase* tc = getTestCaseFromSelf(L);
    lua_pushboolean(L, tc->isIgnored());
    return 1;
}

static int luaTestCaseLineNumber(lua_State* L)
{
    TestCase* tc = getTestCaseFromSelf(L);
    lua_pushinteger(L, tc->source().lineNumber());
    return 1;
}

static int luaTestCaseFileName(lua_State* L)
{
    TestCase* tc = getTestCaseFromSelf(L);
    lua_pushstring(L, tc->source().fileName());
    return 1;
}

static int luaTestCaseName(lua_State* L)
{
    TestCase* tc = getTestCaseFromSelf(L);

    lua_pushfstring(L, "%s::%s", tc->source().fileName(), tc->name());
    return 1;
}

static const char* testCaseMtName = "testCaseMetatable";

static void createTestCaseMetatable(lua_State* L)
{
    static const struct luaL_Reg testCaseMetods[] = 
    {
        {"setUp", luaTestCaseSetUp},
        {"test", luaTestCaseTearDown},
        {"tearDown", luaTestCaseTearDown},
        {"isIgnored", luaTestCaseIsIgnored},
        {"name", luaTestCaseName},
        {"lineNumber", luaTestCaseLineNumber},
        {"fileName", luaTestCaseFileName},
        {NULL, NULL}
    };
    
    luaL_newmetatable(L, testCaseMtName);
    luaL_register(L, NULL, testCaseMetods);

    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index"); // metatable.__index = metatable
    
    lua_pop(L, 1); // remove new metatable from stack
}

static int getTestList(lua_State* L)
{
	lua_newtable(L); // all test cases list

    lua_Number i = 1;
	TestRegistry::TestSuiteConstIter it = TestRegistry::initialize()->begin();
	TestRegistry::TestSuiteConstIter endIt = TestRegistry::initialize()->end();
	for(; it != endIt; ++it)
	{
		TestSuite::TestCaseConstIter itTc = (*it)->begin();
		TestSuite::TestCaseConstIter endItTc = (*it)->end();
		for(; itTc != endItTc; ++itTc)
		{
			lua_pushnumber(L, i++);	// order number of TestCase

            TestCase** tc = reinterpret_cast<TestCase**>(lua_newuserdata(L, sizeof(TestCase*)));
	        *tc = *itTc;

            luaL_getmetatable(L, testCaseMtName);
	        lua_setmetatable(L, -2);

			lua_settable(L, -3); // t[i] = testcase
		}
	}

	return 1;
}

static int getTestContainerExtensions(lua_State* L)
{
    const char** extList = getTestContainerExtensions();

    lua_newtable(L);

    const char** p = extList;
    int i = 1;
    while(p && *p)
    {
        lua_pushnumber(L, i++); 
        lua_pushstring(L, *p++);
        lua_settable(L, -3);
    }

    return 1;
}

static int loadTestContainer(lua_State* L)
{
    if (!lua_isstring(L, 1))
    {
        lua_pushboolean(L, 0);
        lua_pushfstring(L, "expected string as argument type, but was %s", lua_typename(L, lua_type(L, 1)));
        return 2;
    }
    
    size_t len;
    const char* path = lua_tolstring(L, 1, &len);
    if (0 == len)
    {
        lua_pushboolean(L, 0);
        lua_pushstring(L, "empty argument");
        return 2;
    }
    //
    // we must only load library to current process for initialization global objects and filling test register
    //
    // push error handling function
    lua_getglobal(L, "debug");
    lua_getfield(L, -1, "traceback");
    lua_remove(L, -2);
    //
    // push function
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "loadlib");
    lua_remove(L, -2);
    //
    lua_pushstring(L, path); // 1st argument
    lua_pushstring(L, "");     // 2nd argument ("" means not load specified function)
    //
    int rc = lua_pcall(L, 2, 1, -4);
    if (0 != rc)
    {
        lua_pushboolean(L, 0);
        lua_pushvalue(L, -2);   // push copy of error message
        lua_remove(L, -3);       // remove original error message from stack
        return 2;
    }
    
    lua_pop(L, 1);  // remove return value of 'package.loadlib' function
    lua_pushboolean(L, 1);
    return 1;
}

} // namespace YUNIT_NS

extern "C"
int YUNIT_API luaopen_cppunit(lua_State* L)
{
    static const struct luaL_Reg cppunit[] =
    {
	    {"loadTestContainer", YUNIT_NS::loadTestContainer},
	    {"getTestContainerExtensions", YUNIT_NS::getTestContainerExtensions},
	    {"getTestList", YUNIT_NS::getTestList},
	    {NULL, NULL},
    };

    YUNIT_NS::createTestCaseMetatable(L);
	luaL_register(L, "cppunit", cppunit);
	return 0;
}
