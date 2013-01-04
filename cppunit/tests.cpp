//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// tests.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "tests.h"
#include <stdexcept>
#include <cstring>

YUNIT_NS_BEGIN

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
static bool catchCppExceptions(TestCase *testCase, Thunk thunk, char **data);

static bool callTestCaseThunk(TestCase *testCase, Thunk thunk, char **data)
{
    bool caught = false;
#ifdef _MSC_VER
    __try
    {
#endif
        caught = catchCppExceptions(testCase, thunk, data);

#ifdef _MSC_VER
    }
    __except(EXCEPTION_EXECUTE_HANDLER)
    {
        caught = true;

#define UNEXPECTED_SEH_CAUGHT "Unexpected SEH exception was caught"
        enum {dataSize = sizeof(UNEXPECTED_SEH_CAUGHT)};
        *data = new char[dataSize];
        ::memcpy(*data, UNEXPECTED_SEH_CAUGHT, dataSize);
#undef UNEXPECTED_SEH_CAUGHT
    }
#endif

    return !caught;
}

static bool catchCppExceptions(TestCase *testCase, Thunk thunk, char **data)
{
    try
    {
        thunk.invoke();
    }
    catch (std::exception& ex)
    {
        const char *errmsg = ex.what();
        const size_t len = ::strlen(errmsg);
        *data = new char[len + 1/* \0 */];
        ::memcpy(*data, errmsg, len);
        (*data)[len] = '\0';
        return true;
    }
    catch (...)
    {
#define UNEXPECTED_CPP_EXCEPTION "Unexpected unknown C++ exception was caught"
        enum {dataSize = sizeof(UNEXPECTED_CPP_EXCEPTION)};
        *data = new char[dataSize];
        ::memcpy(*data, UNEXPECTED_CPP_EXCEPTION, dataSize);
#undef UNEXPECTED_CPP_EXCEPTION
		return true;
	}

    *data = NULL;
	return false;
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
const char* TestCase::unknownFileName_ = "<unknown>";
const int TestCase::unknownLineNumber_ = -1;

TestCase::TestCase(const char* name, const char *fileName, const int lineNumber)
: name_(name)
, fileName_(fileName)
, lineNumber_(lineNumber)
{
    setUpThunk_ = Thunk::create<Self, &Self::setUp>(this);
    testBodyThunk_ = Thunk::create<Test, &Test::testBody>(dynamic_cast<Test*>(this));
    tearDownThunk_ = Thunk::create<Self, &Self::tearDown>(this);
}

TestCase::~TestCase()
{}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
TestRegistry *testRegistry = NULL;

const char* TestRegistry::ignored = "ignored";
const char* TestRegistry::success = "success";
const char* TestRegistry::fail = "fail";

struct TestRegistryImpl : TestRegistry
{
    virtual void add(TestCase* testCase)
    {
        tests_ << testCase;
    }

    virtual void executeAllTests(void (*callback)(void *ctx, void *arg, void *data), void *ctx)
    {
        for (Chain<TestCase*>::ReverseIterator it = tests_.rbegin(), endIt = tests_.rend(); it != endIt; ++it)
        {
            TestCase *test = *it;
            char *errmsg = NULL;
            bool testRes = false;
            bool tearDownRes = false;

            if (test->ignored())
                callback(ctx, const_cast<char*>(TestRegistry::ignored), test);
            else
            {
                if (callTestCaseThunk(test, test->setUpThunk_, &errmsg))
                {
                    testRes = callTestCaseThunk(test, test->testBodyThunk_, &errmsg);
                    if (!testRes)
                        callback(ctx, const_cast<char*>(TestRegistry::fail), new TestRegistry::FailCtx(test, errmsg));

                    tearDownRes = callTestCaseThunk(test, test->tearDownThunk_, &errmsg);
                    if (!tearDownRes)
                        callback(ctx, const_cast<char*>(TestRegistry::fail), new TestRegistry::FailCtx(test, errmsg));

                    if (testRes && tearDownRes)
                        callback(ctx, const_cast<char*>(TestRegistry::success), test);
                }
                else
                    callback(ctx, const_cast<char*>(TestRegistry::fail), new TestRegistry::FailCtx(test, errmsg));
            }
        }
    }

    Chain<TestCase*> tests_;
};

void initTestRegistry()
{
    if (NULL == testRegistry)
        testRegistry = new TestRegistryImpl;
}

void delTestRegistry()
{
    delete testRegistry;
    testRegistry = NULL;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename T>
Chain<T>::Chain()
: tail_(NULL)
, size_(0)
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

YUNIT_NS_END
