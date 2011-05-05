//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// test.cpp
//
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
// Bindings for Lua
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

// TestCase at Lua code:
// {
//		innerSetUp = setUpCFunction,
//		test = testCFunction,
//		innerTearDown = tearDownCFunction,
//		this = userdata,	// pointer to C++ object of class TestCase
// }

static Thunk getSetUpThunk(TestCase* testCase)
{
	return testCase->setUpThunk();
}

static Thunk getTestThunk(TestCase* testCase)
{
	return testCase->testThunk();
}

static Thunk getTearDownThunk(TestCase* testCase)
{
	return testCase->tearDownThunk();
}

static int errorObjectTableToLuaStackTop(lua_State *L,
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

static bool wereCatchedCppExceptions(lua_State *L,
                                     Thunk (*getThunkFunc)(TestCase*),
                                     TestCase* testCase,
                                     int& countReturnValues)
{
    countReturnValues = 0;
    try
    {
        (*getThunkFunc)(testCase).invoke();
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

static int callTestCaseThunk(lua_State *L, Thunk (*getThunkFunc)(TestCase*))
{
	lua_getfield(L, -1, "this");
	YUNIT_NS::TestCase* testCase = static_cast<TestCase*>(lua_touserdata(L, -1));
    bool thereAreCppExceptions = false;
    int countReturnValues = 0;
#ifdef _MSC_VER
    __try
    {
        thereAreCppExceptions = wereCatchedCppExceptions(L, getThunkFunc, testCase, countReturnValues);
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
    thereAreCppExceptions = wereCatchedCppExceptions(L, getThunkFunc, testCase, countReturnValues);
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

static int luaTestCaseSetUp(lua_State *L)
{
	return callTestCaseThunk(L, getSetUpThunk);
}

static int luaTestCaseTest(lua_State *L)
{
	return callTestCaseThunk(L, getTestThunk);
}

static int luaTestCaseTearDown(lua_State *L)
{
	return callTestCaseThunk(L, getTearDownThunk);
}

static int getTestList(lua_State *L)
{
	lua_newtable(L); // table of all test cases
	lua_Number i = 1;

	TestRegistry::TestSuiteConstIter it = TestRegistry::initialize()->begin();
	TestRegistry::TestSuiteConstIter itEnd = TestRegistry::initialize()->end();
	for(; it != itEnd; ++it)
	{
		TestSuite::TestCaseConstIter itTc = (*it)->begin();
		TestSuite::TestCaseConstIter itTcEnd = (*it)->end();
		for(; itTc != itTcEnd; ++itTc)
		{
			lua_pushnumber(L, i++);	// order number of TestCase

			lua_newtable(L);	// TestCase
			// t["this"] = *itTc
			lua_pushlightuserdata(L, (*itTc));
			lua_setfield(L, -2, "this");
			// t["setUp"] = luaTestCaseSetUp
			lua_pushcfunction(L, luaTestCaseSetUp);
			lua_setfield(L, -2, "setUp");
			// t["test"] = luaTestCaseTest
			lua_pushcfunction(L, luaTestCaseTest);
			lua_setfield(L, -2, "test");
			// t["tearDown"] = luaTestCaseTearDown
			lua_pushcfunction(L, luaTestCaseTearDown);
			lua_setfield(L, -2, "tearDown");
			// t["name_"] =
			lua_pushfstring(L, "%s::%s", (*it)->name(), (*itTc)->name());
			lua_setfield(L, -2, "name_");
			// t["isIgnored_"] =
			lua_pushboolean(L, (*itTc)->isIgnored());
			lua_setfield(L, -2, "isIgnored_");

			// t["lineNumber_"] =
            lua_pushinteger(L, (*itTc)->source().lineNumber());
			lua_setfield(L, -2, "lineNumber_");

			// t["fileName_"] =
            lua_pushstring(L, (*itTc)->source().fileName());
			lua_setfield(L, -2, "fileName_");

            // add table of TestCase into common list
			// t[i] = testcase
			lua_settable(L, -3);
		}
	}

	return 1;
}

static int getTestContainerExtensions(lua_State *L)
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

static int errLoadContainerHandler(lua_State*)
{
    return 0;
}

static int loadTestContainer(lua_State *L)
{
    if (const char* path = lua_tostring(L, 1))
    {
        // we must only load library to current process for initialization global objects and
        // filling test register
        lua_pushcfunction(L, errLoadContainerHandler);
        lua_getglobal(L, "package");
        lua_getfield(L, -1, "loadlib");
        lua_pushstring(L, path);
        lua_pushstring(L, "");  // not load specified function
        lua_pushboolean(L, (0 == lua_pcall(L, 2, 1, -5)) ? 1 : 0);
        lua_pushfstring(L, "error during package.loadlib('%s') call", path);
    }
    else
    {
        lua_pushboolean(L, 0);
        lua_pushstring(L, "invalid argument");
    }

    return 2;
}

} // namespace YUNIT_NS


static const struct luaL_Reg cppunitLuaFunctions[] =
{
	{"loadTestContainer", YUNIT_NS::loadTestContainer},
	{"getTestContainerExtensions", YUNIT_NS::getTestContainerExtensions},
	{"getTestList", YUNIT_NS::getTestList},
	{NULL, NULL},
};

extern "C"
int YUNIT_API luaopen_cppunit(lua_State *L)
{
	luaL_register(L, "cppunit", cppunitLuaFunctions);
	return 0;
}
