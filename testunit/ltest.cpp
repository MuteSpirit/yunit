//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// test.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

#include "lua\lauxlib.h"
#include "lua\lualib.h"

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

#if defined(_MSC_VER) && defined(_DEBUG)
#pragma optimize("g", off)
#endif

static int callTestCaseThunk(lua_State *L, Thunk (*getThunkFunc)(TESTUNIT_NS::TestCase*))
{
	lua_getfield(L, 1, "this");
	TESTUNIT_NS::TestCase* testCase = static_cast<TESTUNIT_NS::TestCase*>(lua_touserdata(L, -1));
    try
    {
        (*getThunkFunc)(testCase).invoke();
    }
	catch (TESTUNIT_NS::TestException& ex)
    {
		lua_pushboolean(L, false);			// status code

		lua_newtable(L);					// ErrorObject table

		lua_pushstring(L, ex.sourceLine().fileName());
		lua_setfield(L, -2, "source");		// source file with error

		lua_pushfstring(L, "%s::%s()", testCase->name(), getFuncName(getThunkFunc));
		lua_setfield(L, -2, "func");		// function with error

		lua_pushinteger(L, ex.sourceLine().lineNumber());
		lua_setfield(L, -2, "line");		// number of line with error

		enum {bufferSize = 1024 * 10};
		char buffer[bufferSize] = {'\0'};
		ex.message(buffer, bufferSize);
		lua_pushstring(L, buffer);			// error message
		lua_setfield(L, -2, "message");
		// now we have bool and table on the top of Lua stack

		return 2;
    }
    catch(std::exception& ex)
    {
		lua_pushboolean(L, false);			// status code

		lua_newtable(L);					// ErrorObject table

		lua_pushstring(L, "");
		lua_setfield(L, -2, "source");		// source file with error

		lua_pushfstring(L, "%s::%s()", testCase->name(), getFuncName(getThunkFunc));
		lua_setfield(L, -2, "func");		// function with error

		lua_pushinteger(L, 0);
		lua_setfield(L, -2, "line");		// number of line with error

		lua_pushfstring(L, "Unexpected std::exception was caught: %s", ex.what());
		lua_setfield(L, -2, "message");
		// now we have bool and table on the top of Lua stack

		return 2;
	}
    catch(...)
    {
		lua_pushboolean(L, false);			// status code

		lua_newtable(L);					// ErrorObject table

		lua_pushstring(L, "");
		lua_setfield(L, -2, "source");		// source file with error

		lua_pushfstring(L, "%s::%s()", testCase->name(), getFuncName(getThunkFunc));
		lua_setfield(L, -2, "func");		// function with error

		lua_pushinteger(L, 0);
		lua_setfield(L, -2, "line");		// number of line with error

		lua_pushstring(L, "Unexpected unknown exception was caught");
		lua_setfield(L, -2, "message");
		// now we have bool and table on the top of Lua stack

		return 2;
	}

	lua_pushboolean(L, true);			// status code

	lua_newtable(L);					// ErrorObject table

	lua_pushstring(L, "");
	lua_setfield(L, -2, "source");

	lua_pushfstring(L, "%s::%s()", testCase->name(), getFuncName(getThunkFunc));
	lua_setfield(L, -2, "func");		// function with error

	lua_pushinteger(L, 0);
	lua_setfield(L, -2, "line");		// number of line with error

	lua_pushstring(L, "");
	lua_setfield(L, -2, "message");

	return 2;
}
#if defined(_MSC_VER) && defined(_DEBUG)
#pragma optimize("g", on)
#endif

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
			// CppUnit mustn't know about TestRunner
			//lua_getfield(L, LUA_GLOBALSINDEX, "test_runner");
			//lua_getfield(L, -1, "TestCaseList");
			//lua_getfield(L, -1, "add");
			//lua_remove(L, -2);	// {"test_runner", "TestCaseList", "add"}. remove "TestCaseList" table
			//// we will call 'TestCaseList:add', not 'TestCaseList.add'
			//lua_getfield(L, -2, "TestCaseList");
			//lua_remove(L, -3);	// {"test_runner", "add", "TestCaseList"}. remove "test_runner" table

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

			//lua_call(L, 2, 1);
			// add tab,le of TestCase into common list
			// t[i] = testcase
			lua_settable(L, -3);
		}
	}

	return 1;
}

TESTUNIT_NS_END

//int luaStub(lua_State*)
//{
//	return 0;
//}


//#ifdef TS_TEST

static const struct luaL_Reg cppunitLuaFunctions[] =
{
	//{"stub", luaStub},
	{"getTestList", TESTUNIT_NS::getTestList},
	{NULL, NULL},
};

extern "C"
int AFL_API luaopen_cppunit(lua_State *L)
{
	luaL_register(L, "cppunit", cppunitLuaFunctions);
	return 0;
}

//#endif // #ifdef TS_TEST
