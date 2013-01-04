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
    registerTest(name, __FILE__, __LINE__)\
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
    registerTest(name, __FILE__, __LINE__)\
    void TestCase__##name::testBody()

/// @brief Register ignored test
#define _TEST(name)\
    YUNIT_NS_PREF(RegisterIgnoredTestCase) UNIQUENAME(name)(#name, __FILE__, __LINE__);\
    template<typename T> void TestCase ## name ## Fake()
    
#define registerTest(name, fileName, lineNumber)\
    YUNIT_NS_PREF(RegisterTestCase)<TestCase__##name> UNIQUENAME(name)(#name, fileName, lineNumber);\

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define CONCAT(a, b) a ## b
#define CONCAT2(x, y) CONCAT(x, y)
#define UNIQUENAME(prefix) CONCAT2(prefix, __COUNTER__)

#define UNIQUE_REGISTER_NAME(name) Register ## name
#define UNIQUE_TEST_NAMESPACE(name) name ## Namespace


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
    const char* fileName_;
    const int lineNumber_;

    static const char* unknownFileName_;
    static const int unknownLineNumber_;
    
protected:
    TestCase(const char* name, const char* fileName, const int lineNumber);
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
    RegisterTestCase(const char* name, const char* fileName, const int lineNumber)
    : TestCase(name, fileName, lineNumber)
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
    RegisterIgnoredTestCase(const char* name, const char* fileName, const int lineNumber)
    : TestCase(name, fileName, lineNumber)
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

YUNIT_NS_END

#endif // _TESTS_YUNIT_HEADER_
 
