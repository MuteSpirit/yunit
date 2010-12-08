//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// test.t.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// \class Test
/// \brief Interface class for all test classes

/// \class Fixture
/// \brief Interface class for tests, which are using some resources and their initialization and release are moved to
/// separate functions, whitch must be correct called before and after test excution correspondingly

/// \class TestCase
/// \brief Interface class for run single test function. We will use this class as fundamental

/// \class TestSuite
/// \brief Class, containing several TestCase objects. It can't run them, it is only container with name.
/// There is no polymorphism.

/// \class TestRegistry
/// \brief Singleton. Contain all C++ TestSuites.

/// \class template<typename TestSuiteClass> class RegisterTestSuite
/// \brief Create at constructor static object of TestSuiteClass, then register it at TestRegistry

/// \class template<typename TestCaseClass> class RegisterTestCase
/// \brief Create at constructor static object of TestCaseClass, then add it to TestSuite, whitch pointer is
/// passed to constructor as second argument

/// \class SourceLine
/// \brief Save info about file and line of code situation. Used at macro with variables __FILE__, __LINE__

/// \class TestException
/// \brief User exception type for throw during checks

/// \class TestConditionException
/// \brief User exception type for throw during check of bool condition

/// \class TestEqualException
/// \brief User exception type for throw during check of equaling two integral numbers

/// \class template<typename T> class TestDoubleEqualException
/// \brief User exception type for throw during check of equaling two float-point numbers

/// \fn ASSERT(condition)
/// \brief Macro ASSERT check condition for true value, otherwise it throw an exception of
/// TestException type

/// \fn ASSERT_EQUAL(expected, actual)
/// \brief Macro ASSERT_EQUAL check that expected == actual, otherwise throw an exception of
/// TestException type
/// Use ASSERT_EQUAL only for integral types, such as int, long, etc.

/// \fn ASSERT_DOUBLES_EQUAL(expected, actual, delta)
/// \brief Macro ASSERT_EQUAL check that expected == actual with tolerance of delta, otherwise throw an exception of
/// TestException type
/// Use ASSERT_DOUBLES_EQUAL only for float point types, such as float, double, long double

/// \fn ASSERT_THROW(expression, exceptionType)
/// \brief Macro ASSERT_THROW check that exception of exceptionType WILL BE THROWN during expression
/// execution

/// \fn ASSERT_NO_THROW(expression)
/// \brief Macro ASSERT_NO_THROW check that exception of exceptionType WILL NOT BE THROWN during expression
/// execution

/// \fn TESTUNIT_MSG(message)
/// \brief Output text message

/// \fn bool protectTestThunkInvoke(Thunk thunk, char* msgBuf, const unsigned int msgBufSize)
/// \param[in] thunk Thunk, whitch function invoke() will be called
/// \param[out] msgBuf Buffer for error message
/// \param[in] msgBufSize Awailable size of buffer
/// \return true, if call of invoke() function not throw exception, else return false

/// \fn int callTestCaseThunk(lua_State *L, Thunk (*getThunkFunc)(TESTUNIT_NS::TestCase*))
/// \brief There is TestCase object on the top of Lua stack. This function call protectTestThunkInvoke
/// for that Thunk, whitch return function 'getThunkFunc'.
/// \return 0, or call lua_error in case of unsuccesfull protectTestThunkInvoke

/// \fn int luaRegistryTestCases(lua_State *L)
/// \brief Return collection of objects with TestCase interface ("name_", setUp, test, tearDown).
/// Names of TestCases contains TestSuite and TestCase name, separated by '::'

#if defined(TS_TEST)

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

    IGNORE_TEST
	TEST_CASE(testMustBeFailed)
		//ASSERT_MESSAGE("Attention! This script must be FAILED, but process must not crash");
        ASSERT(false);
	TEST_CASE_END

    IGNORE_TEST
	TEST_CASE(testMustBeIgnored)
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

#endif // defined(TS_TEST)
