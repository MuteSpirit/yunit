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
    TEST_(name)\
    registerTest(name, YUNIT_SOURCELINE())\
    testBodyDef(name)

#define TEST1(name, usedFixture)\
    TEST1_(name, fixtureName(usedFixture))\
    registerTest(name, YUNIT_SOURCELINE())\
    testBodyDef(name)

#define TEST2(name, usedFixture1, usedFixture2)\
    fixture2(fixtureName2(name, usedFixture1, usedFixture2),\
             fixtureName(usedFixture1),\
             fixtureName(usedFixture2))\
    TEST1_(name, fixtureName2(name, usedFixture1, usedFixture2))\
    registerTest(name, YUNIT_SOURCELINE())\
    testBodyDef(name)

#define _TEST(name)\
    TEST_(name)\
    registerIgnoredTest(name, YUNIT_SOURCELINE())\
    ignoredTestBodyDef(name)

#define _TEST1(name, usedFixture)\
    TEST_(name)\
    registerIgnoredTest(name, YUNIT_SOURCELINE())\
    ignoredTestBodyDef(name)

#define _TEST2(name, usedFixture1, usedFixture2)\
    TEST_(name)\
    registerIgnoredTest(name, YUNIT_SOURCELINE())\
    ignoredTestBodyDef(name)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define CONCAT(a, b) a ## b
#define CONCAT2(x, y) CONCAT(x, y)
#define UNIQUENAME(prefix) CONCAT2(prefix, __COUNTER__)

#define UNIQUE_REGISTER_NAME(name) Register ## name
#define UNIQUE_TEST_NAMESPACE(name) name ## Namespace

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define YUNIT_SOURCELINE()   YUNIT_NS_PREF(SourceLine)(__FILE__, __LINE__)

#define fixtureName(name) name ## Fixture
#define fixtureName2(name, name1, name2) fixtureName(name ## name1 ## name2)

#define FIXTURE(name)\
    struct fixtureName(name) : public virtual YUNIT_NS_PREF(Fixture)

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

#define SETUP()\
    virtual void innerSetUp()

#define TEARDOWN()\
    virtual void innerTearDown()

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define TEST_(name)\
    struct TestCase__##name : public YUNIT_NS_PREF(TestCase)\
    {\
        TestCase__##name(const char* name, bool isIgnored, const YUNIT_NS_PREF(SourceLine)& source)\
        : YUNIT_NS_PREF(TestCase)(name, isIgnored, source)\
        {}\
        virtual void innerSetUp() {}\
        virtual void execute();\
        virtual void innerTearDown() {}\
    };

#define TEST1_(name, usedFixture)\
    struct TestCase__##name : public YUNIT_NS_PREF(TestCase), public usedFixture\
    {\
        TestCase__##name(const char* name, bool isIgnored, const YUNIT_NS_PREF(SourceLine)& source)\
        : YUNIT_NS_PREF(TestCase)(name, isIgnored, source)\
        {}\
        virtual void execute();\
    };

#define registerTest(name, source)\
    YUNIT_NS_PREF(RegisterTestCase)<TestCase__##name> UNIQUENAME(name)(#name, source);

#define registerIgnoredTest(name, source)\
    YUNIT_NS_PREF(RegisterIgnoredTestCase)<TestCase__##name> UNIQUENAME(name)(#name, source);

#define testBodyDef(name)\
    void TestCase__##name::execute()

#define ignoredTestBodyDef(name)\
    void TestCase__##name::execute() {}\
    template<typename T> void TestCase ## name ## Fake()


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
class Test
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
class Fixture
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
class TestCase : public Test
               , public virtual Fixture
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
    const char *name_;
    bool isIgnored_;
    SourceLine source_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Interface class has no virtual destructor, so you must not use TestRegistry* pointers to destroy objects
// of derived classes
struct TestRegistry
{
    virtual void add(TestCase* testCase) = 0;
    virtual void executeAllTests(void (*callback)(void *ctx, void *arg, void *data), void *ctx) = 0;

    static char *ignored, *success, *fail;

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
template<typename TestCaseClass>
struct RegisterTestCase : TestCase
{
    RegisterTestCase(const char* name, const SourceLine& source)
    : TestCase(name, false /* not ignore */, source)
    , testCase_(NULL)
    {
        initTestRegistry();
        testRegistry->add(this);
    }

    ~RegisterTestCase()
    {
        delete testCase_;
    }

    void createTestCase()
    {
        testCase_ = new TestCaseClass(name(), isIgnored(), source());
    }

    virtual void innerSetUp()
    {
        if (NULL == testCase_)
            createTestCase();
        testCase_->innerSetUp();
    }

    virtual void execute()
    {
        if (NULL == testCase_)
            createTestCase();
        testCase_->execute();
    }

    virtual void innerTearDown()
    {
        if (NULL == testCase_)
            createTestCase();
        testCase_->innerTearDown();
    }

    TestCase *testCase_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Ignored test must not execute, so we may create stub TestCase instead of original type
struct RegisterIgnoredTestCase : TestCase
{
    RegisterIgnoredTestCase(const char* name, const SourceLine& source)
    : TestCase(name, true /* ignored */, source)
    {
        initTestRegistry();
        testRegistry->add(this);
    }

    virtual void innerSetUp()    {}
    virtual void execute()       {}
    virtual void innerTearDown() {}
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
 
