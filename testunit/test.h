#ifdef _MSC_VER
#pragma once
#endif

#ifdef _MSC_VER
// Two or more members have the same name. The one in class2 is inherited because it is a base class for the
// other classes that contained this member.
// This situation with TestFixture and TestCase, inherited from it
#pragma warning(disable : 4250)
//
// warning C4251: 'CppUnit::TestSuite::testCases_' : class 'std::list<_Ty>' needs to have dll-interface
// to be used by clients of class 'CppUnit::TestSuite'
#pragma warning(disable : 4251)
#endif


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// test.h
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef _TESTUNIT_PORTABILITY_HEADER_
#define _TESTUNIT_PORTABILITY_HEADER_


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if defined(TESTUNIT_NO_NAMESPACE)
#   define TESTUNIT_NS_BEGIN
#   define TESTUNIT_NS_END
#   define TESTUNIT_NS
#else   // defined(TESTUNIT_NO_NAMESPACE)
#   define TESTUNIT_NS_BEGIN    \
namespace TestUnit {

#   define TESTUNIT_NS_END  \
}

#   define TESTUNIT_NS TestUnit
#endif // defined(TESTUNIT_NO_NAMESPACE)

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

#endif // _TESTUNIT_PORTABILITY_HEADER_

#ifndef _TESTUNIT_TEST_HEADER_
#define _TESTUNIT_TEST_HEADER_

#ifndef _STL_LIST_HEADER_
#define _STL_LIST_HEADER_
#include <list>
#endif

#ifndef _STL_STRING_HEADER_
#define _STL_STRING_HEADER_
#include <string>
#endif

#ifndef _TESTUNIT_THUNK_HEADER_
#include "thunk.h"
#endif

TESTUNIT_NS_BEGIN

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class SourceLine
{
public:
	TESTUNIT_API SourceLine(const char* fileName, const int lineNumber);

	const char* fileName() const;
	int lineNumber() const;

public:
	static const char* unknownFileName_;
	static const int unknownLineNumber_;

protected:
    SourceLine();

private:
	const char* fileName_;
	int lineNumber_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class TESTUNIT_API Test
{
public:
	virtual void execute() = 0;
	virtual Thunk testThunk();
	virtual ~Test();

protected:
	Test();

private:
	Thunk testThunk_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class TESTUNIT_API Fixture
{
public:
	virtual void innerSetUp() = 0;
	virtual void innerTearDown() = 0;

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
class TESTUNIT_API TestCase : public Test, public virtual Fixture
{
public:
	virtual ~TestCase();

	const char* name() const;
    bool isIgnored() const;
    const SourceLine& source() const;

protected:
	TestCase(const char* name, const bool isIgnored, const SourceLine& source);
	TestCase(const TestCase& rhs);
	TestCase& operator=(const TestCase& rhs);

private:
	const char* name_;
	bool isIgnored_;
    SourceLine source_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class TESTUNIT_API TestSuite
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

	const char* name() const;

	TestCaseIter begin();
	TestCaseIter end();

	void addTestCase(TestCase* testCase);

private:
	const char* name_;
	TestCaseList testCases_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class TestRegistry
{
public:
	typedef std::list<TestSuite*> TestSuiteList;
	typedef TestSuiteList::iterator TestSuiteIter;
	typedef TestSuiteList::const_iterator TestSuiteConstIter;

public:
	static TESTUNIT_API TestRegistry* initialize();
	static TESTUNIT_API void reinitialize(TestRegistry* newValue);	// for tests

    void TESTUNIT_API addTestCase(TestCase* testCase);

	TESTUNIT_API TestSuiteIter begin();
	TESTUNIT_API TestSuiteIter end();

protected:
	TestRegistry();
	~TestRegistry();

    TESTUNIT_API TestSuite* getTestSuite(const SourceLine& source);

private:
	static TESTUNIT_API TestRegistry* thisPtr_;

	TestSuiteList testSuiteList_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename TestCaseClass>
struct RegisterTestCase
{
	RegisterTestCase(const char* name, const SourceLine& source);
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename TestCaseClass>
struct RegisterIgnoredTestCase
{
	RegisterIgnoredTestCase(const char* name, const SourceLine& source);
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class TestException : public std::exception
{
public:
    virtual ~TestException() throw();
    const SourceLine& sourceLine() const;

    virtual void message(char* buffer, const unsigned int bufferSize) const = 0;

protected:
    TestException(const SourceLine& sourceLine);

private:
    SourceLine sourceLine_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Templates realization
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename TestCaseClass>
RegisterTestCase<TestCaseClass>::RegisterTestCase(const char* name,
                                                  const SourceLine& source)
{
    const bool ignore = true;
	static TestCaseClass testcase(name, !ignore, source);
	TestRegistry::initialize()->addTestCase(&testcase);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename TestCaseClass>
RegisterIgnoredTestCase<TestCaseClass>::RegisterIgnoredTestCase(const char* name,
                                                                const SourceLine& source)
{
    const bool ignore = true;
	static TestCaseClass testcase(name, ignore, source);
	TestRegistry::initialize()->addTestCase(&testcase);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Macro
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

bool TESTUNIT_API cppunitAssert(const bool condition);

bool TESTUNIT_API cppunitAssert(const long long expected, const long long actual);

/// \param[in] delta must be at [0.00000001f, +INFINITE)
bool TESTUNIT_API cppunitAssert(const float expected, const float actual, const float delta);

/// \param[in] delta must be at [0.000000000000001, +INFINITE)
bool TESTUNIT_API cppunitAssert(const double expected, const double actual, const double delta);

/// \param[in] delta must be at [0.000000000000001, +INFINITE)
bool TESTUNIT_API cppunitAssert(const long double expected, const long double actual, const long double delta);

bool TESTUNIT_API cppunitAssert(const char *expected, const char *actual);
bool TESTUNIT_API cppunitAssert(const wchar_t *expected, const wchar_t *actual);

bool TESTUNIT_API cppunitAssert(const std::wstring& expected, const std::wstring& actual);
bool TESTUNIT_API cppunitAssert(const std::string& expected, const std::string& actual);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void TESTUNIT_API throwException(const SourceLine& sourceLine, const char* condition);
void TESTUNIT_API throwException(const SourceLine& sourceLine, const char* message, bool);
void TESTUNIT_API throwException(const SourceLine& sourceLine, const wchar_t* message, bool);

void TESTUNIT_API throwException(const SourceLine& sourceLine, const long long expected, const long long actual,
							bool mustBeEqual);
void TESTUNIT_API throwException(const SourceLine& sourceLine, const char* expected, const char* actual,
							bool mustBeEqual);
void TESTUNIT_API throwException(const SourceLine& sourceLine, const std::string& expected, const std::string& actual,
							bool mustBeEqual);
void TESTUNIT_API throwException(const SourceLine& sourceLine, const wchar_t* expected, const wchar_t* actual,
							bool mustBeEqual);
void TESTUNIT_API throwException(const SourceLine& sourceLine, const std::wstring& expected, const std::wstring& actual,
							bool mustBeEqual);
void TESTUNIT_API throwException(const SourceLine& sourceLine, const double expected, const double actual,
							const double delta, bool mustBeEqual);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define CONCAT(a, b) a ## b
#define CONCAT2(x, y) CONCAT(x, y)
#define UNIQUENAME(prefix) CONCAT2(prefix, __COUNTER__)

#define UNIQUE_REGISTER_NAME(name) Register ## name
#define UNIQUE_TEST_NAMESPACE(name) name ## Namespace

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define TESTUNIT_SOURCELINE()   TESTUNIT_NS::SourceLine(__FILE__, __LINE__)

#define fixtureName(name) name ## Fixture
#define fixtureName2(name, name1, name2) fixtureName(name ## name1 ## name2)

#define fixture(name)\
    struct fixtureName(name) : public virtual TESTUNIT_NS::Fixture

#define fixture2(derived, base1, base2)\
    struct derived : public base1,\
                     public base2 \
    {\
		virtual void innerSetUp()\
        {\
            base1::innerSetUp();\
            base2::innerSetUp();\
        }\
		virtual void innerTearDown()\
        {\
            base1::innerTearDown();\
            base2::innerTearDown();\
        }\
    };

#define setUp()\
    virtual void innerSetUp()

#define tearDown()\
    virtual void innerTearDown()

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define test_(name)\
	struct TestCase##name : public TESTUNIT_NS::TestCase\
	{\
		TestCase##name(const char* name, bool isIgnored, const TESTUNIT_NS::SourceLine& source)\
		: TESTUNIT_NS::TestCase(name, isIgnored, source)\
		{}\
		virtual void innerSetUp() {}\
        virtual void execute();\
		virtual void innerTearDown() {}\
    };

#define test1_(name, usedFixture)\
	struct TestCase##name : public TESTUNIT_NS::TestCase, public usedFixture\
	{\
		TestCase##name(const char* name, bool isIgnored, const TESTUNIT_NS::SourceLine& source)\
		: TESTUNIT_NS::TestCase(name, isIgnored, source)\
		{}\
		virtual void execute();\
    };

#define registerTest(name, source)\
    TESTUNIT_NS::RegisterTestCase<TestCase##name> UNIQUENAME(name)(#name, source);

#define registerIgnoredTest(name, source)\
    TESTUNIT_NS::RegisterIgnoredTestCase<TestCase##name> UNIQUENAME(name)(#name, source);

#define testBodyDef(name)\
    void TestCase##name::execute()

#define ignoredTestBodyDef(name)\
    void TestCase##name::execute() {}\
    template<typename T> void TestCase ## name ## Fake()

#define test(name)\
    test_(name)\
    registerTest(name, TESTUNIT_SOURCELINE())\
    testBodyDef(name)

#define test1(name, usedFixture)\
    test1_(name, fixtureName(usedFixture))\
    registerTest(name, TESTUNIT_SOURCELINE())\
    testBodyDef(name)

#define test2(name, usedFixture1, usedFixture2)\
    fixture2(fixtureName2(name, usedFixture1, usedFixture2),\
             fixtureName(usedFixture1),\
             fixtureName(usedFixture2))\
    test1_(name, fixtureName2(name, usedFixture1, usedFixture2))\
    registerTest(name, TESTUNIT_SOURCELINE())\
    testBodyDef(name)

#define _test(name)\
    test_(name)\
    registerIgnoredTest(name, TESTUNIT_SOURCELINE())\
    ignoredTestBodyDef(name)

#define _test1(name, usedFixture)\
    test_(name)\
    registerIgnoredTest(name, TESTUNIT_SOURCELINE())\
    ignoredTestBodyDef(name)

#define _test2(name, usedFixture1, usedFixture2)\
    test_(name)\
    registerIgnoredTest(name, TESTUNIT_SOURCELINE())\
    ignoredTestBodyDef(name)


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ASSERTS
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define isNull(actual)\
	if(!TESTUNIT_NS::cppunitAssert((actual) == NULL))\
        TESTUNIT_NS::throwException(TESTUNIT_SOURCELINE(), L ## #actual L" is not NULL", false)

#define isTrue(condition)\
	if(!TESTUNIT_NS::cppunitAssert(condition))\
		TESTUNIT_NS::throwException(TESTUNIT_SOURCELINE(), #condition)

#define isFalse(condition)\
	if(TESTUNIT_NS::cppunitAssert(condition))\
		TESTUNIT_NS::throwException(TESTUNIT_SOURCELINE(), #condition " != false", false)

#define areEq(expected, actual)\
	if(!TESTUNIT_NS::cppunitAssert((expected), (actual)))\
        TESTUNIT_NS::throwException(TESTUNIT_SOURCELINE(), (expected), (actual), true)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define areNotEq(expected, actual)\
	if(TESTUNIT_NS::cppunitAssert((expected), (actual)))\
		TESTUNIT_NS::throwException(TESTUNIT_SOURCELINE(), (expected), (actual), false)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define areDoubleEq(expected, actual, delta)\
	if(!TESTUNIT_NS::cppunitAssert((expected), (actual), (delta)))\
		TESTUNIT_NS::throwException(TESTUNIT_SOURCELINE(), (expected), (actual), (delta), true)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define areDoubleNotEq(expected, actual, delta)\
	if(TESTUNIT_NS::cppunitAssert((expected), (actual), (delta)))\
		TESTUNIT_NS::throwException(TESTUNIT_SOURCELINE(), (expected), (actual), (delta), false)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define willThrow(expression, exceptionType)																\
	{                                                                                                       \
        bool catched = false;                                                                               \
		try																									\
		{																									\
			expression;																			            \
		}																									\
		catch(const exceptionType&)																			\
		{																									\
			catched = true;																					\
		}																									\
		if (!catched)																						\
		{                                                                                                   \
            TESTUNIT_NS::throwException(TESTUNIT_SOURCELINE(),												\
			"Expected exception "" #exceptionType "" hasn't been not thrown.", true);						\
        }                                                                                                   \
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define noSpecificThrow(expression, exceptionType)														\
	try																									\
	{																									\
		expression;																						\
	}																									\
	catch(const exceptionType&)																			\
	{																									\
		TESTUNIT_NS::throwException(TESTUNIT_SOURCELINE(),													\
			"Not expected exception \"" #exceptionType "\" has been thrown.", true);			\
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define noAnyCppThrow(expression)														\
	try																									\
	{																									\
		expression;																						\
	}																									\
	catch(...)																			\
	{																									\
		TESTUNIT_NS::throwException(TESTUNIT_SOURCELINE(),													\
			"Unwanted C++ exception has been thrown.", true);			\
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define noSehThrow(expression)																	\
	__try																									\
	{																										\
		expression;																							\
	}																										\
	__except(EXCEPTION_EXECUTE_HANDLER)																		\
	{																										\
		TESTUNIT_NS::throwException(TESTUNIT_SOURCELINE(), "Unwanted SEH exception has been thrown.", true);		\
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

TESTUNIT_NS_END

#endif // _TESTUNIT_TEST_HEADER_
