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

/// \def TEST_SUITE(testSuiteName)
/// \brief Declare concrete class 'testSuiteName', derived from TestSuite

/// \def TEST_CASE(testName)
/// \brief Declare class 'testName', derived from TestCase. This test case will be added into previously test suite,
/// declared by TEST_SUITE macro

/// \def TEST_CASE_ALONE(testName)
/// \brief Declare class 'testName', derived from TestCase. This test case will be added into default test suite,
/// you need not use TEST_SUITE macro before TEST_CASE_ALONE

/// \def TEST_CASE_EX(testName, fixtureName)
/// \brief Declare class 'testName', derived from TestCase and 'fixtureName', i.e. it will have setUp and tearDown functions.
/// This test case will be added into previously test suite, declared by TEST_SUITE macro

/// \def TEST_CASE_EX_ALONE(testName, fixtureName)
/// \brief Declare class 'testName', derived from TestCase and 'fixtureName'. This test case will be added into default test suite,
/// you need not use TEST_SUITE macro before TEST_CASE_ALONE

/// \def TEST_CASE_END
/// \brief Close test case, begun with TEST_CASE or TEST_CASE_EX

/// \def TEST_CASE_ALONE_END
/// \brief Close test case, begun with TEST_CASE_ALONE or TEST_CASE_EX_ALONE

/// \def IGNORE_TEST_CASE(testName)
/// \brief Add ignored test. It's code may be uncompiled.

/// \def IGNORE_TEST_CASE_ALONE(testName)
/// \brief Add ignored test. It's code may be uncompiled.

/// \def IGNORE_TEST_CASE_EX(testName, fixtureName)
/// \brief Add ignored test. It's code may be uncompiled.

/// \def IGNORE_TEST_CASE_EX_ALONE(testName, fixtureName)
/// \brief Add ignored test. It's code may be uncompiled.

/// \def ASSERT(condition)
/// \brief Check condition for 'true' value, otherwise it throw an exception of TestException type

/// \def ASSERT_NOT(condition)
/// \brief Check condition for 'false' value, otherwise it throw an exception of TestException type

/// \def ASSERT_EQUAL(expected, actual)
/// \brief Check that expected == actual, otherwise throw an exception of TestException type
/// Use ASSERT_EQUAL only for integral types, such as int, long, etc.

/// \def ASSERT_NOT_EQUAL(expected, actual)
/// \brief Check that expected != actual, otherwise throw an exception of TestException type
/// Use ASSERT_EQUAL only for integral types, such as int, long, etc.

/// \def ASSERT_DOUBLES_EQUAL(expected, actual, delta)
/// \brief Check that expected == actual with tolerance of delta, otherwise throw an exception of
/// TestException type
/// Use ASSERT_DOUBLES_EQUAL only for float point types, such as float, double, long double

/// \def ASSERT_DOUBLES_NOT_EQUAL(expected, actual, delta)
/// \brief Check that expected != actual with tolerance of delta, otherwise throw an exception of
/// TestException type
/// Use ASSERT_DOUBLES_EQUAL only for float point types, such as float, double, long double

/// \def ASSERT_THROW(expression, exceptionType)
/// \brief Check that exception of exceptionType WILL BE THROWN during expression execution

/// \def ASSERT_NO_CPP_EXCEPTION(expression, exceptionType)
/// \brief Check that C++ exception of 'exceptionType' WILL NOT BE THROWN during expression execution

/// \def ASSERT_NO_ANY_CPP_EXCEPTION(expression)
/// \brief Check that NO ANY C++ exception WILL BE THROWN during expression execution

/// \def ASSERT_NO_SEH_THROW(expression)
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

#include "test.h"

#ifdef OLD_SYNTAX
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
TEST_FIXTURE(EmptyFixture)
{
};

TEST_SUITE(EmptyTestSuite)
{
};

TEST_FIXTURE(SetUpCallCheck)
{
    SETUP
	{
		setUpCall_ = true;
	}

    TEARDOWN
	{
		setUpCall_ = false;
	}

	bool setUpCall_;
};

std::wstring getTestWstdStr()
{
    return L"abc";
}

TEST_SUITE(CppUnitAssertsTests)
{
	TEST_CASE(testBoolAssert)
		ASSERT(true);
		ASSERT(!false);

		ASSERT(1);
		ASSERT(!0);

		ASSERT(0 == 0);
		ASSERT(0 >= 0);
		ASSERT(0 <= 0);
		ASSERT(0 <= 1);
		ASSERT(1 > 0);
		ASSERT(-1 < 0);

		ASSERT(1 == 1);
		ASSERT(1 != 2);
		ASSERT(1 < 2);
		ASSERT(1 <= 1);
		ASSERT(1 <= 2);

		ASSERT(-1 == -1);
		ASSERT(1 != -1);
	TEST_CASE_END

	TEST_CASE(testMustBeFailed)
        ASSERT_THROW(ASSERT(false), TESTUNIT_NS::TestException);
	TEST_CASE_END

    TEST_CASE(testBoolAssertNot)
		ASSERT_NOT(false);
		ASSERT_NOT(!true);

		ASSERT_NOT(0);
		ASSERT_NOT(!1);

		ASSERT_NOT(0 != 0);
		ASSERT_NOT(1 < 0);
		ASSERT_NOT(-1 > 0);
		ASSERT_NOT(0 > 1);
		ASSERT_NOT(0 < -1);

		ASSERT_NOT(1 != 1);
		ASSERT_NOT(1 == 2);
		ASSERT_NOT(1 > 2);

		ASSERT_NOT(-1 != -1);
		ASSERT_NOT(1 == -1);
		ASSERT_NOT(-1 == 1);
	TEST_CASE_END

	TEST_CASE(testAssertEqual)
		ASSERT_EQUAL((unsigned int)1, (unsigned int)1);
		ASSERT_EQUAL((unsigned int)0, (unsigned int)0);

		ASSERT_EQUAL((int)1, (int)1);
		ASSERT_EQUAL((int)0, (int)0);
        ASSERT_EQUAL((int)-1, (int)-1);
	TEST_CASE_END

	TEST_CASE(testAssertEqualWithTypedefs)
            typedef unsigned int uint_max_t;
            ASSERT_EQUAL((uint_max_t)1, (uint_max_t)1);
            ASSERT_EQUAL((uint_max_t)0, (uint_max_t)0);
            typedef int int_max_t;
            ASSERT_EQUAL((int_max_t)1, (int_max_t)1);
            ASSERT_EQUAL((int_max_t)0, (int_max_t)0);
            ASSERT_EQUAL((int_max_t)-1, (int_max_t)-1);
        TEST_CASE_END

	TEST_CASE(testAssertEqualNot)
		ASSERT_NOT_EQUAL(1, 0);
		ASSERT_NOT_EQUAL(0, 1);
		ASSERT_NOT_EQUAL(1, 2);
		ASSERT_NOT_EQUAL(2, 1);
		ASSERT_NOT_EQUAL(-1, 0);
		ASSERT_NOT_EQUAL(0, -1);
		ASSERT_NOT_EQUAL(-1, 1);
		ASSERT_NOT_EQUAL(1, -1);
	TEST_CASE_END

	TEST_CASE(testDoubleEqualAssertForFloats)
		ASSERT_DOUBLES_EQUAL(1.0f, 1.0f, 0.0f);
		ASSERT_DOUBLES_EQUAL(0.0f, 0.0f, 0.0f);
		ASSERT_DOUBLES_EQUAL(-1.0f, -1.0f, 0.0f);

		ASSERT_DOUBLES_EQUAL(1.1f, 1.2f, 0.1f);
		ASSERT_DOUBLES_EQUAL(-1.1f, -1.2f, 0.1f);
	TEST_CASE_END

	TEST_CASE(testDoubleEqualAssertForDoubles)
		ASSERT_DOUBLES_EQUAL(1.1, 1.2, 0.1);
		ASSERT_DOUBLES_EQUAL(-1.1, -1.2, 0.1);

		ASSERT_DOUBLES_EQUAL(1.0, 1.0, 0.1);
		ASSERT_DOUBLES_EQUAL(1.0, 1.0, 0.5);
		ASSERT_DOUBLES_EQUAL(-1.0, -1.0, 0.1);
		ASSERT_DOUBLES_EQUAL(-1.0, -1.0, 0.5);

		ASSERT_DOUBLES_EQUAL(1.0, 1.0, -0.1);
		ASSERT_DOUBLES_EQUAL(1.0, 1.0, -0.5);
		ASSERT_DOUBLES_EQUAL(-1.0, -1.0, 0.1);
		ASSERT_DOUBLES_EQUAL(-1.0, -1.0, 0.5);
	TEST_CASE_END

	TEST_CASE(testDoubleEqualAssertNotForFloats)
		ASSERT_DOUBLES_NOT_EQUAL(1.0f, 0.0f, 0.0f);
		ASSERT_DOUBLES_NOT_EQUAL(0.0f, 1.0f, 0.0f);
		ASSERT_DOUBLES_NOT_EQUAL(-1.0f, 0.0f, 0.0f);
		ASSERT_DOUBLES_NOT_EQUAL(0.0f, -1.0f, 0.0f);
		ASSERT_DOUBLES_NOT_EQUAL(-1.0f, 1.0f, 0.0f);
		ASSERT_DOUBLES_NOT_EQUAL(1.0f, -1.0f, 0.0f);

		ASSERT_DOUBLES_NOT_EQUAL(1.0f, 0.0f, 0.5f);
		ASSERT_DOUBLES_NOT_EQUAL(0.0f, 1.0f, 0.5f);
		ASSERT_DOUBLES_NOT_EQUAL(-1.0f, 0.0f, 0.5f);
		ASSERT_DOUBLES_NOT_EQUAL(0.0f, -1.0f, 0.5f);
		ASSERT_DOUBLES_NOT_EQUAL(-1.0f, 1.0f, 0.5f);
		ASSERT_DOUBLES_NOT_EQUAL(1.0f, -1.0f, 0.5f);
	TEST_CASE_END

	TEST_CASE(testDoubleEqualAssertNotForDoubles)
		ASSERT_DOUBLES_NOT_EQUAL(1.0, 0.0, 0.0);
		ASSERT_DOUBLES_NOT_EQUAL(0.0, 1.0, 0.0);
		ASSERT_DOUBLES_NOT_EQUAL(-1.0, 0.0, 0.0);
		ASSERT_DOUBLES_NOT_EQUAL(0.0, -1.0, 0.0);
		ASSERT_DOUBLES_NOT_EQUAL(-1.0, 1.0, 0.0);
		ASSERT_DOUBLES_NOT_EQUAL(1.0, -1.0, 0.0);

		ASSERT_DOUBLES_NOT_EQUAL(1.0, 0.0, 0.5);
		ASSERT_DOUBLES_NOT_EQUAL(0.0, 1.0, 0.5);
		ASSERT_DOUBLES_NOT_EQUAL(-1.0, 0.0, 0.5);
		ASSERT_DOUBLES_NOT_EQUAL(0.0, -1.0, 0.5);
		ASSERT_DOUBLES_NOT_EQUAL(-1.0, 1.0, 0.5);
		ASSERT_DOUBLES_NOT_EQUAL(1.0, -1.0, 0.5);
	TEST_CASE_END

	TEST_CASE_EX(testCheckSetUpCall, SetUpCallCheck)
		ASSERT(setUpCall_);
	TEST_CASE_END

	TEST_CASE(testSourceLineCreation)
		TESTUNIT_SOURCELINE();
		TESTUNIT_NS::SourceLine sourceLine(__FILE__, __LINE__);
	TEST_CASE_END

	TEST_CASE(assertEqualStringsTest)
		ASSERT_EQUAL( "",  "");
		ASSERT_EQUAL(L"", L"");
		ASSERT_EQUAL(std::string(""), std::string(""));
		ASSERT_EQUAL(std::wstring(L""), std::wstring(L""));

		ASSERT_NOT_EQUAL( "a",  "");
		ASSERT_NOT_EQUAL(L"a", L"");
		ASSERT_NOT_EQUAL(std::string("a"), std::string(""));
		ASSERT_NOT_EQUAL(std::wstring(L"a"), std::wstring(L""));

		ASSERT_EQUAL( "\n",  "\n");
		ASSERT_EQUAL(L"\n", L"\n");
		ASSERT_EQUAL(std::string("\n"), std::string("\n"));
		ASSERT_EQUAL(std::wstring(L"\n"), std::wstring(L"\n"));
    TEST_CASE_END

	TEST_CASE(assertEqualWideCharConstStringsAnsStlStringsTest)
        std::wstring expected = L"abc";
		ASSERT_EQUAL(expected, L"abc");
		ASSERT_EQUAL(L"abc", expected);
        ASSERT_EQUAL(expected, expected);

        ASSERT_EQUAL(expected, getTestWstdStr());
        ASSERT_EQUAL(expected, getTestWstdStr().c_str());
        ASSERT_EQUAL(getTestWstdStr(), expected);

        ASSERT_EQUAL(L"abc", getTestWstdStr());
        ASSERT_EQUAL(getTestWstdStr(), L"abc");

        ASSERT_EQUAL(L"abc", getTestWstdStr().c_str());

        expected = L"10";
        std::wstringstream ss;
        ss << 10;
        ASSERT_EQUAL(L"10", ss.str());
        ASSERT_EQUAL(ss.str(), L"10");
        ASSERT_EQUAL(ss.str(), ss.str());

        ASSERT_EQUAL(expected.data(), ss.str());
        ASSERT_EQUAL(ss.str(), expected.data());
        ASSERT_EQUAL(expected.data(), expected.data());
    TEST_CASE_END

	TEST_CASE(assertEqualMultiByteCharConstStringsAnsStlStringsTest)
        std::string expectedStlStr = "abc";
		ASSERT_EQUAL(expectedStlStr, "abc");
		ASSERT_EQUAL("abc", expectedStlStr);
        ASSERT_EQUAL(expectedStlStr, expectedStlStr);
        ASSERT_EQUAL(expectedStlStr.data(), expectedStlStr.data());
        ASSERT_EQUAL(expectedStlStr.c_str(), expectedStlStr.c_str());

        const char* expectedStr = "abc";
        ASSERT_EQUAL(expectedStr, "abc");
        ASSERT_EQUAL("abc", expectedStr);
        ASSERT_EQUAL(expectedStr, expectedStr);
    TEST_CASE_END

	TEST_CASE(assertEqualStringCompareCrash)
        ASSERT_NOT_EQUAL(L"", reinterpret_cast<const wchar_t*>(NULL));
        ASSERT_NOT_EQUAL("", reinterpret_cast<const char*>(NULL));
    TEST_CASE_END
};

TEST_CASE_ALONE(standaloneTestCase)
    ASSERT(true);
TEST_CASE_END

TEST_CASE_EX_ALONE(standaloneTestCaseWithSetUpAndTeardown, SetUpCallCheck)
    ASSERT(setUpCall_);
TEST_CASE_END

TEST_SUITE(CppUnitTestEngine)
{
	TEST_CASE(exceptionDerivedFromStdException)
        try
        {
            ASSERT(false);
        }
        catch(std::exception& ex)
        {
            ASSERT_EQUAL("Unknown exception", ex.what());
            return; // succesfull test execution
        }
        catch(...)
        {
            bool testMustReturnAtCatchBlockAndDontExecuteThis = false;
            ASSERT(testMustReturnAtCatchBlockAndDontExecuteThis);
        }
	TEST_CASE_END
};

TEST_SUITE(IgnoreTestCases)
{
    IGNORE_TEST_CASE(ignoredButCompiledTest)
        ASSERT(false);
	TEST_CASE_END

	IGNORE_TEST_CASE(ignoredAndNotCompiledTest)
        int emptyArrayNotAllowed[0];// error C2466: cannot allocate an array of constant size 0
	TEST_CASE_END

	IGNORE_TEST_CASE_EX(ignoredButCompiledTestWithFixture, SetUpCallCheck)
    	ASSERT_MESSAGE("Attention! This script must be INGNORED, but process must not crash");
	TEST_CASE_END

    IGNORE_TEST_CASE_EX(ignoredAndNotCompiledTestWithFixture, SetUpCallCheck)
        int emptyArrayNotAllowed[0];// error C2466: cannot allocate an array of constant size 0
	TEST_CASE_END
};

IGNORE_TEST_CASE_ALONE(standaloneAndIgnoredButCompiledTest)
    ASSERT(true);
TEST_CASE_END

IGNORE_TEST_CASE_ALONE(standaloneAndIgnoredAndNotCompiledTest)
    unsigned int emptyArrayNotAllowed[0];
TEST_CASE_END

IGNORE_TEST_CASE_EX_ALONE(standaloneAndIgnoredButCompiledTestWithFixture, SetUpCallCheck)
    ASSERT(true);
TEST_CASE_END

IGNORE_TEST_CASE_EX_ALONE(standaloneAndIgnoredAndNotCompiledTestWithFixture, SetUpCallCheck)
    int emptyArrayNotAllowed[0];// error C2466: cannot allocate an array of constant size 0
TEST_CASE_END

#else // i.e. not defined OLD_SYNTAX
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// some_test.t.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#include <testunit/test.h>

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

#endif // OLD_SYNTAX