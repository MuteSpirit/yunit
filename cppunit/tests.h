//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// @file tests.h
//
// Contain macro for unit test registration
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef _TESTS_YUNIT_HEADER_
#define _TESTS_YUNIT_HEADER_

#include "../yunit/yunit.h"
#include <cstddef>
#include <cstdio>

YUNIT_NS_BEGIN

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define TEST(name)\
    struct TestCase__##name : YUNIT_NS_PREF(Test)\
    {\
        virtual void testBody();\
    };\
    registerTest(name, YUNIT_SOURCELINE())\
    void TestCase__##name::testBody()

/// @param name test name
/// @param ... list of fixtures, separated with column (','). 
/// Fixtures's constructors play 'setUp' role, and destructors - 'tearDown' role
/// You may use as fixtures a structs or classes with all members, situated in public or protected sections, 
/// because at such conditions test body can access then without any additional accessors.
/// @code
/// struct Fixture
/// {
///     unsigned int value_;
/// 
///     Fixture()  // a'la setUp
///     : value_(0)
///     {}
/// 
///     ~Fixture() // a'la tearDown
///     {}
/// };
/// 
/// TEST1(, Fixture)
/// {
///     isNull(value_);
/// }
/// @endcode
//
#define TEST1(name, ...)\
    struct TestCase__##name : YUNIT_NS_PREF(Test), __VA_ARGS__\
    {\
        virtual void testBody();\
    };\
    registerTest(name, YUNIT_SOURCELINE())\
    void TestCase__##name::testBody()

/// @brief Register ignored test
#define _TEST(name)\
    YUNIT_NS_PREF(RegisterIgnoredTestCase) UNIQUENAME(name)(#name, YUNIT_SOURCELINE());\
    template<typename T> void TestCase ## name ## Fake()
    
#define registerTest(name, source)\
    YUNIT_NS_PREF(RegisterTestCase)<TestCase__##name> UNIQUENAME(name)(#name, source);\

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define CONCAT(a, b) a ## b
#define CONCAT2(x, y) CONCAT(x, y)
#define UNIQUENAME(prefix) CONCAT2(prefix, __COUNTER__)

#define UNIQUE_REGISTER_NAME(name) Register ## name
#define UNIQUE_TEST_NAMESPACE(name) name ## Namespace

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define YUNIT_SOURCELINE()   YUNIT_NS_PREF(SourceLine)(__FILE__, __LINE__)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class SourceLine
{
public:
    SourceLine(const char* fileName, const int lineNumber);

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
class Thunk
{
public:
    Thunk();

    template<typename T, void (T::* funcPtr)()>
    static Thunk create(T* thisPtr);

    void invoke();

private:
    Thunk(void (* thunkPtr)(void*), void* thisPtr);

    template<typename T, void (T::* funcPtr)()>
    static void thunk(void* thisPtr);

    void (* thunkPtr_)(void*);
    void* thisPtr_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct Test
{
    virtual void testBody() = 0;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct TestCase : Test
{
    typedef TestCase Self;

    virtual ~TestCase();

    virtual void setUp() = 0;
    virtual void tearDown() = 0;
    virtual bool ignored() = 0;

    const char *name_;
    SourceLine source_;

    Thunk setUpThunk_;
    Thunk testBodyThunk_;
    Thunk tearDownThunk_;
    
protected:
    TestCase(const char* name, const SourceLine& source);
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Interface class has no virtual destructor, so you must not use TestRegistry* pointers to destroy objects
// of derived classes
struct TestRegistry
{
    virtual void add(TestCase* testCase) = 0;
    virtual void executeAllTests(void (*callback)(void *ctx, void *arg, void *data), void *ctx) = 0;

    static const char *ignored; // const TestCase* will be passed as 'data' argument of 'callback'
    static const char *success; // const TestCase* will be passed as 'data' argument of 'callback'
    static const char *fail;    // FailCtx* will be passed as 'data' argument of 'callback'

    // FailCtx object will be passed as 'data' argument of 'callback' function, that must delete 'errmsg_' and 'FailCtx'
    struct FailCtx
    {
        const TestCase *test_;
        char *errmsg_;

        FailCtx(const TestCase *test, char *errmsg)
        : test_(test)
        , errmsg_(errmsg)
        {}
    };
};

// instead of pattern 'Monotone' use 'Singleton' pattern with public pointer to singleton object, because it is
// more simple to change architecture for sintax 'singleton->method()', than 'Singleton::method()'
extern TestRegistry *testRegistry;

// object, that adding tests into test registry, will be static variables. Firstly created of them must initialize
// test registry 
void initTestRegistry();

// destroy TestReginsty singleton object, for example, at exiting process
void delTestRegistry();

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// @brief Register test case and delay original type object creation until execution
/// @param TestClass type of real test class
template<typename TestClass>
struct RegisterTestCase : TestCase
{
    RegisterTestCase(const char* name, const SourceLine& source)
    : TestCase(name, source)
    , test_(NULL)
    {
        initTestRegistry();
        testRegistry->add(this);
    }

    virtual bool ignored()
    {
        return false;
    }

    ~RegisterTestCase()
    {
        delete test_;
    }

    virtual void setUp()
    {
        test_ = new TestClass;
    }

    virtual void testBody()
    {
        test_->testBody();
    }

    virtual void tearDown()
    {
        delete test_;
        test_ = NULL;
    }

    Test *test_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Ignored test must not execute, so we may create stub TestCase instead of original type
struct RegisterIgnoredTestCase : TestCase
{
    RegisterIgnoredTestCase(const char* name, const SourceLine& source)
    : TestCase(name, source)
    {
        initTestRegistry();
        testRegistry->add(this);
    }

    virtual bool ignored()
    {
        return true;
    }

    virtual void setUp()    {}
    virtual void testBody() {}
    virtual void tearDown() {}
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Templates implementation
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename T, void (T::* funcPtr)()>
Thunk Thunk::create(T* thisPtr)
{
    return Thunk(&thunk<T, funcPtr>, thisPtr);
}

template<typename T, void (T::* funcPtr)()>
void Thunk::thunk(void* thisPtr)
{
    (static_cast<T*>(thisPtr)->*funcPtr)();
}


YUNIT_NS_END

#endif // _TESTS_YUNIT_HEADER_
 
