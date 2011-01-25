//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// test.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
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


TESTUNIT_NS_BEGIN

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Bindings for Lua
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

// TestCase at Lua code:
// {
//		setUp = setUpCFunction,
//		test = testCFunction,
//		tearDown = tearDownCFunction,
//		this = userdata,	// pointer to C++ object of class TestCase
// }

static Thunk getSetUpThunk(TESTUNIT_NS::TestCase* testCase)
{
	return testCase->setUpThunk();
}

static Thunk getTestThunk(TESTUNIT_NS::TestCase* testCase)
{
	return testCase->testThunk();
}

static Thunk getTearDownThunk(TESTUNIT_NS::TestCase* testCase)
{
	return testCase->tearDownThunk();
}

static const char* getFuncName(Thunk (*getThunkFunc)(TESTUNIT_NS::TestCase*))
{
	if (&getSetUpThunk == getThunkFunc)
		return "setUp";
	else if (&getTestThunk == getThunkFunc)
		return "test";
	else if (&getTearDownThunk == getThunkFunc)
		return "tearDown";

	return "[unknown]";
}

static int errorObjectTableToLuaStackTop(lua_State *L,
                                     const TESTUNIT_NS::TestCase* testCase,
                                     Thunk (*getThunkFunc)(TESTUNIT_NS::TestCase*),
                                     const char* fileName,
                                     lua_Integer lineNumber,
                                     const char* message)
{
    enum {numberOfReturnValues = 1};
    // new Error Object (return value)
	lua_newtable(L);
    // function with error
	lua_pushfstring(L, "%s::%s()", testCase->name(), getFuncName(getThunkFunc));
	lua_setfield(L, -2, "func");		
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
                                     Thunk (*getThunkFunc)(TESTUNIT_NS::TestCase*),
                                     TESTUNIT_NS::TestCase* testCase,
                                     int& countReturnValues)
{
    countReturnValues = 0;
    try
    {
        (*getThunkFunc)(testCase).invoke();
    }
	catch (TESTUNIT_NS::TestException& ex)
    {
        // status code
		lua_pushboolean(L, false);
        ++countReturnValues;

		enum {bufferSize = 1024 * 5};
		char errorMessage[bufferSize] = {'\0'};
		ex.message(errorMessage, bufferSize);

        countReturnValues += errorObjectTableToLuaStackTop(
            L,
            testCase, getThunkFunc,
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
            testCase, getThunkFunc,
            "", 0,
            errorMessage);

		return true;
	}
    catch(...)
    {
		lua_pushboolean(L, false);
        ++countReturnValues;

        countReturnValues += errorObjectTableToLuaStackTop(
            L,
            testCase, getThunkFunc,
            "", 0,
            "Unexpected unknown C++ exception was caught");

		return true;
	}

	return false;
}

static int callTestCaseThunk(lua_State *L, Thunk (*getThunkFunc)(TESTUNIT_NS::TestCase*))
{
	lua_getfield(L, -1, "this");
	TESTUNIT_NS::TestCase* testCase = static_cast<TESTUNIT_NS::TestCase*>(lua_touserdata(L, -1));
    bool thereAreCppExceptions = false;
    int countReturnValues = 0;
    __try
    {
        thereAreCppExceptions = wereCatchedCppExceptions(L, getThunkFunc, testCase, countReturnValues);
    }
#ifdef _MSC_VER
    __except(EXCEPTION_EXECUTE_HANDLER)
#else
    __catch(...)
#endif
    {
		lua_pushboolean(L, false); // status code
        countReturnValues = 1;

        countReturnValues += errorObjectTableToLuaStackTop(
            L,
            testCase, getThunkFunc,
            "", 0,
            "Unexpected SEH exception was caught");
    }

    if (!thereAreCppExceptions)
    {
        // status code
	    lua_pushboolean(L, true);
        ++countReturnValues;

        countReturnValues += errorObjectTableToLuaStackTop(
            L,
            testCase, getThunkFunc,
            "", 0,
            "");
    }

    return countReturnValues;
}

int luaTestCaseSetUp(lua_State *L)
{
	return callTestCaseThunk(L, getSetUpThunk);
}

int luaTestCaseTest(lua_State *L)
{
	return callTestCaseThunk(L, getTestThunk);
}

int luaTestCaseTearDown(lua_State *L)
{
	return callTestCaseThunk(L, getTearDownThunk);
}

int getTestList(lua_State *L)
{
	lua_newtable(L); // table of all test cases
	lua_Number i = 1;

	TESTUNIT_NS::TestRegistry::TestSuiteIter it = TESTUNIT_NS::TestRegistry::initialize()->beginTestSuites();
	TESTUNIT_NS::TestRegistry::TestSuiteIter itEnd = TESTUNIT_NS::TestRegistry::initialize()->endTestSuites();
	for(; it != itEnd; ++it)
	{
		TESTUNIT_NS::TestSuite::TestCaseIter itTc = (*it)->beginTestCases();
		TESTUNIT_NS::TestSuite::TestCaseIter itTcEnd = (*it)->endTestCases();
		for(; itTc != itTcEnd; ++itTc)
		{
			lua_pushnumber(L, i++);	// order number of TestCase

			lua_newtable(L);	// TestCase
			// t["this"] = *itTc
			lua_pushlightuserdata(L, (*itTc));
			lua_setfield(L, -2, "this");
			// t["setUp"] = luaTestCaseSetUp
			lua_pushcfunction(L, TESTUNIT_NS::luaTestCaseSetUp);
			lua_setfield(L, -2, "setUp");
			// t["test"] = luaTestCaseTest
			lua_pushcfunction(L, TESTUNIT_NS::luaTestCaseTest);
			lua_setfield(L, -2, "test");
			// t["tearDown"] = luaTestCaseTearDown
			lua_pushcfunction(L, TESTUNIT_NS::luaTestCaseTearDown);
			lua_setfield(L, -2, "tearDown");
			// t["name_"] =
			lua_pushfstring(L, "%s::%s", (*it)->name(), (*itTc)->name());
			lua_setfield(L, -2, "name_");
			// t["isIgnored_"] =
			lua_pushboolean(L, (*itTc)->isIgnored());
			lua_setfield(L, -2, "isIgnored_");

			// add table of TestCase into common list
			// t[i] = testcase
			lua_settable(L, -3);
		}
	}

	return 1;
}

TESTUNIT_NS_END


static const struct luaL_Reg cppunitLuaFunctions[] =
{
	{"getTestList", TESTUNIT_NS::getTestList},
	{NULL, NULL},
};

extern "C"
int TESTUNIT_API luaopen_cppunit(lua_State *L)
{
	luaL_register(L, "cppunit", cppunitLuaFunctions);
	return 0;
}
