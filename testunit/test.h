#ifdef _MSC_VER
#pragma once
#endif

#ifdef _MSC_VER
// Two or more members have the same name. The one in class2 is inherited because it is a base class for the
// other classes that contained this member.
// This situation with TestFixture and TestCase, inherited from it
#pragma warning(disable : 4250)
//
// warning C4251: 'afl::CppUnit::TestSuite::testCases_' : class 'std::list<_Ty>' needs to have dll-interface
// to be used by clients of class 'afl::CppUnit::TestSuite'
#pragma warning(disable : 4251)
#endif


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// test.h
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef _CPPUNIT_PORTABILITY_HEADER_
#define _CPPUNIT_PORTABILITY_HEADER_


namespace afl {

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if defined(CPPUNIT_NO_NAMESPACE)
# define CPPUNIT_NS_BEGIN
# define CPPUNIT_NS_END
# define CPPUNIT_NS
#else   // defined(CPPUNIT_NO_NAMESPACE)
#define CPPUNIT_NS_BEGIN	\
namespace afl {				\
namespace CppUnit {

#define CPPUNIT_NS_END	\
}						\
}

#define CPPUNIT_NS afl::CppUnit
#endif // defined(CPPUNIT_NO_NAMESPACE)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef TS_T
//#	ifdef UNICODE
//#		define TS_T2(x)		L ## x
//#		define char		wchar_t
//#		define TS_STRING	std::wstring
//#		define TS_STRLEN	wcslen
//#		define TS_STRCPY	wcscpy
//#		define TS_STRNCPY	wcsncpy
//#		define TS_STRCMP	wcscmp
//#		define _snprintf	_snwprintf
//#	else
#		define TS_T2(x)		x
//#		define char		char
//#		define TS_STRING	std::string
//#		define TS_STRLEN	strlen
//#		define TS_STRCPY	strcpy
//#		define TS_STRNCPY	strncpy
//#		define TS_STRCMP	strcmp
#	if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#		define TS_SNPRINTF	_snprintf
#	else
#		define TS_SNPRINTF	snprintf
#	endif
//#	endif
#define TS_T(x)  TS_T2(x)
#endif

} // namespace afl

#endif // _CPPUNIT_PORTABILITY_HEADER_

#ifndef _CPPUNIT_TEST_HEADER_
#define _CPPUNIT_TEST_HEADER_

#ifdef _MSC_VER
	#define _CRT_SECURE_NO_WARNINGS 1
#endif

#ifndef _STL_LIST_HEADER_
#define _STL_LIST_HEADER_
#include <list>
#endif

#ifndef _STL_STRING_HEADER_
#define _STL_STRING_HEADER_
#include <string>
#endif

#ifndef _CPPUNIT_THUNK_HEADER_
#include "thunk.h"
#endif

#ifndef _TYPE_INT_HEADER_
#include "type_int.h"
#endif

CPPUNIT_NS_BEGIN

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class AFL_API Test
{
public:
	virtual void test() = 0;
	virtual Thunk testThunk();
	virtual ~Test();

protected:
	Test();

private:
	Thunk testThunk_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class AFL_API Fixture
{
public:
	virtual void setUp() = 0;
	virtual void tearDown() = 0;

	virtual Thunk setUpThunk();
	virtual Thunk tearDownThunk();

	virtual ~Fixture();

protected:
	Fixture();

private:
	Thunk setUpThunk_;
	Thunk tearDownThunk_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class AFL_API TestCase : public Test, public virtual Fixture
{
public:
	virtual ~TestCase();

	const char* name() const;
    bool isIgnored() const;

protected:
	TestCase(const char* name, const bool isIgnored);
	TestCase(const TestCase& rhs);
	TestCase& operator=(const TestCase& rhs);

private:
	const char* name_;
	bool isIgnored_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class AFL_API TestSuite
{
public:
	typedef std::list<TestCase*> TestCaseList;
	typedef TestCaseList::iterator TestCaseIter;
	typedef TestCaseList::const_iterator TestCaseConstIter;

public:
	TestSuite(const char* name = 0);
	TestSuite(const TestSuite& rhs);
	TestSuite& operator=(const TestSuite& rhs);
	virtual ~TestSuite();

	const char* name();

	TestCaseIter beginTestCases();
	TestCaseIter endTestCases();

	void addTestCase(TestCase* testCase);

    void ignoreAddingTestCases(bool value);
    bool ignoreAddingTestCases() const;

private:
	const char* name_;
	TestCaseList testCases_;

	bool ignoreAddingTestCases_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class TestRegistry
{
public:
	typedef std::list<TestSuite*> TestSuiteList;
	typedef TestSuiteList::iterator TestSuiteIter;
	typedef TestSuiteList::const_iterator TestSuiteConstIter;

public:
	static AFL_API TestRegistry* initialize();
	static AFL_API void reinitialize(TestRegistry* newValue);	// for tests

	void AFL_API addTestCase(TestCase* testCase);
	void AFL_API addTestSuite(TestSuite* testSuite);

	AFL_API TestSuiteIter beginTestSuites();
	AFL_API TestSuiteIter endTestSuites();

	AFL_API TestSuiteList& testSuiteList();

protected:
	TestRegistry();

private:
	static AFL_API TestRegistry* thisPtr_;
	static AFL_API TestSuite defaultTestSuite_;

	TestSuiteList testSuiteList_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename TestSuiteClass>
class RegisterTestSuite
{
public:
	RegisterTestSuite(const char* name);

	TestSuite* testsuite_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename TestCaseClass>
class RegisterTestCase
{
public:
	RegisterTestCase(const char* name, TestSuite* testSuite);
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class SourceLine
{
public:
	AFL_API SourceLine(const char* fileName, const int_max_t lineNumber);

	const char* fileName() const;
	int_max_t lineNumber() const;

public:
	static const char* unknownFileName_;
	static const int_max_t unknownLineNumber_;

protected:
    SourceLine();

private:
	const char* fileName_;
	int_max_t lineNumber_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class TestException
{
public:
    virtual ~TestException();
    const SourceLine& sourceLine() const;

    virtual void message(char* buffer, const uint_max_t bufferSize) const = 0;

protected:
    TestException(const SourceLine& sourceLine);

private:
    SourceLine sourceLine_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Templates realization
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

template<typename TestSuiteClass>
RegisterTestSuite<TestSuiteClass>::RegisterTestSuite(const char* name)
: testsuite_(0)
{
	static TestSuiteClass testsuite(name);
	testsuite_ = &testsuite;
	TestRegistry::initialize()->addTestSuite(&testsuite);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename TestCaseClass>
RegisterTestCase<TestCaseClass>::RegisterTestCase(const char* name, TestSuite* testSuite)
{
	static TestCaseClass testcase(name, testSuite->ignoreAddingTestCases());
	testSuite->addTestCase(&testcase);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class IgnoreTestCaseGuard
{
public:
    AFL_API IgnoreTestCaseGuard(TestSuite* testSuite)
    {
        testSuite->ignoreAddingTestCases(true);
    }
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class NotIgnoreTestCaseGuard
{
public:
    AFL_API NotIgnoreTestCaseGuard(TestSuite* testSuite)
    {
        testSuite->ignoreAddingTestCases(false);
    }
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Macro
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define CPPUNIT_SOURCELINE()   CPPUNIT_NS::SourceLine(__FILE__, __LINE__)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define TEST_FIXTURE_NAME(name) name##TestFixture

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define TEST_FIXTURE(fixtureName)\
class TEST_FIXTURE_NAME(fixtureName) : public virtual CPPUNIT_NS::Fixture\

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define SETUP\
	public:\
		virtual void setUp()

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define TEARDOWN\
	public:\
		virtual void tearDown()

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define TEST_FUNCTION(functionName)\
\
class functionName##TestCase : public CPPUNIT_NS::TestCase\
{\
public:\
    virtual void test();\
};\
static functionName##TestCase functionName##TestCase##StaticObject;\
void functionName##TestCase::test()

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//#define UNIQUE_TEST_SUITE_NAME(name) name ## TestSuite
#define UNIQUE_REGISTER_NAME(name) Register ## name
#define UNIQUE_TEST_SUITE_OBJECT_NAME name ## Object
#define UNIQUE_TEST_SUITE_NAMESPACE(name) name ## Namespace

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define TEST_SUITE(testSuiteName)\
	class testSuiteName : public CPPUNIT_NS::TestSuite\
	{\
	public:\
		testSuiteName(const char* name)\
		: CPPUNIT_NS::TestSuite(name)\
		{\
		}\
	};\
	CPPUNIT_NS::RegisterTestSuite<testSuiteName> UNIQUE_REGISTER_NAME(testSuiteName)(#testSuiteName);\
	namespace UNIQUE_TEST_SUITE_NAMESPACE(testSuiteName)\
	{\
		static CPPUNIT_NS::TestSuite* localTestSuite = UNIQUE_REGISTER_NAME(testSuiteName).testsuite_;\
	}\
	namespace UNIQUE_TEST_SUITE_NAMESPACE(testSuiteName)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define CONCAT(a, b) a ## b
#define CONCAT2(x, y) CONCAT(x, y)
//#define UNIQUENAME(prefix) CONCAT2(prefix, __LINE__)
#define UNIQUENAME(prefix) CONCAT2(prefix, __COUNTER__)

#define IGNORE_TEST \
    CPPUNIT_NS::IgnoreTestCaseGuard UNIQUENAME(ignore)(localTestSuite);


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define TEST_CASE(testName)\
	class TestCase##testName;\
	CPPUNIT_NS::RegisterTestCase<TestCase##testName> UNIQUE_REGISTER_NAME(testName)(#testName, localTestSuite);\
	class TestCase##testName : public CPPUNIT_NS::TestCase\
	{\
	public:\
		TestCase##testName(const char* name, bool isIgnored)\
		: CPPUNIT_NS::TestCase(name, isIgnored)\
		{\
		}\
		SETUP {}\
		TEARDOWN {}\
		virtual void test()\
		{

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define TEST_CASE_EX(testName, fixtureName)\
	class TestCase##testName;\
	CPPUNIT_NS::RegisterTestCase<TestCase##testName> UNIQUE_REGISTER_NAME(testName)(#testName, localTestSuite);\
	class TestCase##testName : public CPPUNIT_NS::TestCase, public TEST_FIXTURE_NAME(fixtureName)\
	{\
	public:\
		TestCase##testName(const char* name, bool isIgnored)\
		: CPPUNIT_NS::TestCase(name, isIgnored)\
		{\
		}\
		virtual void test()\
		{

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define TEST_CASE_END\
		}\
	};\
	CPPUNIT_NS::NotIgnoreTestCaseGuard UNIQUENAME(notIgnore)(localTestSuite);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool AFL_API cppunitAssert(const bool condition);

template<typename T>
bool cppunitAssert(const T expected, const T actual);

template<typename T1, typename T2>
bool cppunitAssert(const T1 expected, const T2 actual)
{
	return cppunitAssert(expected == actual);
}

template<typename T>
bool cppunitAssert(const T expected, const T actual)
{
	return cppunitAssert(expected == actual);
}

/// \param[in] delta must be at [0.00000001f, +INFINITE)
bool AFL_API cppunitAssert(const float expected, const float actual, const float delta);

/// \param[in] delta must be at [0.000000000000001, +INFINITE)
bool AFL_API cppunitAssert(const double expected, const double actual, const double delta);

/// \param[in] delta must be at [0.000000000000001, +INFINITE)
bool AFL_API cppunitAssert(const long double expected, const long double actual, const long double delta);

bool AFL_API cppunitAssert(const char *expected, const char *actual);
bool AFL_API cppunitAssert(const wchar_t *expected, const wchar_t *actual);
bool AFL_API cppunitAssert(const std::wstring& expected, const std::wstring& actual);
bool AFL_API cppunitAssert(const std::string& expected, const std::string& actual);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void AFL_API throwException(const SourceLine& sourceLine, const char* condition);
void AFL_API throwException(const SourceLine& sourceLine, const char* message, bool);
void AFL_API throwException(const SourceLine& sourceLine, const wchar_t* message, bool);

void AFL_API throwException(const SourceLine& sourceLine, const int_max_t expected, const int_max_t actual,
							bool mustBeEqual);
void AFL_API throwException(const SourceLine& sourceLine, const char *expected, const char *actual,
							bool mustBeEqual);
void AFL_API throwException(const SourceLine& sourceLine, const wchar_t *expected, const wchar_t *actual,
							bool mustBeEqual);
void AFL_API throwException(const SourceLine& sourceLine, const std::wstring& expected, const std::wstring& actual,
							bool mustBeEqual);
void AFL_API throwException(const SourceLine& sourceLine, const std::string& expected, const std::string& actual,
							bool mustBeEqual);
void AFL_API throwException(const SourceLine& sourceLine, const double expected, const double actual,
							const double delta, bool mustBeEqual);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//#define ASSERT_MESSAGE(message)
	//CPPUNIT_NS::throwException(CPPUNIT_SOURCELINE(), message, true)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define ASSERT(condition)\
	if(!CPPUNIT_NS::cppunitAssert(condition))\
		CPPUNIT_NS::throwException(CPPUNIT_SOURCELINE(), #condition)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define ASSERT_NOT(condition)\
	if(CPPUNIT_NS::cppunitAssert(condition))\
		CPPUNIT_NS::throwException(CPPUNIT_SOURCELINE(), #condition " != false", false)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define ASSERT_EQUAL(expected, actual)\
	if(!CPPUNIT_NS::cppunitAssert((expected), (actual)))\
		CPPUNIT_NS::throwException(CPPUNIT_SOURCELINE(), (expected), (actual), true)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define ASSERT_NOT_EQUAL(expected, actual)\
	if(CPPUNIT_NS::cppunitAssert((expected), (actual)))\
		CPPUNIT_NS::throwException(CPPUNIT_SOURCELINE(), (expected), (actual), false)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define ASSERT_DOUBLES_EQUAL(expected, actual, delta)\
	if(!CPPUNIT_NS::cppunitAssert((expected), (actual), (delta)))\
		CPPUNIT_NS::throwException(CPPUNIT_SOURCELINE(), (expected), (actual), (delta), true)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define ASSERT_DOUBLES_NOT_EQUAL(expected, actual, delta)\
	if(CPPUNIT_NS::cppunitAssert((expected), (actual), (delta)))\
		CPPUNIT_NS::throwException(CPPUNIT_SOURCELINE(), (expected), (actual), (delta), false)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define ASSERT_THROW(expression, exceptionType)																\
	for(;;)																									\
	{																										\
		try																									\
		{																									\
			expression;																						\
		}																									\
		catch(const exceptionType&)																			\
		{																									\
			break;																							\
		}																									\
																											\
		CPPUNIT_NS::throwException(CPPUNIT_SOURCELINE(),													\
			"Expected exception \"" #exceptionType "\" hasn't been not thrown.", true);						\
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define ASSERT_NO_CPP_EXCEPTION(expression, exceptionType)														\
	try																									\
	{																									\
		expression;																						\
	}																									\
	catch(const exceptionType&)																			\
	{																									\
		CPPUNIT_NS::throwException(CPPUNIT_SOURCELINE(),													\
			"Not expected exception \"" #exceptionType "\" has been thrown.", true);			\
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define ASSERT_NO_ANY_CPP_EXCEPTION(expression)														\
	try																									\
	{																									\
		expression;																						\
	}																									\
	catch(...)																			\
	{																									\
		CPPUNIT_NS::throwException(CPPUNIT_SOURCELINE(),													\
			"Unwanted C++ exception has been thrown.", true);			\
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define ASSERT_NO_SEH_THROW(expression)																	\
	__try																									\
	{																										\
		expression;																							\
	}																										\
	__except(EXCEPTION_EXECUTE_HANDLER)																		\
	{																										\
		CPPUNIT_NS::throwException(CPPUNIT_SOURCELINE(), "Unwanted SEH exception has been thrown.", true);		\
	}

CPPUNIT_NS_END

#endif // _CPPUNIT_TEST_HEADER_
