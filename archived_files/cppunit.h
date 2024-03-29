//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// cppunit.h
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if _MSC_VER > 1000
#  pragma once
#endif

#ifndef _CPPUNIT_TEST_HEADER_
#define _CPPUNIT_TEST_HEADER_

#ifdef _MSC_VER
// Two or more members have the same name. The one in class2 is inherited because it is a base class for the
// other classes that contained this member.
// This situation with TestFixture and TestCase, inherited from it
#  pragma warning(disable : 4250)
#endif

#include "yunit.h"
#include <string>

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define test(name)\
    test_(name)\
    registerTest(name, YUNIT_SOURCELINE())\
    testBodyDef(name)

#define test1(name, usedFixture)\
    test1_(name, fixtureName(usedFixture))\
    registerTest(name, YUNIT_SOURCELINE())\
    testBodyDef(name)

#define test2(name, usedFixture1, usedFixture2)\
    fixture2(fixtureName2(name, usedFixture1, usedFixture2),\
             fixtureName(usedFixture1),\
             fixtureName(usedFixture2))\
    test1_(name, fixtureName2(name, usedFixture1, usedFixture2))\
    registerTest(name, YUNIT_SOURCELINE())\
    testBodyDef(name)

#define _test(name)\
    test_(name)\
    registerIgnoredTest(name, YUNIT_SOURCELINE())\
    ignoredTestBodyDef(name)

#define _test1(name, usedFixture)\
    test_(name)\
    registerIgnoredTest(name, YUNIT_SOURCELINE())\
    ignoredTestBodyDef(name)

#define _test2(name, usedFixture1, usedFixture2)\
    test_(name)\
    registerIgnoredTest(name, YUNIT_SOURCELINE())\
    ignoredTestBodyDef(name)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define example(name)\
    test_(name)\
    testBodyDef(name) {}\
    void example##name()

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define todo(name)\
    test_(name)\
    registerTest(name, YUNIT_SOURCELINE())\
    testBodyDef(name)\
    {\
        throwException(YUNIT_SOURCELINE(), "You want to make this test as soon as possible", true);\
    }\
    void futureTest##name()


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ASSERTS

#define isNull(actual)\
    if(!YUNIT_NS::cppunitAssert(0 == (actual)))\
        YUNIT_NS::throwException(YUNIT_SOURCELINE(), #actual " is not NULL", false)

#define isNotNull(actual)\
    if(!YUNIT_NS::cppunitAssert((actual) != NULL))\
        YUNIT_NS::throwException(YUNIT_SOURCELINE(), #actual " is NULL", false)

#define isTrue(condition)\
    if(!YUNIT_NS::cppunitAssert(condition))\
        YUNIT_NS::throwException(YUNIT_SOURCELINE(), #condition)

#define isFalse(condition)\
    if(YUNIT_NS::cppunitAssert(condition))\
        YUNIT_NS::throwException(YUNIT_SOURCELINE(), #condition " != false", false)

#define areEq(expected, actual)\
    if(!YUNIT_NS::cppunitAssert((expected), (actual)))\
        YUNIT_NS::throwException(YUNIT_SOURCELINE(), (expected), (actual), true)

#define areNotEq(expected, actual)\
    if(YUNIT_NS::cppunitAssert((expected), (actual)))\
        YUNIT_NS::throwException(YUNIT_SOURCELINE(), (expected), (actual), false)

#define areDoubleEq(expected, actual, delta)\
    if(!YUNIT_NS::cppunitAssert((expected), (actual), (delta)))\
        YUNIT_NS::throwException(YUNIT_SOURCELINE(), (expected), (actual), (delta), true)

#define areDoubleNotEq(expected, actual, delta)\
    if(YUNIT_NS::cppunitAssert((expected), (actual), (delta)))\
        YUNIT_NS::throwException(YUNIT_SOURCELINE(), (expected), (actual), (delta), false)

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
            YUNIT_NS::throwException(YUNIT_SOURCELINE(),												\
            "Expected exception \"" #exceptionType "\" has not been thrown", true);						\
        }                                                                                                   \
    }

#define noSpecificThrow(expression, exceptionType)														\
    try																									\
    {																									\
        expression;																						\
    }																									\
    catch(const exceptionType&)																			\
    {																									\
        YUNIT_NS::throwException(YUNIT_SOURCELINE(),													\
            "Not expected exception \"" #exceptionType "\" has been thrown", true);			\
    }

#define noAnyCppThrow(expression)														\
    try																									\
    {																									\
        expression;																						\
    }																									\
    catch(...)																			\
    {																									\
        YUNIT_NS::throwException(YUNIT_SOURCELINE(),													\
            "Unwanted C++ exception has been thrown", true);			\
    }

#define noSehThrow(expression)																	\
    __try																									\
    {																										\
        expression;																							\
    }																										\
    __except(EXCEPTION_EXECUTE_HANDLER)																		\
    {																										\
        YUNIT_NS::throwException(YUNIT_SOURCELINE(), "Unwanted SEH exception has been thrown", true);		\
    }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define CONCAT(a, b) a ## b
#define CONCAT2(x, y) CONCAT(x, y)
#define UNIQUENAME(prefix) CONCAT2(prefix, __COUNTER__)

#define UNIQUE_REGISTER_NAME(name) Register ## name
#define UNIQUE_TEST_NAMESPACE(name) name ## Namespace

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define YUNIT_SOURCELINE()   YUNIT_NS::SourceLine(__FILE__, __LINE__)

#define fixtureName(name) name ## Fixture
#define fixtureName2(name, name1, name2) fixtureName(name ## name1 ## name2)

#define fixture(name)\
    struct fixtureName(name) : public virtual YUNIT_NS::Fixture

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
    struct TestCase__##name : public YUNIT_NS::TestCase\
    {\
        TestCase__##name(const char* name, bool isIgnored, const YUNIT_NS::SourceLine& source)\
        : YUNIT_NS::TestCase(name, isIgnored, source)\
        {}\
        virtual void innerSetUp() {}\
        virtual void execute();\
        virtual void innerTearDown() {}\
    };

#define test1_(name, usedFixture)\
    struct TestCase__##name : public YUNIT_NS::TestCase, public usedFixture\
    {\
        TestCase__##name(const char* name, bool isIgnored, const YUNIT_NS::SourceLine& source)\
        : YUNIT_NS::TestCase(name, isIgnored, source)\
        {}\
        virtual void execute();\
    };

#define registerTest(name, source)\
    YUNIT_NS::RegisterTestCase<TestCase__##name> UNIQUENAME(name)(#name, source);

#define registerIgnoredTest(name, source)\
    YUNIT_NS::RegisterIgnoredTestCase<TestCase__##name> UNIQUENAME(name)(#name, source);

#define testBodyDef(name)\
    void TestCase__##name::execute()

#define ignoredTestBodyDef(name)\
    void TestCase__##name::execute() {}\
    template<typename T> void TestCase ## name ## Fake()

namespace YUNIT_NS {

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class YUNIT_API Thunk
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
class YUNIT_API SourceLine
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
template<typename T>
class Chain
{
public:
    struct Node
    {
        T value_;
        Node* next_;
    };

    class ReverseIterator
    {
    public:
        ReverseIterator(Node* node);
        ReverseIterator operator++();
        bool operator==(const ReverseIterator& it);
        bool operator!=(const ReverseIterator& it);
        T operator*();
    private:
        Node* node_;
    };

public:
    Chain();
    ~Chain();
    Chain& operator<<(const T& value);
    unsigned int size() const;
    void clear();

    ReverseIterator rbegin();
    ReverseIterator rend();

private:
    Node* tail_;
    unsigned int size_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class YUNIT_API Test
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
class YUNIT_API Fixture
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
class YUNIT_API TestCase : public Test
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
    const char* name_;
    bool isIgnored_;
    SourceLine source_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class TestRegistry
{
public:
    YUNIT_API static TestRegistry* get();
    static void set(TestRegistry* instanse);
    
    YUNIT_API virtual void add(TestCase* testCase) = 0;

protected:
    TestRegistry() {}
    virtual ~TestRegistry() {}
    
protected:
    static TestRegistry* this_;
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
class YUNIT_API TestException : public std::exception
{
public:
    virtual ~TestException() throw();
    const SourceLine& sourceLine() const;

    virtual void message(char* buffer, const unsigned int bufferSize) const = 0;

    const char* what() const throw();

protected:
    TestException(const SourceLine& sourceLine);

private:
    SourceLine sourceLine_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool YUNIT_API cppunitAssert(const bool condition);

bool YUNIT_API cppunitAssert(const long long int expected, const long long int actual);


/// \param[in] delta must be at [0.000000000000001, +INFINITE) for long double comparison
bool YUNIT_API cppunitAssert(const long double expected, const long double actual, const long double delta);

/// \param[in] delta must be at [0.000000000000001, +INFINITE) for double comparison
bool YUNIT_API cppunitAssert(const double expected, const double actual, const long double delta);

/// \param[in] delta must be at [0.00000001f, +INFINITE) for float comparison
bool YUNIT_API cppunitAssert(const float expected, const float actual, const long double delta);

bool YUNIT_API cppunitAssert(const void *expected, const void *actual);

bool YUNIT_API cppunitAssert(const char *expected, const char *actual);
bool YUNIT_API cppunitAssert(const wchar_t *expected, const wchar_t *actual);

inline bool YUNIT_API cppunitAssert(const std::wstring& expected, const std::wstring& actual) {
    return cppunitAssert(expected.c_str(), actual.c_str());
}

inline bool YUNIT_API cppunitAssert(const std::string& expected, const std::string& actual) {
    return cppunitAssert(expected.c_str(), actual.c_str());
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void YUNIT_API throwException(const SourceLine& sourceLine, const char* condition);
void YUNIT_API throwException(const SourceLine& sourceLine, const char* message, bool);

void YUNIT_API throwException(const SourceLine& sourceLine, const void* expected, const void* actual,
        bool mustBeEqual);

void YUNIT_API throwException(const SourceLine& sourceLine, const long long expected, const long long actual,
        bool mustBeEqual);
void YUNIT_API throwException(const SourceLine& sourceLine, const char* expected, const char* actual,
        bool mustBeEqual);

inline void YUNIT_API throwException(const SourceLine& sourceLine,
        const std::string& expected,
        const std::string& actual,
        bool mustBeEqual) {
    throwException(sourceLine, expected.c_str(), actual.c_str(), mustBeEqual);
}

void YUNIT_API throwException(const SourceLine& sourceLine, const wchar_t* expected, const wchar_t* actual,
        bool mustBeEqual);

inline void YUNIT_API throwException(const SourceLine& sourceLine,
        const std::wstring& expected,
        const std::wstring& actual,
        bool mustBeEqual) {
    throwException(sourceLine, expected.c_str(), actual.c_str(), mustBeEqual);
}

void YUNIT_API throwException(const SourceLine& sourceLine, const double expected, const double actual,
        const double delta, bool mustBeEqual);


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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename TestCaseClass>
RegisterTestCase<TestCaseClass>::RegisterTestCase(const char* name,
                                                  const SourceLine& source)
{
    const bool ignore = true;
    static TestCaseClass testcase(name, !ignore, source);
    TestRegistry::get()->add(&testcase);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename TestCaseClass>
RegisterIgnoredTestCase<TestCaseClass>::RegisterIgnoredTestCase(const char* name,
                                                                const SourceLine& source)
{
    const bool ignore = true;
    static TestCaseClass testcase(name, ignore, source);
    TestRegistry::get()->add(&testcase);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename T>
Chain<T>::Chain()
: size_(0)
, tail_(0)
{
}

template<typename T>
Chain<T>::~Chain()
{
    clear();
}

template<typename T>
void Chain<T>::clear()
{
    Node* tmp;
    while (tail_)
    {
        tmp = tail_->next_;
        delete tail_;
        tail_ = tmp;
    }
}

template<typename T>
Chain<T>& Chain<T>::operator<<(const T& value)
{
    Node* node = new Node;
    node->value_ = value;
    node->next_ = tail_;
    tail_ = node;
    ++size_;

    return *this;
}

template<typename T>
unsigned int Chain<T>::size() const
{
    return size_;
}

template<typename T>
typename Chain<T>::ReverseIterator Chain<T>::rbegin()
{
    return ReverseIterator(tail_);
}


template<typename T>
typename Chain<T>::ReverseIterator Chain<T>::rend()
{
    return ReverseIterator(NULL);
}

template<typename T>
Chain<T>::ReverseIterator::ReverseIterator(Node* node)
: node_(node)
{
}

template<typename T>
typename Chain<T>::ReverseIterator Chain<T>::ReverseIterator::operator++()
{
    if (node_)
        node_ = node_->next_;
    return *this;
}

template<typename T>
bool Chain<T>::ReverseIterator::operator==(const ReverseIterator& it)
{
    return node_ == it.node_;
}

template<typename T>
bool Chain<T>::ReverseIterator::operator!=(const ReverseIterator& it)
{
    return node_ != it.node_;
}

template<typename T>
T Chain<T>::ReverseIterator::operator*()
{
    return node_ ? node_->value_ : 0;
}

} // namespace YUNIT_NS

#endif // _CPPUNIT_TEST_HEADER_
