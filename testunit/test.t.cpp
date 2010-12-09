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

/// \class IgnoreTestCaseGuard
/// \brief Say 'testSuite', reaching as argument, that next added test cases must be marked as ignored

/// \class NotIgnoreTestCaseGuard
/// \brief Say 'testSuite', reaching as argument, that next added test cases must not be disabled

/// \def TESTUNIT_SOURCELINE()
/// \brief Create temporary object of SourceLine type. Need for saving file name and line of assert crash

/// \def TEST_SUITE(testSuiteName)
/// \brief Declare concrete class 'testSuiteName', derived from TestSuite

/// \def IGNORE_TEST
/// \brief Mark next test case as 'ignored', and it will not be executed during run tests

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

#include "test.h"

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

    IGNORE_TEST
	TEST_CASE(testMustBeIgnored)
    	//ASSERT_MESSAGE("Attention! This script must be INGNORED, but process must not crash");
        ASSERT(false);
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

        typedef unsigned __int32 uint_max_t;
		ASSERT_EQUAL((uint_max_t)1, (uint_max_t)1);
		ASSERT_EQUAL((uint_max_t)0, (uint_max_t)0);

        typedef int int_max_t;
		ASSERT_EQUAL((int_max_t)1, (int_max_t)1);
		ASSERT_EQUAL((int_max_t)0, (int_max_t)0);
        ASSERT_EQUAL((int_max_t)-1, (int_max_t)-1);

        typedef __int32 int_max_t;
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
};

TEST_CASE_ALONE(standaloneTestCase)
    ASSERT(true);
TEST_CASE_ALONE_END

TEST_CASE_EX_ALONE(standaloneTestCaseWithSetUpAndTeardown, SetUpCallCheck)
    ASSERT(setUpCall_);
TEST_CASE_ALONE_END
