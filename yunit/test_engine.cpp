//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// @file test_engine.cpp
// 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "test_engine.h"
#include "test_engine_interface.h"

#ifdef _WIN32
#  include <windows.h>
#  include <io.h>
#  define ACCESS_FUNC _access
#else
#  include <unistd.h> 
#  define ACCESS_FUNC access
#  include <dlfcn.h>
#endif

template<typename T, typename Arg, void (T::*method)(Arg)>
void callAdapter(void *t, Arg arg)
{
    (static_cast<T*>(t)->*method)(arg);
}

template<typename T, void (T::*method)()>
void callAdapter(void *t)
{
    (static_cast<T*>(t)->*method)();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
static bool isExist(const char* path)
{
    enum {existenceOnlyMode = 0, notAccessible = -1};
    return notAccessible != ACCESS_FUNC(path, existenceOnlyMode);
}


#ifdef _WIN32

class TestEngineWin32 : public TestEngine
{
public:
    TestEngineWin32(const char *path);
    virtual bool initialize();
    virtual const char *error() const;
    virtual const char** supportedExtensions();
    virtual Test* load(const char* testContainerPath);
    
private:
    std::string path_;
    HMODULE hModule_;
    std::string error_;
};

#else // _WIN32

class TestEngineUnix : public TestEngine
{
public:
    TestEngineUnix(const char *path);
    virtual bool initialize();
    virtual const char *error() const;
    virtual const char** supportedExtensions();
    virtual TestPtr load(const char* testContainerPath);
    
private:
    std::string path_;
    void *hModule_;
    std::string error_;
    
    typedef const char** (*TestContainerExtensionsFunc)();
    TestContainerExtensionsFunc testContainerExtensions_;

    typedef Test* (*LoadTestContainerFunc)(const char*);
    LoadTestContainerFunc loadTestContainerFunc_;
};

#endif // _WIN32

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifdef WIN32

TestEngineWin32::TestEngineWin32(const char *path)
: path_(path)
, hModule_(NULL)
{
}
        
void TestEngineWin32::initialize()
{
    error_ = "";
    hModule_ = ::LoadLibraryExA(path_, NULL, 0);
    
    if (NULL == hModule_)
    {
        enum {bufferSize = 1024};
        char buffer[bufferSize];

        const int error = ::GetLastError();
        if (::FormatMessageA(FORMAT_MESSAGE_IGNORE_INSERTS | FORMAT_MESSAGE_FROM_SYSTEM, NULL, error, 0, buffer, bufferSize, NULL))
            error_.assign(buffer);
        else
            snprintf(buffer, bufferSize, "system error %d\n", error)
                    
        return false;
    }
    
    return true;
}

TestEngine* TestEngineFactory::create(const char *filePath)
{
    return new TestEngineWin32(filePath);
}

#else // _WIN32
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
TestEngine* TestEngineFactory::create(const char *filePath)
{
    return new TestEngineUnix(filePath);
}

void TestEngineFactory::destroy(TestEngine *object)
{
    delete object;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
TestEngineUnix::TestEngineUnix(const char *path)
: path_(path)
, hModule_(NULL)
, testContainerExtensions_(NULL)
, loadTestContainerFunc_(NULL)
{
}

bool TestEngineUnix::initialize()
{
    error_ = "";

    dlerror();    /* Clear any existing error */
    hModule_ = dlopen(path_.c_str(), RTLD_NOW | RTLD_GLOBAL);
    if (NULL == hModule_)
    {
        error_ = dlerror();
        return false;
    }

    void *funcPtr;
    
    dlerror();    /* Clear any existing error */
    funcPtr = dlsym(hModule_, "testContainerExtensions");
    if (NULL == funcPtr)
    {
        error_ = dlerror();
        dlclose(hModule_);
        return false;
    }
    else
        testContainerExtensions_ = reinterpret_cast<TestContainerExtensionsFunc>(funcPtr);
    
    dlerror();    /* Clear any existing error */
    funcPtr = dlsym(hModule_, "loadTestContainer");
    if (NULL == funcPtr)
    {
        error_ = dlerror();
        dlclose(hModule_);
        return false;
    }
    else
        loadTestContainerFunc_ = reinterpret_cast<LoadTestContainerFunc>(funcPtr);
    
    return true;
}

const char* TestEngineUnix::error() const
{
    return error_.c_str();
}

const char** TestEngineUnix::supportedExtensions()
{
    return (*testContainerExtensions_)();
}

Test* TestEngineUnix::load(const char* testContainerPath)
{
    return (*loadTestContainerFunc_)(testContainerPath);
}

#endif // _WIN32

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
SimpleLogger::SimpleLogger()
: currentTest_(NULL)
, step_(0)
{
    logger_.self_ = this;

    logger_.startWorkWithTestEngine_ = callAdapter<Self, const char*, &Self::startWorkWithTestEngine>;
    logger_.startLoadTe_ = callAdapter<Self, &Self::startLoadTe>;
    logger_.startGetExt_ = callAdapter<Self, &Self::startGetExt>;
    logger_.startUnloadTe_ = callAdapter<Self, &Self::startUnloadTe>;
    
    logger_.startWorkWithTestContainer_ = callAdapter<Self, const char*, &Self::startWorkWithTestContainer>;
    logger_.startLoadTc_ = callAdapter<Self, &Self::startLoadTc>;
    logger_.startUnloadTc_ = callAdapter<Self, &Self::startUnloadTc>;
    
    logger_.startWorkWithTest_ = callAdapter<Self, TestPtr, &Self::startWorkWithTest>;
    logger_.startSetUp_ = callAdapter<Self, &Self::startSetUp>;
    logger_.startTest_ = callAdapter<Self, &Self::startTest>;
    logger_.startTearDown_ = callAdapter<Self, &Self::startTearDown>;

    logger_.destroy_ = destroy;
    logger_.success_ = callAdapter<Self, &Self::success>;
    logger_.failure_ = callAdapter<Self, const char*, &Self::failure>;
    logger_.error_ = callAdapter<Self, const char*, &Self::error>;
}

LoggerPtr SimpleLogger::logger()
{
    return &logger_;
}

void SimpleLogger::startWorkWithTestEngine(const char *path)
{
    
}

void SimpleLogger::startLoadTe()
{
    
}

void SimpleLogger::startGetExt()
{
    
}

void SimpleLogger::startUnloadTe()
{
    
}

void SimpleLogger::startWorkWithTestContainer(const char *path)
{
    
}

void SimpleLogger::startLoadTc()
{
    
}

void SimpleLogger::startUnloadTc()
{
    
}

void SimpleLogger::startWorkWithTest(TestPtr test)
{
    currentTest_ = test;
}

void SimpleLogger::startSetUp()
{
    step_ = Step::setUp;
}

void SimpleLogger::startTest()
{
    step_ = Step::test;
}

void SimpleLogger::startTearDown()
{
    step_ = Step::tearDown;
}

void SimpleLogger::success()
{
    printf("%s::%s is Ok" ENDL, name(currentTest_), stepName(step_));
}

void SimpleLogger::failure(const char *message)
{
    printf("%s::%s is Fail: '%s'" ENDL, name(currentTest_), stepName(step_), message);
}

void SimpleLogger::error(const char *message)
{
    printf("%s::%s is Error: '%s'" ENDL, name(currentTest_), stepName(step_), message);
}

const char* SimpleLogger::stepName(const int step)
{
   switch (step)
   {
   case Step::setUp:
       return "setUp";
   case Step::test:
       return "test";
   case Step::tearDown:
       return "tearDown";
   default:
       abort(); /* unknown step type */
   }
}

void SimpleLogger::destroy(void *ptr)
{
    SimpleLogger *self = static_cast<SimpleLogger*>(ptr);
    delete self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
LUA_CONSTRUCTOR(TestEngine)
{
    using namespace Lua;
    
    enum Args {pathIdx = 1};
    LUA_CHECK_ARG(string, Lua::String, pathIdx);
    
    String path(lua.to<Lua::String>(pathIdx));
    if (0 == path.size_)
    {
        lua.push(Nil);
        lua.push("expected file path as argument, but was empty string");
        return 2;
    }
    
    if (!isExist(path))
    {
        lua.push(Nil);
        lua.push("accept path of nonexistent file");
        return 2;
    }
    
    TestEngine *testEngine = TestEngineFactory::create(path);
    if (testEngine->initialize())
    {
        LUA_PUSH(testEngine, TestEngine);
        return 1;
    }
    else
    {
        lua.push(Nil);
        lua.push(testEngine->error());
        TestEngineFactory::destroy(testEngine);
        return 2;
    }
}

LUA_METHOD(TestEngine, supportedExtensions)
{
    enum Args {selfIdx = 1};
    /// @todo Add argument type check
    
    TestEngine *testEngine = lua.to<TestEngine*>(selfIdx);
    const char **ext = testEngine->supportedExtensions();
    
    lua.push(Lua::Table());
    const int extTableIdx = lua.top();
    int extIdx = 0;
    
    for (; *ext; ++ext)
    {
        lua.push(++extIdx);
        lua.push(*ext);
        lua.settable(extTableIdx);
    }
    
    return 1;
}

LUA_METHOD(TestEngine, load)
{
    enum Args {selfIdx = 1, testContainerPathIdx};
    /// @todo Add argument type check
    LUA_CHECK_ARG(string, const char*, testContainerPathIdx);
    
    TestEngine *testEngine = lua.to<TestEngine*>(selfIdx);
    TestPtr test = testEngine->load(lua.to<const char*>(testContainerPathIdx));
    
    lua.push(Lua::Table());
    const int testTableIdx = lua.top();
    int testIdx = 0;
    
    for (; test; test = test->next_)
    {
        lua.push(++testIdx);
        LUA_PUSH(test, UnitTest);
        lua.settable(testTableIdx);
    }
    
    return 1;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
LUA_METHOD(UnitTest, start)
{
    enum Args {selfIdx = 1, loggerIdx};
    TestPtr testCase = lua.to<TestPtr>(selfIdx);
    LoggerPtr logger = lua.to<LoggerPtr>(loggerIdx);

    startWorkWithTest(logger, testCase);
    return 0;
}

LUA_METHOD(UnitTest, setUp)
{
    enum Args {selfIdx = 1, loggerIdx};
    TestPtr testCase = lua.to<TestPtr>(selfIdx);
    LoggerPtr logger = lua.to<LoggerPtr>(loggerIdx);
    
    startTest(logger);
    setUp(testCase, logger);
    return 0;
}

LUA_METHOD(UnitTest, test)
{
    enum Args {selfIdx = 1, loggerIdx};
    TestPtr testCase = lua.to<TestPtr>(selfIdx);
    LoggerPtr logger = lua.to<LoggerPtr>(loggerIdx);
    
    startTest(logger);
    test(testCase, logger);
    return 0;
}

LUA_METHOD(UnitTest, tearDown)
{
    enum Args {selfIdx = 1, loggerIdx};
    TestPtr testCase = lua.to<TestPtr>(selfIdx);
    LoggerPtr logger = lua.to<LoggerPtr>(loggerIdx);
    
    startTest(logger);
    tearDown(testCase, logger);
    return 0;
}

LUA_METHOD(UnitTest, isIgnored)
{
    enum Args {selfIdx = 1};
    lua.push(isIgnored(lua.to<TestPtr>(selfIdx)));
    return 1;
}

LUA_METHOD(UnitTest, name)
{
    enum Args {selfIdx = 1};
    lua.push(name(lua.to<TestPtr>(selfIdx)));
    return 1;
}

LUA_METHOD(UnitTest, source)
{
    enum Args {selfIdx = 1};
    lua.push(source(lua.to<TestPtr>(selfIdx)));
    return 1;
}

LUA_METHOD(UnitTest, line)
{
    enum Args {selfIdx = 1};
    lua.push(line(lua.to<TestPtr>(selfIdx)));
    return 1;
}

