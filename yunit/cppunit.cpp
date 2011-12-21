//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// cppunit.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifdef _MSC_VER
#  define _CRT_SECURE_NO_WARNINGS 1
#  include <excpt.h>
#else
#  include <string.h>
#endif

#ifdef _WIN32
#  include <io.h>
#  define ACCESS_FUNC _access
#  include <windows.h>
#else
#  include <unistd.h> 
#  define ACCESS_FUNC access
#  include <dlfcn.h>
#endif

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

#define YUNIT_DLL_EXPORTS
#include "cppunit.h"
#include "lua_wrapper.h"

namespace YUNIT_NS {

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
const char** getTestContainerExtensions();
    
} // namespace YUNIT_NS

static bool isExist(const char* path);

struct Cppunit {};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
extern "C"
int YUNIT_API luaopen_yunit_cppunit(lua_State* L)
{
    using namespace YUNIT_NS;
    Lua::State lua(L);

    luaWrapper<TestCase>().makeMetatable(lua, MT_NAME(TestCase));
    luaWrapper<Cppunit>().regLib(lua, "yunit.cppunit");
    return 1;
}

LUA_META_METHOD(Cppunit, getTestContainerExtensions)
{
    const char** ext = YUNIT_NS::getTestContainerExtensions();

    Lua::State lua(L);
    
    lua.push(Lua::Table());

    int i = 1;
    while (ext && *ext)
    {
        lua.push(i++); 
        lua.push(*ext++);
        lua.settable(-3);
    }

    return 1;
}

LUA_META_METHOD(Cppunit, loadTestContainer)
{
    using namespace YUNIT_NS;
    
    Lua::State lua(L);
    enum {argIdx = 1};

    if (!lua.isstring(argIdx))
    {
        lua.push(false);
        lua.pushf("expected string as argument type, but was %s", lua.typeName(argIdx));
        return 2;
    }
    
    size_t len;
    const char* testContainerPath = lua.to(1, &len);
    if (0 == len)
    {
        lua.push(false);
        lua.push("empty argument");
        return 2;
    }
    
    if (!isExist(testContainerPath))
    {
        lua.push(false);
        lua.push("file doesn't exist");
        return 2;
    }

    // we load library for initialize global objects, registed test cases during their creation

    class TestCasesRegistry : public TestRegistry
    {
    public:
        void add(TestCase* testCase) { tests_ << testCase; }
        Chain<TestCase*> tests_;
    };
    
    TestCasesRegistry testRegistry;
    TestRegistry::set(&testRegistry);

#if defined(_WIN32)
    if (NULL == ::LoadLibraryExA(testContainerPath, NULL, 0))
    {
        lua.push(false);

        enum {bufferSize = 128};
        char buffer[bufferSize];

        const int error = ::GetLastError();
        if (::FormatMessageA(FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_FROM_SYSTEM, NULL, error, 0, buffer, bufferSize, NULL))
            lua.push(buffer);
        else
            lua.pushf("system error %d\n", error);
        return 2;
    }
#else
    if (NULL == dlopen(testContainerPath, RTLD_NOW | RTLD_GLOBAL))
    {
        lua.push(false);
        lua.push(dlerror());
        return 2;
    }
#endif // WIN32

    if (testRegistry.tests_.rbegin() == testRegistry.tests_.rend())
    {
        lua.push(false);
        lua.pushf("no one test case has been loaded from \"%s\"", testContainerPath);
        return 2;
    }
    
        lua.push(Lua::Table()); // return value
	
	Chain<TestCase*>::ReverseIterator it = testRegistry.tests_.rbegin();
	Chain<TestCase*>::ReverseIterator endIt = testRegistry.tests_.rend();
	
	for (int i = 1; it != endIt; ++it)
	{
	    // every TestCase object is static, so they will be deleted automatically on exit process
        lua.push<TestCase>(*it, MT_NAME(TestCase));
        lua.rawseti(-2, i++);
	}
    
    return 1;
}

static bool isExist(const char* path)
{
    enum {existenceOnlyMode = 0, notAccessible = -1};
    return notAccessible != ACCESS_FUNC(path, existenceOnlyMode);
}

namespace YUNIT_NS {

static int callTestCaseThunk(lua_State* L, TestCase* testCase, Thunk thunk);
static bool wereCatchedCppExceptions(lua_State* L, TestCase* testCase, Thunk thunk, int& countReturnValues);
static int luaPushErrorObject(lua_State* L, const SourceLine& source, const char* message);

LUA_META_METHOD(TestCase, setUp)
{
    Lua::State lua(L);

    TestCase* tc; lua.to<TestCase>(1, &tc);
    return callTestCaseThunk(lua, tc, tc->setUpThunk());
}

LUA_META_METHOD(TestCase, test)
{
    Lua::State lua(L);

    TestCase* tc; lua.to<TestCase>(1, &tc);
    return callTestCaseThunk(lua, tc, tc->testThunk());
}

LUA_META_METHOD(TestCase, tearDown)
{
    Lua::State lua(L);

    TestCase* tc; lua.to<TestCase>(1, &tc);
    return callTestCaseThunk(lua, tc, tc->tearDownThunk());
}

LUA_META_METHOD(TestCase, isIgnored)
{
    Lua::State lua(L);
    
    TestCase* tc; lua.to<TestCase>(1, &tc);
    lua.push(tc->isIgnored());
    return 1;
}

LUA_META_METHOD(TestCase, lineNumber)
{
    Lua::State lua(L);

    TestCase* tc; lua.to<TestCase>(1, &tc);
    lua.push(tc->source().lineNumber());
    return 1;
}

LUA_META_METHOD(TestCase, fileName)
{
    Lua::State lua(L);

    TestCase* tc; lua.to<TestCase>(1, &tc);
    lua.push(tc->source().fileName());
    return 1;
}

LUA_META_METHOD(TestCase, name)
{
    Lua::State lua(L);

    TestCase* tc; lua.to<TestCase>(1, &tc);
    lua.pushf("%s::%s", tc->source().fileName(), tc->name());
    return 1;
}

static int callTestCaseThunk(lua_State* L, TestCase* testCase, Thunk thunk)
{
    Lua::State lua(L);
    bool thereAreCppExceptions = false;
    int countReturnValues = 0;
#ifdef _MSC_VER
    __try
    {
        thereAreCppExceptions = wereCatchedCppExceptions(lua, testCase, thunk, countReturnValues);
    }
    __except(EXCEPTION_EXECUTE_HANDLER)
    {
		lua.push(false); // status code
        countReturnValues = 1;
        countReturnValues += luaPushErrorObject(lua, testCase->source(), "Unexpected SEH exception was caught");
    }
#else // not defined _MSC_VER
    thereAreCppExceptions = wereCatchedCppExceptions(lua, testCase, thunk, countReturnValues);
#endif
    if (!thereAreCppExceptions)
    {
        // status code
	    lua.push(true);
        ++countReturnValues;
        countReturnValues += luaPushErrorObject(lua, testCase->source(), "");
    }

    return countReturnValues;
}

/// \todo Return (un)success result status and ErrorObject
static bool wereCatchedCppExceptions(lua_State* L, TestCase* testCase, Thunk thunk, int& countReturnValues)
{
    Lua::State lua(L);
    countReturnValues = 0;
    try
    {
        thunk.invoke();
    }
	catch (TestException& ex)
    {
		enum {bufferSize = 1024 * 5};
		char errorMessage[bufferSize] = {'\0'};
		ex.message(errorMessage, bufferSize);

		lua.push(false);
        countReturnValues += 1 + luaPushErrorObject(lua, ex.sourceLine(), errorMessage);
		return true;
    }
    catch(std::exception& ex)
    {
        enum {bufferSize = 1024 * 5};
        char errorMessage[bufferSize] = {'\0'};
        TS_SNPRINTF(errorMessage, bufferSize - 1, "Unexpected std::exception was caught: %s", ex.what());

        lua.push(false);
        countReturnValues += 1 + luaPushErrorObject(lua, testCase->source(), errorMessage);
		return true;
    }
    catch(...)
    {
        lua.push(false);
        countReturnValues += 1 + luaPushErrorObject(lua,
            testCase->source(), "Unexpected unknown C++ exception was caught");
		return true;
	}

	return false;
}

static int luaPushErrorObject(lua_State* L,
                              const SourceLine& source,
                              const char* message)
{
    Lua::State lua(L);

    lua.push(Lua::Table()); // new Error Object 
    
    lua.push(source.fileName());       // source file with error
    lua.setfield(-2, "source");
    
    lua.push(source.lineNumber());     // number of line with error
    lua.setfield(-2, "line");
    
    lua.push(message);         // error message
    lua.setfield(-2, "message");

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
TestRegistry* TestRegistry::this_ = 0;

TestRegistry* TestRegistry::get()
{
	return this_;
}

void TestRegistry::set(TestRegistry* instanse)
{
    this_ = instanse;
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
