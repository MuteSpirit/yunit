//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// test.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifdef _MSC_VER
#  define _CRT_SECURE_NO_WARNINGS 1
#  include <excpt.h>
#else
#  include <string.h>
#endif

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#ifdef __cplusplus
extern "C" {
#endif
#  include "lauxlib.h"
#  include "lualib.h"
#ifdef __cplusplus
}
#endif

#define YUNIT_DLL_EXPORTS
#include "test.h"

namespace YUNIT_NS {
static int loadTestContainer(lua_State* L);
static int getTestContainerExtensions(lua_State* L);
static int getTestList(lua_State* L);
static void createTestCaseMetatable(lua_State* L);

static const char* testCaseMtName = "testCaseMetatable";
    
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class TestSuite
{
public:
    typedef std::list<TestCase*> TestCaseList;
    typedef TestCaseList::const_iterator TestCaseConstIter;
private:
    typedef TestCaseList::iterator TestCaseIter;

public:
    YUNIT_API TestSuite(const char* name = 0);
    TestSuite(const TestSuite& rhs);
    TestSuite& operator=(const TestSuite& rhs);
    virtual ~TestSuite();

    const char* name() const;

    TestCaseConstIter begin();
    TestCaseConstIter end();

    void addTestCase(TestCase* testCase);

private:
    const char* name_;
    TestCaseList testCases_;
};
    
} // namespace YUNIT_NS


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
extern "C"
int YUNIT_API luaopen_cppunit(lua_State* L)
{
    static const struct luaL_Reg cppunit[] =
    {
	    {"getTestContainerExtensions", YUNIT_NS::getTestContainerExtensions},
	    {"loadTestContainer", YUNIT_NS::loadTestContainer},
	    {"getTestList", YUNIT_NS::getTestList},
	    {NULL, NULL},
    };

    YUNIT_NS::createTestCaseMetatable(L);
	luaL_register(L, "cppunit", cppunit);
	return 0;
}


namespace YUNIT_NS {

const char** getTestContainerExtensions();
    
static int getTestContainerExtensions(lua_State* L)
{
    const char** ext = getTestContainerExtensions();

    lua_newtable(L);

    int i = 1;
    while(ext && *ext)
    {
        lua_pushnumber(L, i++); 
        lua_pushstring(L, *ext++);
        lua_settable(L, -3);
    }

    return 1;
}

static int loadTestContainer(lua_State* L)
{
    if (!lua_isstring(L, 1))
    {
        lua_pushboolean(L, 0);
        lua_pushfstring(L, "expected string as argument type, but was %s", lua_typename(L, lua_type(L, 1)));
        return 2;
    }
    
    size_t len;
    const char* path = lua_tolstring(L, 1, &len);
    if (0 == len)
    {
        lua_pushboolean(L, 0);
        lua_pushstring(L, "empty argument");
        return 2;
    }
    //
    // we must only load library to current process for initialization global objects and filling test register
    //
    // push error handling function
    lua_getglobal(L, "debug");
    lua_getfield(L, -1, "traceback");
    lua_remove(L, -2);
    //
    // push function
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "loadlib");
    lua_remove(L, -2);
    //
    lua_pushstring(L, path); // 1st argument
    lua_pushstring(L, "");     // 2nd argument ("" means not load specified function)
    //
    int rc = lua_pcall(L, 2, 1, -4);
    if (0 != rc)
    {
        lua_pushboolean(L, 0);
        lua_pushvalue(L, -2);   // push copy of error message
        lua_remove(L, -3);       // remove original error message from stack
        return 2;
    }
    
    lua_pop(L, 1);  // remove return value of 'package.loadlib' function
    lua_pushboolean(L, 1);
    return 1;
}

static int getTestList(lua_State* L)
{
	lua_newtable(L); // all test cases list

    lua_Number i = 1;
	TestRegistry::TestSuiteConstIter it = TestRegistry::initialize()->begin();
	TestRegistry::TestSuiteConstIter endIt = TestRegistry::initialize()->end();
	for(; it != endIt; ++it)
	{
		TestSuite::TestCaseConstIter itTc = (*it)->begin();
		TestSuite::TestCaseConstIter endItTc = (*it)->end();
		for(; itTc != endItTc; ++itTc)
		{
			lua_pushnumber(L, i++);	// order number of TestCase

            TestCase** tc = reinterpret_cast<TestCase**>(lua_newuserdata(L, sizeof(TestCase*)));
	        *tc = *itTc;

            luaL_getmetatable(L, testCaseMtName);
	        lua_setmetatable(L, -2);

			lua_settable(L, -3); // t[i] = testcase
		}
	}

	return 1;
}



static int luaTestCaseSetUp(lua_State* L);
static int luaTestCaseTest(lua_State* L);
static int luaTestCaseTearDown(lua_State* L);
static int luaTestCaseIsIgnored(lua_State* L);
static int luaTestCaseName(lua_State* L);
static int luaTestCaseLineNumber(lua_State* L);
static int luaTestCaseFileName(lua_State* L);

static void createTestCaseMetatable(lua_State* L)
{
    static const struct luaL_Reg testCaseMetods[] = 
    {
        {"setUp", luaTestCaseSetUp},
        {"test", luaTestCaseTest},
        {"tearDown", luaTestCaseTearDown},
        {"isIgnored", luaTestCaseIsIgnored},
        {"name", luaTestCaseName},
        {"lineNumber", luaTestCaseLineNumber},
        {"fileName", luaTestCaseFileName},
        {NULL, NULL}
    };
    
    luaL_newmetatable(L, testCaseMtName);
    luaL_register(L, NULL, testCaseMetods);

    lua_pushvalue(L, -1);
    lua_setfield(L, -2, "__index"); // metatable.__index = metatable
    
    lua_pop(L, 1); // remove new metatable from stack
}

static TestCase* getTestCaseFromSelf(lua_State* L);
static int callTestCaseThunk(lua_State* L, TestCase* testCase, Thunk thunk);
static bool wereCatchedCppExceptions(lua_State* L, TestCase* testCase, Thunk thunk, int& countReturnValues);
static int luaPushErrorObject(lua_State* L, const char* fileName, lua_Integer lineNumber, const char* message);

static int luaTestCaseSetUp(lua_State* L)
{
    TestCase* tc = getTestCaseFromSelf(L);
    return callTestCaseThunk(L, tc, tc->setUpThunk());
}

static int luaTestCaseTest(lua_State* L)
{
    TestCase* tc = getTestCaseFromSelf(L);
    return callTestCaseThunk(L, tc, tc->testThunk());
}

static int luaTestCaseTearDown(lua_State* L)
{
    TestCase* tc = getTestCaseFromSelf(L);
    return callTestCaseThunk(L, tc, tc->tearDownThunk());
}

static int luaTestCaseIsIgnored(lua_State* L)
{
    TestCase* tc = getTestCaseFromSelf(L);
    lua_pushboolean(L, tc->isIgnored());
    return 1;
}

static int luaTestCaseLineNumber(lua_State* L)
{
    TestCase* tc = getTestCaseFromSelf(L);
    lua_pushinteger(L, tc->source().lineNumber());
    return 1;
}

static int luaTestCaseFileName(lua_State* L)
{
    TestCase* tc = getTestCaseFromSelf(L);
    lua_pushstring(L, tc->source().fileName());
    return 1;
}

static int luaTestCaseName(lua_State* L)
{
    TestCase* tc = getTestCaseFromSelf(L);

    lua_pushfstring(L, "%s::%s", tc->source().fileName(), tc->name());
    return 1;
}

static TestCase* getTestCaseFromSelf(lua_State* L)
{
    if (!lua_isuserdata(L, 1))
        luaL_error(L, "cannot use 'self' object, because userdata expected, but was %s", lua_typename(L, lua_type(L, 1)));
    
    TestCase** tcPp = reinterpret_cast<TestCase**>(lua_touserdata(L, 1));
    if (NULL == tcPp)
        luaL_error(L, "cannot use 'self' object, it equals NULL");
    
    TestCase* tc = *tcPp;
    if (NULL == tcPp)
        luaL_error(L, "cannot use 'self' object, it points to NULL value");

    return tc;
}

static int callTestCaseThunk(lua_State* L, TestCase* testCase, Thunk thunk)
{
    bool thereAreCppExceptions = false;
    int countReturnValues = 0;
#ifdef _MSC_VER
    __try
    {
        thereAreCppExceptions = wereCatchedCppExceptions(L, testCase, thunk, countReturnValues);
    }
    __except(EXCEPTION_EXECUTE_HANDLER)
    {
		lua_pushboolean(L, false); // status code
        countReturnValues = 1;

        countReturnValues += luaPushErrorObject(
            L,
            testCase->source().fileName(), testCase->source().lineNumber(),
            "Unexpected SEH exception was caught");
    }
#else // not defined _MSC_VER
    thereAreCppExceptions = wereCatchedCppExceptions(L, testCase, thunk, countReturnValues);
#endif
    if (!thereAreCppExceptions)
    {
        // status code
	    lua_pushboolean(L, true);
        ++countReturnValues;

        countReturnValues += luaPushErrorObject(
            L,
            testCase->source().fileName(), testCase->source().lineNumber(),
            "");
    }

    return countReturnValues;
}

static bool wereCatchedCppExceptions(lua_State* L, TestCase* testCase, Thunk thunk, int& countReturnValues)
{
    countReturnValues = 0;
    try
    {
        thunk.invoke();
    }
	catch (TestException& ex)
    {
        // status code
		lua_pushboolean(L, false);
        ++countReturnValues;

		enum {bufferSize = 1024 * 5};
		char errorMessage[bufferSize] = {'\0'};
		ex.message(errorMessage, bufferSize);

        countReturnValues += luaPushErrorObject(
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

        countReturnValues += luaPushErrorObject(
            L,
            testCase->source().fileName(), testCase->source().lineNumber(),
            errorMessage);

		return true;
    }
    catch(...)
    {
        lua_pushboolean(L, false);
        ++countReturnValues;

        countReturnValues += luaPushErrorObject(
            L,
            testCase->source().fileName(), testCase->source().lineNumber(),
            "Unexpected unknown C++ exception was caught");

		return true;
	}

	return false;
}

static int luaPushErrorObject(lua_State* L,
                              const char* fileName,
                              lua_Integer lineNumber,
                              const char* message)
{
    lua_newtable(L); // new Error Object 
    
    lua_pushstring(L, fileName);       // source file with error
    lua_setfield(L, -2, "source");
    
    lua_pushinteger(L, lineNumber);     // number of line with error
    lua_setfield(L, -2, "line");
    
    lua_pushstring(L, message);         // error message
    lua_setfield(L, -2, "message");

    return 1;
}

const char** getTestContainerExtensions()
{
#ifdef WIN32
    static const char* mas[] = {".t.dll", NULL};
#else
    static const char* mas[] = {".t.so", NULL};
#endif
    return mas;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
Thunk::Thunk()
: thunkPtr_(0)
, thisPtr_(0)
{
}

Thunk::Thunk(void (* thunkPtr)(void*), void* thisPtr)
: thunkPtr_(thunkPtr)
, thisPtr_(thisPtr)
{
}

void Thunk::invoke()
{
    (*thunkPtr_)(thisPtr_);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class TestConditionException : public TestException
{
private:
    typedef TestException Parent;

public:
    TestConditionException(const SourceLine& sourceLine, const char* condition);
    TestConditionException(const TestConditionException& rhs);
    TestConditionException& operator=(const TestConditionException& rhs);

    void message(char* buffer, const unsigned int bufferSize) const;

private:
    const char* condition_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename CharType>
class TestMessageException : public TestException
{
private:
    typedef TestException Parent;

public:
    TestMessageException(const SourceLine& sourceLine, const CharType* message);
    TestMessageException(const TestMessageException<CharType>& rhs);
    TestMessageException<CharType>& operator=(const TestMessageException<CharType>& rhs);

    void message(char* buffer, const unsigned int bufferSize) const;

private:
    const CharType* message_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename T1, typename T2>
class TestEqualException : public TestException
{
private:
    typedef TestException Parent;

public:
    TestEqualException(const SourceLine& sourceLine, const T1 expected, const T2 actual, bool mustBeEqual);
    ~TestEqualException() throw();
    void message(char* buffer, const unsigned int bufferSize) const;

private:
    T1 expected_;
    T2 actual_;
	bool mustBeEqual_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class TestEqualPointersException : public TestException
{
private:
    typedef TestException Parent;

public:
    TestEqualPointersException(const SourceLine& sourceLine, const void* expected, const void* actual, bool mustBeEqual);
    ~TestEqualPointersException() throw();
    void message(char* buffer, const unsigned int bufferSize) const;

private:
    const void* expected_;
    const void* actual_;
	bool mustBeEqual_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename T>
class TestDoubleEqualException : public TestException
{
private:
    typedef TestException Parent;

public:
    TestDoubleEqualException(const SourceLine& sourceLine, const T expected, const T actual, const T delta,
		bool mustBeEqual);
    virtual void message(char* buffer, const unsigned int bufferSize) const;

private:
    T expected_;
    T actual_;
    T delta_;
	bool mustBeEqual_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
Test::Test()
: testThunk_()
{
	testThunk_ = Thunk::create<Test, &Test::execute>(this);
}

Test::~Test()
{
}

Thunk Test::testThunk()
{
	return testThunk_;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
Fixture::Fixture()
: setUpThunk_()
, tearDownThunk_()
{
	setUpThunk_ = Thunk::create<Fixture, &Fixture::innerSetUp>(this);
	tearDownThunk_ = Thunk::create<Fixture, &Fixture::innerTearDown>(this);
}

Fixture::~Fixture()
{
}

Thunk Fixture::setUpThunk()
{
	return setUpThunk_;
}

Thunk Fixture::tearDownThunk()
{
	return tearDownThunk_;
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
TestCase::TestCase(const char* name, const bool isIgnored, const SourceLine& source)
: name_(name)
, isIgnored_(isIgnored)
, source_(source)
{
}

TestCase::TestCase(const TestCase& rhs)
: name_(rhs.name_)
, isIgnored_(rhs.isIgnored_)
, source_(rhs.source_)
{
}

TestCase& TestCase::operator=(const TestCase& rhs)
{
    if (this == &rhs)
        return *this;
    name_ = rhs.name_;
    isIgnored_ = rhs.isIgnored_;
    source_ = rhs.source_;
    return *this;
}

TestCase::~TestCase()
{
}

const char* TestCase::name() const
{
	return name_;
}

bool TestCase::isIgnored() const
{
	return isIgnored_;
}

const SourceLine& TestCase::source() const
{
    return source_;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
TestSuite::TestSuite(const char *name)
: name_(name ? name : "")
, testCases_()
{
}

TestSuite::TestSuite(const TestSuite& rhs)
: name_(rhs.name_)
, testCases_(rhs.testCases_)
{
}

TestSuite& TestSuite::operator=(const TestSuite& rhs)
{
    if (this == &rhs)
        return *this;
    name_ = rhs.name_;
    testCases_ = rhs.testCases_;
    return *this;
}

TestSuite::~TestSuite()
{
}

const char* TestSuite::name() const
{
	return name_;
}

void TestSuite::addTestCase(TestCase* testCase)
{
    testCases_.push_back(testCase);
}

TestSuite::TestCaseConstIter TestSuite::begin()
{
    return testCases_.begin();
}

TestSuite::TestCaseConstIter TestSuite::end()
{
    return testCases_.end();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
TestRegistry* TestRegistry::thisPtr_ = 0;

TestRegistry::TestRegistry()
: testSuiteList_()
{
}

TestRegistry::~TestRegistry()
{
	for (TestSuiteIter it = testSuiteList_.begin(), itEnd = testSuiteList_.end(); it != itEnd; ++it)
		delete *it;
    testSuiteList_.clear();
}

TestRegistry* TestRegistry::initialize()
{
	static TestRegistry testRegistry;
	if (0 == thisPtr_)
		thisPtr_ = &testRegistry;
	return thisPtr_;
}

void TestRegistry::addTestCase(TestCase* testCase)
{
    TestSuite* testSuite = getTestSuite(testCase->source());
    testSuite->addTestCase(testCase);
}

TestRegistry::TestSuiteConstIter TestRegistry::begin()
{
    return testSuiteList_.begin();
}

TestRegistry::TestSuiteConstIter TestRegistry::end()
{
    return testSuiteList_.end();
}

TestSuite* TestRegistry::getTestSuite(const SourceLine& source)
{
    TestSuiteIter it = testSuiteList_.begin();
    TestSuiteIter itEnd = testSuiteList_.end();
    for (; it != itEnd; ++it)
    {
        if (0 == strcmp((*it)->name(), source.fileName()))
            break;
    }

    if (it == itEnd)
    {
        testSuiteList_.push_back(new TestSuite(source.fileName()));
        it = --itEnd;
    }

    return *it;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
SourceLine::SourceLine()
: fileName_(unknownFileName_)
, lineNumber_(unknownLineNumber_)
{
}

SourceLine::SourceLine(const char* fileName, const int lineNumber)
: fileName_(fileName)
, lineNumber_(lineNumber)
{
}

const char* SourceLine::fileName() const
{
    return fileName_;
}

int SourceLine::lineNumber() const
{
    return lineNumber_;
}

const char* SourceLine::unknownFileName_ = "<unknown>";
const int SourceLine::unknownLineNumber_ = -1;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
TestException::TestException(const SourceLine& sourceLine)
: sourceLine_(sourceLine)
{
}

TestException::~TestException() throw()
{
}

const SourceLine& TestException::sourceLine() const
{
    return sourceLine_;
}

const char* TestException::what() const throw()
{
    return "Unknown TestException";
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
TestConditionException::TestConditionException(const SourceLine& sourceLine, const char* condition)
: Parent(sourceLine)
, condition_(condition)
{
}

TestConditionException::TestConditionException(const TestConditionException& rhs)
: Parent(rhs)
, condition_(rhs.condition_)
{
}

TestConditionException& TestConditionException::operator=(const TestConditionException& rhs)
{
    if (this == &rhs)
        return *this;
    Parent::operator=(rhs);
    condition_ = rhs.condition_;
    return *this;
}

void TestConditionException::message(char* buffer, const unsigned int bufferSize) const
{
    TS_SNPRINTF(buffer, bufferSize - 1, "%s != true", condition_);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename CharType>
TestMessageException<CharType>::TestMessageException(const SourceLine& sourceLine, const CharType* message)
: Parent(sourceLine)
, message_(message)
{
}

template<typename CharType>
TestMessageException<CharType>::TestMessageException(const TestMessageException<CharType>& rhs)
: Parent(rhs)
, message_(rhs.message_)
{
}

template<typename CharType>
TestMessageException<CharType>& TestMessageException<CharType>::operator=(const TestMessageException<CharType>& rhs)
{
    if (this == &rhs)
        return *this;
    Parent::operator=(rhs);
    message_ = rhs.message_;
    return *this;
}

template<typename CharType>
void TestMessageException<CharType>::message(char* buffer, const unsigned int bufferSize) const
{
    ::strncpy(buffer, message_, bufferSize);
}

template<>
void TestMessageException<wchar_t>::message(char* buffer, const unsigned int bufferSize) const
{
    ::wcstombs(buffer, message_, bufferSize);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void makeEqualMessage(char* dst, const unsigned int dstSize,
                  const bool mustBeEqual, const wchar_t* expected, const wchar_t* actual)
{
    size_t writtenBytes = ::wcstombs(dst, expected, dstSize);
    size_t offset = writtenBytes;

    if (offset >= dstSize)
        return;

    const char* equalSign = mustBeEqual ? " != " : " == ";
    const size_t equalSignLen = ::strlen(equalSign);
    ::strncpy(dst + offset, equalSign, equalSignLen);
    offset += equalSignLen;

    if (offset >= dstSize)
        return;

    writtenBytes = ::wcstombs(dst + offset, actual, dstSize - offset);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename T1, typename T2>
TestEqualException<T1, T2>::TestEqualException(const SourceLine& sourceLine,
                                               const T1 expected, const T2 actual,
                                               bool mustBeEqual)
: Parent(sourceLine)
, expected_(expected)
, actual_(actual)
, mustBeEqual_(mustBeEqual)
{
}

template<typename T1, typename T2>
TestEqualException<T1, T2>::~TestEqualException() throw()
{
}

template<typename T1, typename T2>
void TestEqualException<T1, T2>::message(char* buffer, const unsigned int bufferSize) const
{
	TS_SNPRINTF(buffer, bufferSize - 1, mustBeEqual_ ? "%d != %d" : "%d == %d", expected_, actual_);
}

template<>
void TestEqualException<long long, long long>::message(char* buffer, const unsigned int bufferSize) const
{
	TS_SNPRINTF(buffer, bufferSize - 1, mustBeEqual_ ? "%lld != %lld" : "%lld == %lld", expected_, actual_);
}

template<>
void TestEqualException<std::wstring, std::wstring>::message(char* buffer, const unsigned int bufferSize) const
{
    makeEqualMessage(buffer, bufferSize, mustBeEqual_, (L"\"" + expected_ + L"\"").c_str(), (L"\"" + actual_ + L"\"").c_str());
}

template<>
void TestEqualException<std::string, std::string>::message(char* buffer, const unsigned int bufferSize) const
{
	TS_SNPRINTF(buffer, bufferSize - 1, mustBeEqual_ ? "\"%s\" != \"%s\"" : "\"%s\" == \"%s\"", expected_.c_str(), actual_.c_str());
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
TestEqualPointersException::TestEqualPointersException(const SourceLine& sourceLine,
                                               const void* expected, const void* actual,
                                               bool mustBeEqual)
: Parent(sourceLine)
, expected_(expected)
, actual_(actual)
, mustBeEqual_(mustBeEqual)
{
}

TestEqualPointersException::~TestEqualPointersException() throw()
{
}

void TestEqualPointersException::message(char* buffer, const unsigned int bufferSize) const
{
	TS_SNPRINTF(buffer, bufferSize - 1, mustBeEqual_ ? "\"0x%X\" != \"0x%X\"" : "\"0x%X\" == \"0x%X\"",
        reinterpret_cast<unsigned int>(expected_), reinterpret_cast<unsigned int>(actual_));
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename T>
TestDoubleEqualException<T>::TestDoubleEqualException(const SourceLine& sourceLine,
  													  const T expected, const T actual, const T delta,
													  bool mustBeEqual)
: Parent(sourceLine)
, expected_(expected)
, actual_(actual)
, delta_(delta)
, mustBeEqual_(mustBeEqual)
{
}

template<typename T>
void TestDoubleEqualException<T>::message(char* buffer, const unsigned int bufferSize) const
{
	TS_SNPRINTF(buffer, bufferSize - 1, mustBeEqual_ ? "%f != %f +- %f" : "%f == %f +- %f", expected_, actual_, delta_);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool cppunitAssert(const bool condition)
{
    return condition;
}

bool cppunitAssert(const long long int expected, const long long int actual)
{
    return expected == actual;
}

/// \brief All float point types have imprecission, so we must know precission of type for normal check
/// \param[in] delta must be positive
bool cppunitAssert(const long double expected, const long double actual, const long double  delta, const long double typePrecission = 0)
{
    return cppunitAssert((fabs(expected - actual) - fabs(delta)) <= typePrecission);
}

bool cppunitAssert(const float expected, const float actual, const long double delta)
{
    return cppunitAssert(expected, actual, delta, 0.0000001f);
}

bool cppunitAssert(const double expected, const double actual, const long double delta)
{
    return cppunitAssert(expected, actual, delta, 0.000000000000001);
}

bool cppunitAssert(const long double expected, const long double actual, const long double delta)
{
    return cppunitAssert(expected, actual, delta, 0.000000000000001);
}

bool cppunitAssert(const void *expected, const void *actual)
{
	return expected == actual;
}

bool cppunitAssert(const char *expected, const char *actual)
{
	return expected == actual || (NULL != expected && NULL != actual && 0 == ::strcmp(expected, actual));
}

bool cppunitAssert(const wchar_t *expected, const wchar_t *actual)
{
	return expected == actual || (NULL != expected && NULL != actual && 0 == ::wcscmp(expected, actual));
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void YUNIT_API throwException(const SourceLine& sourceLine, const char* condition)
{
    throw TestConditionException(sourceLine, condition);
}

void YUNIT_API throwException(const SourceLine& sourceLine, const char* message, bool)
{
    throw TestMessageException<char>(sourceLine, message);
}

void YUNIT_API throwException(const SourceLine& sourceLine, const wchar_t* message, bool)
{
    throw TestMessageException<wchar_t>(sourceLine, message);
}

void YUNIT_API throwException(const SourceLine& sourceLine, const long long expected, const long long actual, bool mustBeEqual)
{
    throw TestEqualException<long long, long long>(sourceLine, expected, actual, mustBeEqual);
}

void YUNIT_API throwException(const SourceLine& sourceLine, const void* expected, const void* actual, bool mustBeEqual)
{
    throw TestEqualPointersException(sourceLine, expected, actual, mustBeEqual);
}

void YUNIT_API throwException(const SourceLine& sourceLine, const wchar_t* expected, const wchar_t* actual, bool mustBeEqual)
{
    throw TestEqualException<std::wstring, std::wstring>(sourceLine, expected ? expected : L"NULL", actual ? actual : L"NULL", mustBeEqual);
}

void YUNIT_API throwException(const SourceLine& sourceLine, const char* expected, const char* actual, bool mustBeEqual)
{
    throw TestEqualException<std::string, std::string>(sourceLine, expected ? expected : "NULL", actual ? actual : "NULL", mustBeEqual);
}

void YUNIT_API throwException(const SourceLine& sourceLine,
                    const double expected, const double actual, const double delta,
					bool mustBeEqual)
{
    throw TestDoubleEqualException<double>(sourceLine, expected, actual, delta, mustBeEqual);
}

} // namespace YUNIT_NS
