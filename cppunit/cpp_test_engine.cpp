#define TUE_LIB
#include "test_engine_interface.h"
#include <memory.h>

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
template<typename T, typename Arg, void (T::*method)(Arg)>
void methodAdapter(void *t, Arg arg)
{
    (static_cast<T*>(t)->*method)(arg);
}

template<typename T, void (T::*method)()>
void methodAdapter(void *t)
{
    (static_cast<T*>(t)->*method)();
}

template<typename RetT, typename T, RetT (T::*method)()>
RetT methodAdapter(void *t)
{
    return (static_cast<T*>(t)->*method)();
}

template<typename RetT, typename T, RetT (T::*method)() const>
RetT methodAdapter(const void *t)
{
    return (static_cast<const T*>(t)->*method)();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct CppTestContainer
{
    unsigned int numberOfTests();
    void load(TestCasePtr testList); 
    void unload(TestCasePtr testList); 
    const char* errMsg(); 
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct CppTestCase
{
    bool setUp();
    bool testBody();               
    bool tearDown(); 
    void error(TestErrorPtr errorInfo); 
    int ignored() const;
    const char* name() const;
    const char* source() const;
    int line() const;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct CppTestError
{
    const char* source() const;
    int line() const;
    const char* errMsg() const;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
TUE_API void loadTestContainer(TestContainerPtr tcPtr, const char *path)
{
    tcPtr->self_ = new CppTestContainer;
    tcPtr->numberOfTests_ = methodAdapter<unsigned int, CppTestContainer, &CppTestContainer::numberOfTests>;
    tcPtr->load_          = methodAdapter<CppTestContainer, TestCasePtr, &CppTestContainer::load>;
    tcPtr->unload_        = methodAdapter<CppTestContainer, TestCasePtr, &CppTestContainer::unload>;
    tcPtr->errMsg_        = methodAdapter<const char*, CppTestContainer, &CppTestContainer::errMsg>;
}

TUE_API void unloadTestContainer(TestContainerPtr tcPtr)
{
    delete static_cast<CppTestContainer*>(tcPtr->self_);
    ::memset(tcPtr, 0, sizeof(TestContainer));
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
unsigned int CppTestContainer::numberOfTests()
{
    return 1;
}

void CppTestContainer::load(TestCasePtr testList) 
{
    testList->self_     = new CppTestCase;
    testList->setUp_    = methodAdapter<bool, CppTestCase, &CppTestCase::setUp>;
    testList->testBody_ = methodAdapter<bool, CppTestCase, &CppTestCase::testBody>;
    testList->tearDown_ = methodAdapter<bool, CppTestCase, &CppTestCase::tearDown>;
    testList->error_    = methodAdapter<CppTestCase, TestErrorPtr, &CppTestCase::error>;
    testList->ignored_  = methodAdapter<int, CppTestCase, &CppTestCase::ignored>;
    testList->name_     = methodAdapter<const char*, CppTestCase, &CppTestCase::name>;
    testList->source_   = methodAdapter<const char*, CppTestCase, &CppTestCase::source>;
    testList->line_     = methodAdapter<int, CppTestCase, &CppTestCase::line>;
}

void CppTestContainer::unload(TestCasePtr testList) 
{
    delete static_cast<CppTestCase*>(testList->self_);
    //
    // we know that 'testList' contain only one test case, so set zero for all object fields. In normal case
    // we must not change 'next_' field
    ::memset(testList, 0, sizeof(TestCase));
}

const char* CppTestContainer::errMsg() 
{
    return "";
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool CppTestCase::setUp()
{
    return true;
}

bool CppTestCase::testBody()               
{
    return false;
}

bool CppTestCase::tearDown() 
{
    return true;
}

void CppTestCase::error(TestErrorPtr errorInfo) 
{
    errorInfo->self_   = new CppTestError;
    errorInfo->source_ = methodAdapter<const char*, CppTestError, &CppTestError::source>;
    errorInfo->line_   = methodAdapter<int, CppTestError, &CppTestError::line>;
    errorInfo->errMsg_ = methodAdapter<const char*, CppTestError, &CppTestError::errMsg>;
}

int CppTestCase::ignored() const
{
    return false;
}

const char* CppTestCase::name() const
{
    return "mock";
}

const char* CppTestCase::source() const
{
    return __FILE__;
}

int CppTestCase::line() const 
{
    return -1;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
const char* CppTestError::source() const
{
    return __FILE__;
}

int CppTestError::line() const
{
    return 1;
}

const char* CppTestError::errMsg() const
{
    return "";
}

