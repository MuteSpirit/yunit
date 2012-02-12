//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// cppunit.t.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <sstream>
#include <fstream>

#include "cppunit.h"

#ifdef WIN32
#  include <process.h>
#  include <windows.h>
#endif

#ifndef WIN32
#  include <float.h>
#endif


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
test(Test1)
{
    isTrue(true);
    isFalse(false);
}

// fixtureA::setUp() will be called before testB and fixtureA::tearDown() - after.
test1(Test2, fixtureA)
{
    areEq(10, a_); 
}

// fixtureA::setUp() and fixtureB::setUp() will be executed before testC
// fixtureB::tearDown() and fixtureA::tearDown() will be executed after testC
test2(Test3, fixtureA, fixtureB)
{
    areEq(10, a_); 
    areEq(11, b_); 
}
#ifdef _MSC_VER
// ignored test case (may have uncompiled code in body)
_test(Test4)
{
    int uncompiledCode[0] = {1};
}

// ignored test case (may have uncompiled code in body)
_test1(Test5, fixtureA)
{
    int uncompiledCode[0] = {1};
}

// ignored test case (may have uncompiled code in body)
_test2(Test6, fixtureA, fixtureB)

{
    int uncompiledCode[0] = {1};
}
#endif
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// test macro multiple using in one t.cpp file

test(Test1bis)
{
    isTrue(true);
    isFalse(false);
}

test1(Test2bis, fixtureA)
{
    areEq(10, a_); 
}

test2(Test3bis, fixtureA, fixtureB)
{
    areEq(10, a_); 
    areEq(11, b_); 
}
#ifdef _MSC_VER
_test(Test4bis)
{
    // ignored test case
    int uncompiledCode[0] = {1};
}

_test1(Test5bis, fixtureA)
{
    // ignored test case
    int uncompiledCode[0] = {1};
}

_test2(Test6bis, fixtureA, fixtureB)
{
    // ignored test case
    int uncompiledCode[0] = {1};
}
#endif

test(IsNullAssert)
{
    void* p = NULL;
    isNull(p);
    willThrow(isNull(1), YUNIT_NS::TestException);
}

test(isNotNullAssert)
{
    static void* pointer = &pointer;
    isNotNull(pointer);

    willThrow(isNotNull(NULL), YUNIT_NS::TestException);
}

test(TestBoolAssert)
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

test(TestBoolAssertNot)
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

test(TestAssertEqual)
{
	areEq(1, 1);

	areEq(1, (int)1);
    areEq(-1, (int)-1);

	areEq((unsigned int)1, (int)1);
    areEq(-1, (int)-1);

    areEq((unsigned int)1, (unsigned int)1);

	areEq((int)1, (int)1);
    areEq((int)-1, (int)-1);
}

test(TestAssertEqualWithTypedefs)
{
    typedef unsigned int uint_max_t;
    areEq((uint_max_t)1, (uint_max_t)1);
    areNotEq((uint_max_t)1, (uint_max_t)0);
    typedef int int_max_t;
    areEq((int_max_t)1, (int_max_t)1);
    areEq((int_max_t)-1, (int_max_t)-1);
}

test(TestAssertEqualNot)
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

test(TestDoubleEqualAssertForFloats)
{
	areDoubleEq(1.0f, 1.0f, 0.0f);
	areDoubleEq(0.0f, 0.0f, 0.0f);
	areDoubleEq(-1.0f, -1.0f, 0.0f);

	areDoubleEq(1.1f, 1.2f, 0.1f);
	areDoubleEq(-1.1f, -1.2f, 0.1f);
}

test(TestDoubleEqualAssertForDoubles)
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

test(TestDoubleEqualAssertNotForFloats)
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

test(TestDoubleEqualAssertNotForDoubles)
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

test(equationLongDoubleVariables)
{
    areDoubleEq((long double)0.1, (long double)0.1, LDBL_EPSILON);
    areDoubleEq((long double)0.0, (long double)0.0, LDBL_EPSILON);
    areDoubleEq((long double)-0.1, (long double)-0.1, LDBL_EPSILON);
    areDoubleEq((long double)0.000000000000001, (long double)0.000000000000001, LDBL_EPSILON);
}

test1(testCheckSetUpCall, SetUpCallCheckFixture)
{
	isTrue(setUpCall_);
}

test(TestSourceLineCreation)
{
	YUNIT_SOURCELINE();
	YUNIT_NS::SourceLine sourceLine(__FILE__, __LINE__);
}

test(AssertEqualStringsTest)
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

test(AssertEqualWideCharConstStringsAnsStlStringsTest)
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

test(AssertEqualMultiByteCharConstStringsAnsStlStringsTest)
{
    std::string expectedStlStr = "abc";
    std::string expectedStlStr2 = expectedStlStr;
	areEq(expectedStlStr, "abc");
	areEq("abc", expectedStlStr);
    areEq(expectedStlStr, expectedStlStr);
    areEq(expectedStlStr, expectedStlStr2);
    areEq(expectedStlStr.data(), expectedStlStr.data());
    areEq(expectedStlStr.c_str(), expectedStlStr.c_str());

    const char* expectedStr = "abc";
    areEq(expectedStr, "abc");
    areEq("abc", expectedStr);
    areEq(expectedStr, expectedStr);
}

test(AssertEqualStringCompareCrash)
{
    areNotEq(L"", reinterpret_cast<const wchar_t*>(NULL));
    areNotEq("", reinterpret_cast<const char*>(NULL));
}

test(ExceptionDerivedFromStdException)
{
    try
    {
        isTrue(false);
    }
    catch(std::exception& ex)
    {
        areEq("Unknown TestException", ex.what());
        return; // succesfull test execution
    }
    catch(...)
    {
        bool testMustReturnAtCatchBlockAndDontExecuteThis = false;
        isTrue(testMustReturnAtCatchBlockAndDontExecuteThis);
    }
}

test(SingleWillThrowTest)
{
    willThrow(isTrue(false), YUNIT_NS::TestException);
}

test(CheckForUnreachableCodeWarningWhenUseWillThrow)
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

test(CompareConstAndNonConstCharPointer)
{
    char a[] = "abc";
    char b[] = "abcd";

    areNotEq("ab", "abc");
    areEq(a, "abc");
    areEq("abc", a);
    areNotEq(a, b);
}

test(CompareConstAndNonConstWcharPointer)
{
    wchar_t a[] = L"abc";
    wchar_t b[] = L"abcd";

    areNotEq(L"ab", L"abc");
    areEq(a, L"abc");
    areEq(L"abc", a);
    areNotEq(a, b);
}

#ifdef WIN32
test(TestSetGoodWorkingDir)
{
#ifdef WIN32
    std::wifstream f(L".\\yunit.t.dll", std::ios::in | std::ios::binary);
#else
    std::ifstream f(".\\yunit.t.so", std::ifstream::in | std::ifstream::binary);
#endif
    bool exist = f.good();
    if (exist)
        f.close();
    isTrue(exist);
}
#endif

test(WrongMessageTextWhere)
{
    try
    {
        areEq(1, 10);
    }
    catch(YUNIT_NS::TestException& ex)
    {
        enum {bufferSize = 128};
        char buffer[bufferSize];
        ex.message(buffer, bufferSize);
        areEq("1 != 10", buffer);
    }
}

test(CharStringMustBeBoundedWithDoubleQuotesAtFailedEquationMessage)
{
    try
    {
        areEq("s1", "s2");
    }
    catch(YUNIT_NS::TestException& ex)
    {
        enum {bufferSize = 128};
        char buffer[bufferSize];
        ex.message(buffer, bufferSize);
        areEq("\"s1\" != \"s2\"", buffer);
    }

    try
    {
        areNotEq("s1", "s2");
    }
    catch(YUNIT_NS::TestException& ex)
    {
        enum {bufferSize = 128};
        char buffer[bufferSize];
        ex.message(buffer, bufferSize);
        areEq("\"s1\" == \"s2\"", buffer);
    }
}

test(WideCharStringMustBeBoundedWithDoubleQuotesAtFailedEquationMessage)
{
    try
    {
        areEq(L"s1", L"s2");
    }
    catch(YUNIT_NS::TestException& ex)
    {
        enum {bufferSize = 128};
        char buffer[bufferSize];
        ex.message(buffer, bufferSize);
        areEq("\"s1\" != \"s2\"", buffer);
    }

    try
    {
        areNotEq(L"s1", L"s2");
    }
    catch(YUNIT_NS::TestException& ex)
    {
        enum {bufferSize = 128};
        char buffer[bufferSize];
        ex.message(buffer, bufferSize);
        areEq("\"s1\" == \"s2\"", buffer);
    }
}

test(ComparePointers)
{
	int value, other;
	void* p = &value;
	areEq(&value, p);
	areNotEq(&value, &other);

	areNotEq(&value, NULL);
	areNotEq(NULL, &value);
}

example(ExampleWhichIsCompiledButNotRun)
{
	int a = 0;
	int b = 10 / a;
	(void)b;
}

/* Sample TODO test
todo(ForFutureCreation)
{
}
*/

test(simple_list_use_case)
{
    using namespace YUNIT_NS;
    
    Chain<int> chain;
    chain << 1 << 2;

    areEq(2, chain.size());

    Chain<int>::ReverseIterator it = chain.rbegin(), endIt = chain.rend();
    areEq(2, *it);
    areEq(1, *(++it));
    isTrue(++it == endIt);

    chain.clear();
}

test(check_willThrow_macro_error_message)
{
    try
    {
        willThrow(int a = 10, int);
    }
    catch (YUNIT_NS::TestException& ex)
    {
        enum {bufferSize = 256};
        char buffer[bufferSize];
        ex.message(buffer, bufferSize);
        areEq("Expected exception \"int\" has not been thrown", buffer);
    }
}

test(check_noSpecificError_macro_error_message)
{
    try
    {
        noSpecificThrow(throw (int)0, int);
    }
    catch (YUNIT_NS::TestException& ex)
    {
        enum {bufferSize = 256};
        char buffer[bufferSize];
        ex.message(buffer, bufferSize);
        areEq("Not expected exception \"int\" has been thrown", buffer);
    }
}