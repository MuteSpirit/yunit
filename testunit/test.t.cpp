//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// test.t.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// \class Test
/// \brief Interface class for all test classes

/// \class Fixture
/// \brief Interface class for tests, which are using some resources and their initialization and release are moved to
/// separate functions, which must be called correctly before and after test execution correspondingly

/// \class TestCase
/// \brief Interface class for run single test function. We will use this class as fundamental

/// \class TestSuite
/// \brief Class, containing several TestCase objects. It can't run them, it is only container for them.

/// \class TestRegistry
/// \brief Singleton. Contains all C++ TestSuites, consequently contains all TestCases.

/// \class template<typename TestSuiteClass> class RegisterTestSuite
/// \brief Create at constructor static object of TestSuiteClass type, then register it into TestRegistry

/// \class template<typename TestCaseClass> class RegisterTestCase
/// \brief Create at constructor static object of TestCaseClass type, then add it into TestSuite, whitch pointer is
/// passed to constructor as second argument

/// \class SourceLine
/// \brief Save info about file and line of code situation. Used at macro with variables __FILE__, __LINE__

/// \class TestException
/// \brief User exception type for throw during assert checks

/// \class TestConditionException
/// \brief User exception type for throw during assert check of bool condition

/// \class TestEqualException
/// \brief User exception type for throw during assert check of equaling two integral numbers

/// \class template<typename T> class TestDoubleEqualException
/// \brief User exception type for throw during assert check of equaling two float-point numbers

/// \def UNIQUE_TEST_NAMESPACE(name)
/// \brief Generate "unique" namespace name. 

/// \def TESTUNIT_SOURCELINE()
/// \brief Create temporary object of SourceLine type. Need for saving file name and line of assert crash

/// \def test(testName)
/// \brief Declare class 'testName', derived from TestCase. This test case will be added into previously test suite,
/// declared by TEST_SUITE macro

/// \def test1(testName, fixtureName)
/// \brief Declare class 'testName', derived from TestCase and 'fixtureName', i.e. it will have setUp and tearDown functions.
/// This test case will be added into previously test suite, declared by TEST_SUITE macro

/// \def test2(testName, fixture1name, fixture2name)
/// \brief Declare class 'testName', derived from TestCase and autogenerated fixture, derived from 'fixture1name' and 'fixture2name',
/// which have setUp and tearDown functions, calling corresponding functions from it's base classes.
/// This test case will be added into previously test suite, declared by TEST_SUITE macro

/// \def _test(testName)
/// \brief Add ignored test. It's code may be uncompiled.

/// \def _test1(testName, fixtureName)
/// \brief Add ignored test. It's code may be uncompiled.

/// \def _test2(testName, fixture1name, fixture2name)
/// \brief Add ignored test. It's code may be uncompiled.

/// \def isTrue(condition)
/// \brief Check condition for 'true' value, otherwise it throw an exception of TestException type

/// \def isFalse(condition)
/// \brief Check condition for 'false' value, otherwise it throw an exception of TestException type

/// \def areEq(expected, actual)
/// \brief Check that expected == actual, otherwise throw an exception of TestException type
/// Use areEq only for integral types, such as int, long, etc.

/// \def areNotEq(expected, actual)
/// \brief Check that expected != actual, otherwise throw an exception of TestException type
/// Use areNotEq only for integral types, such as int, long, etc.

/// \def areDoubleEq(expected, actual, delta)
/// \brief Check that expected == actual with tolerance of delta, otherwise throw an exception of
/// TestException type
/// Use areDoubleEq only for float point types, such as float, double, long double

/// \def areDoubleNotEq(expected, actual, delta)
/// \brief Check that expected != actual with tolerance of delta, otherwise throw an exception of
/// TestException type
/// Use areDoubleNotEq only for float point types, such as float, double, long double

/// \def willThrow(expression, exceptionType)
/// \brief Check that exception of exceptionType WILL BE THROWN during expression execution

/// \def noSpecificThrow(expression, exceptionType)
/// \brief Check that C++ exception of 'exceptionType' WILL NOT BE THROWN during expression execution

/// \def noAnyCppThrow(expression)
/// \brief Check that NO ANY C++ exception WILL BE THROWN during expression execution

/// \def noSehThrow(expression)
/// \brief Check that NO ANY SEH (Structed Exception Handling) exception WILL BE THROWN during expression execution

/// \fn bool protectTestThunkInvoke(Thunk thunk, char* msgBuf, const unsigned int msgBufSize)
/// \param[in] thunk Thunk, whitch function invoke() will be called
/// \param[out] msgBuf Buffer for error message
/// \param[in] msgBufSize Awailable size of buffer
/// \return true, if call of invoke() function not throw exception, else return false

/// \fn int callTestCaseThunk(lua_State *L, Thunk (*getThunkFunc)(TESTUNIT_NS::TestCase*))
/// \brief There is TestCase object on the top of Lua stack. This function call protectTestThunkInvoke
/// for that Thunk, whitch return function 'getThunkFunc'.
/// \return 0, or call lua_error in case of unsuccessful protectTestThunkInvoke

/// \fn int luaRegistryTestCases(lua_State *L)
/// \brief Return collection of objects with TestCase interface ("name_", setUp, test, tearDown).
/// Names of TestCases contains TestSuite and TestCase name, separated by '::'

#include <sstream>
#include <testunit/test.h>

std::wstring getTestWstdStr()
{
    return L"abc";
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
fixture(fixtureA)
{
    setUp()
    {
        a_ = 10;
    }
    tearDown()
    {
        a_ = 0;
    }
    int a_;
};

fixture(fixtureB)
{
    setUp()
    {
        b_ = 11;
    }
    tearDown()
    {
        b_ = 0;
    }
    int b_;
};

fixture(SetUpCallCheckFixture)
{
    setUp()
	{
		setUpCall_ = true;
	}

    tearDown()
	{
		setUpCall_ = false;
	}

	bool setUpCall_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
test(test1)
{
    isTrue(true);
    isFalse(false);
}

test1(test2, fixtureA)
{
    areEq(10, a_); 
}

test2(test3, fixtureA, fixtureB)
{
    areEq(10, a_); 
    areEq(11, b_); 
}

_test(test4)
{
    // ignored test case
    int uncompiledCode[0] = {1};
}

_test1(test5, fixtureA)
{
    // ignored test case
    int uncompiledCode[0] = {1};
}

_test2(test6, fixtureA, fixtureB)
{
    // ignored test case
    int uncompiledCode[0] = {1};
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// test macro multiple using in one t.cpp file

test(test1bis)
{
    isTrue(true);
    isFalse(false);
}

test1(test2bis, fixtureA)
{
    areEq(10, a_); 
}

test2(test3bis, fixtureA, fixtureB)
{
    areEq(10, a_); 
    areEq(11, b_); 
}

_test(test4bis)
{
    // ignored test case
    int uncompiledCode[0] = {1};
}

_test1(test5bis, fixtureA)
{
    // ignored test case
    int uncompiledCode[0] = {1};
}

_test2(test6bis, fixtureA, fixtureB)
{
    // ignored test case
    int uncompiledCode[0] = {1};
}

test(testBoolAssert)
{
	isTrue(true);
	isTrue(!false);

	isTrue(1);
	isTrue(!0);

	isTrue(0 == 0);
	isTrue(0 >= 0);
	isTrue(0 <= 0);
	isTrue(0 <= 1);
	isTrue(1 > 0);
	isTrue(-1 < 0);

	isTrue(1 == 1);
	isTrue(1 != 2);
	isTrue(1 < 2);
	isTrue(1 <= 1);
	isTrue(1 <= 2);

	isTrue(-1 == -1);
	isTrue(1 != -1);
}

test(testBoolAssertNot)
{
	isFalse(false);
	isFalse(!true);

	isFalse(0);
	isFalse(!1);

	isFalse(0 != 0);
	isFalse(1 < 0);
	isFalse(-1 > 0);
	isFalse(0 > 1);
	isFalse(0 < -1);

	isFalse(1 != 1);
	isFalse(1 == 2);
	isFalse(1 > 2);

	isFalse(-1 != -1);
	isFalse(1 == -1);
	isFalse(-1 == 1);
}

test(testAssertEqual)
{
	areEq((unsigned int)1, (unsigned int)1);
	areEq((unsigned int)0, (unsigned int)0);

	areEq((int)1, (int)1);
	areEq((int)0, (int)0);
    areEq((int)-1, (int)-1);
}

test(testAssertEqualWithTypedefs)
{
    typedef unsigned int uint_max_t;
    areEq((uint_max_t)1, (uint_max_t)1);
    areEq((uint_max_t)0, (uint_max_t)0);
    typedef int int_max_t;
    areEq((int_max_t)1, (int_max_t)1);
    areEq((int_max_t)0, (int_max_t)0);
    areEq((int_max_t)-1, (int_max_t)-1);
}

test(testAssertEqualNot)
{
	areNotEq(1, 0);
	areNotEq(0, 1);
	areNotEq(1, 2);
	areNotEq(2, 1);
	areNotEq(-1, 0);
	areNotEq(0, -1);
	areNotEq(-1, 1);
	areNotEq(1, -1);
}

test(testDoubleEqualAssertForFloats)
{
	areDoubleEq(1.0f, 1.0f, 0.0f);
	areDoubleEq(0.0f, 0.0f, 0.0f);
	areDoubleEq(-1.0f, -1.0f, 0.0f);

	areDoubleEq(1.1f, 1.2f, 0.1f);
	areDoubleEq(-1.1f, -1.2f, 0.1f);
}

test(testDoubleEqualAssertForDoubles)
{
	areDoubleEq(1.1, 1.2, 0.1);
	areDoubleEq(-1.1, -1.2, 0.1);

	areDoubleEq(1.0, 1.0, 0.1);
	areDoubleEq(1.0, 1.0, 0.5);
	areDoubleEq(-1.0, -1.0, 0.1);
	areDoubleEq(-1.0, -1.0, 0.5);

	areDoubleEq(1.0, 1.0, -0.1);
	areDoubleEq(1.0, 1.0, -0.5);
	areDoubleEq(-1.0, -1.0, 0.1);
	areDoubleEq(-1.0, -1.0, 0.5);
}

test(testDoubleEqualAssertNotForFloats)
{
	areDoubleNotEq(1.0f, 0.0f, 0.0f);
	areDoubleNotEq(0.0f, 1.0f, 0.0f);
	areDoubleNotEq(-1.0f, 0.0f, 0.0f);
	areDoubleNotEq(0.0f, -1.0f, 0.0f);
	areDoubleNotEq(-1.0f, 1.0f, 0.0f);
	areDoubleNotEq(1.0f, -1.0f, 0.0f);

	areDoubleNotEq(1.0f, 0.0f, 0.5f);
	areDoubleNotEq(0.0f, 1.0f, 0.5f);
	areDoubleNotEq(-1.0f, 0.0f, 0.5f);
	areDoubleNotEq(0.0f, -1.0f, 0.5f);
	areDoubleNotEq(-1.0f, 1.0f, 0.5f);
	areDoubleNotEq(1.0f, -1.0f, 0.5f);
}

test(testDoubleEqualAssertNotForDoubles)
{
	areDoubleNotEq(1.0, 0.0, 0.0);
	areDoubleNotEq(0.0, 1.0, 0.0);
	areDoubleNotEq(-1.0, 0.0, 0.0);
	areDoubleNotEq(0.0, -1.0, 0.0);
	areDoubleNotEq(-1.0, 1.0, 0.0);
	areDoubleNotEq(1.0, -1.0, 0.0);

	areDoubleNotEq(1.0, 0.0, 0.5);
	areDoubleNotEq(0.0, 1.0, 0.5);
	areDoubleNotEq(-1.0, 0.0, 0.5);
	areDoubleNotEq(0.0, -1.0, 0.5);
	areDoubleNotEq(-1.0, 1.0, 0.5);
	areDoubleNotEq(1.0, -1.0, 0.5);
}

test1(testCheckSetUpCall, SetUpCallCheckFixture)
{
	isTrue(setUpCall_);
}

test(testSourceLineCreation)
{
	TESTUNIT_SOURCELINE();
	TESTUNIT_NS::SourceLine sourceLine(__FILE__, __LINE__);
}

test(assertEqualStringsTest)
{
	areEq( "",  "");
	areEq(L"", L"");
	areEq(std::string(""), std::string(""));
	areEq(std::wstring(L""), std::wstring(L""));

	areNotEq( "a",  "");
	areNotEq(L"a", L"");
	areNotEq(std::string("a"), std::string(""));
	areNotEq(std::wstring(L"a"), std::wstring(L""));

	areEq( "\n",  "\n");
	areEq(L"\n", L"\n");
	areEq(std::string("\n"), std::string("\n"));
	areEq(std::wstring(L"\n"), std::wstring(L"\n"));
}

test(assertEqualWideCharConstStringsAnsStlStringsTest)
{
    std::wstring expected = L"abc";
	areEq(expected, L"abc");
	areEq(L"abc", expected);
    areEq(expected, expected);

    areEq(expected, getTestWstdStr());
    areEq(expected, getTestWstdStr().c_str());
    areEq(getTestWstdStr(), expected);

    areEq(L"abc", getTestWstdStr());
    areEq(getTestWstdStr(), L"abc");

    areEq(L"abc", getTestWstdStr().c_str());

    expected = L"10";
    std::wstringstream ss;
    ss << 10;
    areEq(L"10", ss.str());
    areEq(ss.str(), L"10");
    areEq(ss.str(), ss.str());

    areEq(expected.data(), ss.str());
    areEq(ss.str(), expected.data());
    areEq(expected.data(), expected.data());
}

test(assertEqualMultiByteCharConstStringsAnsStlStringsTest)
{
    std::string expectedStlStr = "abc";
	areEq(expectedStlStr, "abc");
	areEq("abc", expectedStlStr);
    areEq(expectedStlStr, expectedStlStr);
    areEq(expectedStlStr.data(), expectedStlStr.data());
    areEq(expectedStlStr.c_str(), expectedStlStr.c_str());

    const char* expectedStr = "abc";
    areEq(expectedStr, "abc");
    areEq("abc", expectedStr);
    areEq(expectedStr, expectedStr);
}

test(assertEqualStringCompareCrash)
{
    areNotEq(L"", reinterpret_cast<const wchar_t*>(NULL));
    areNotEq("", reinterpret_cast<const char*>(NULL));
}

test(exceptionDerivedFromStdException)
{
    try
    {
        isTrue(false);
    }
    catch(std::exception& ex)
    {
        areEq("Unknown exception", ex.what());
        return; // succesfull test execution
    }
    catch(...)
    {
        bool testMustReturnAtCatchBlockAndDontExecuteThis = false;
        isTrue(testMustReturnAtCatchBlockAndDontExecuteThis);
    }
}

test(singleWillThrowTest)
{
    willThrow(isTrue(false), TESTUNIT_NS::TestException);
}

test(checkForUnreachableCodeWarningWhenUseWillThrow)
{
    class Exception {};
    struct ThrowException
    {
        static void foo()
        {
            throw Exception();
        }
    };

    willThrow(ThrowException::foo(), Exception);
    willThrow(ThrowException::foo(), Exception);
}
