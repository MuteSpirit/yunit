/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// @file test_engine_interface.h
/// @brief Declare test unit engine library interface functions
///
/// @todo Use Logger's startSetUp, startTearDown and finish methods to estimate elapsed time for test execution
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef _TEST_ENGINE_INTERFACE_HEADER_
#define _TEST_ENGINE_INTERFACE_HEADER_

#ifdef __cplusplus
extern "C" {
#endif

/// @def TUE_LIB You must define this macro, if you build test unit engine DLL to export special functions,
/// which will be used by test runner

#ifndef TUE_API
#   if defined _WIN32 || defined __CYGWIN__
#       define TUE_HELPER_DLL_IMPORT __declspec(dllimport)
#       define TUE_HELPER_DLL_EXPORT __declspec(dllexport)
#   else
#       if __GNUC__ >= 4
#           define TUE_HELPER_DLL_IMPORT __attribute__ ((visibility ("default")))
#           define TUE_HELPER_DLL_EXPORT __attribute__ ((visibility ("default")))
#       else
#           define TUE_HELPER_DLL_IMPORT
#           define TUE_HELPER_DLL_EXPORT
#       endif
#   endif

#   ifdef TUE_LIB
#       define TUE_API TUE_HELPER_DLL_EXPORT
#   else
#       define TUE_API TUE_HELPER_DLL_IMPORT
#   endif
#endif

struct _TestCase;
typedef struct _TestCase TestCase, *TestCasePtr;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
typedef struct _Logger
{
    // work with Test Engine:
    void (*startWorkWithTestEngine_)(void *self, const char *path);
    void (*startLoadTe_)(void *self);
    void (*startGetExt_)(void *self);
    void (*startUnloadTe_)(void *self);
    
    // work with Test Container:
    void (*startWorkWithTestContainer_)(void *self, const char *path);
    void (*startLoadTc_)(void *self);
    void (*startUnloadTc_)(void *self);
    
    // work with Unit Test:
    void (*startWorkWithTest_)(void *self, TestCasePtr);
    void (*startSetUp_)(void *self);
    void (*startTest_)(void *self);
    void (*startTearDown_)(void *self);
    
    // Call any of next 3 methods means that step has been finished:
    void (*success_)(void *self);                      ///< @brief Inform about successfull step finish
    void (*failure_)(void *self, const char *message); ///< @brief Inform about failure step finish
    void (*error_)(void *self, const char *message);   ///< @brief Inform about unexpected error during step

    /// @brief Pointer to real object, hiding behind 'Logger' interface
    void *self_;
    
    /// @brief Allow destroy real object, hiding behind 'Logger' interface
    void (*destroy_)(void *self);

} Logger, *LoggerPtr;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct _TestContainer;
typedef struct _TestContainer TestContainer, *TestContainerPtr;

/// @brief Create new TestContainer object
/// @param[in] path Path to test container file (usually, but really it maybe path to some other resource)
TUE_API TestContainerPtr newTestContainer(const char *path);

/// @brief Delete TestContainer object
TUE_API void closeTestContainer(TestContainerPtr tcPtr);


struct _TestContainer
{
    void *self_;

    const char* (*errMsg_)(void *self); ///< @return Last occured error's message

    TestCasePtr (*load_)(void *self); ///< load test container file, get it's tests and return them
    bool (*unload_)(void *self); ///< unload test container file. You must not use got TestCase objects after this method call
};

inline const char* testContainerErrMsg(TestContainerPtr tc)
{
    return tc->errMsg_(tc->self_);
}

inline TestCasePtr testContainerLoad(TestContainerPtr tc)
{
    return tc->load_(tc->self_);
}

inline bool testContainerUnload(TestContainerPtr tc)
{
    return tc->unload_(tc->self_);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// @brief Test case object
/// @details You should return test, even it must be ignored, because information hiding is wrong strategy
struct _TestCase
{
    ///< test object's "this" pointer
    void *self_;
    
    ///< will be called before 'test'
    void (*setUp_)(void *self, LoggerPtr logger);
    void (*testBody_)(void *self, LoggerPtr logger);               ///< test's 'main' function, will be called if 'setUp' has been success
    void (*tearDown_)(void *self, LoggerPtr logger);           ///< will be called, if 'setUp' has been success

    /// @return 1 if test must be ignored and not executed and 0 otherwise
    int (*ignored_)(const void *self);

    const char* (*name_)(const void *self);  ///< @return test name
    const char* (*source_)(const void *self);///< @return full path of file, containing test source
    int (*line_)(const void *self);          ///< @return number of 1st line of test definition
    
    struct _Test* next_;                    ///< pointer to next Test in list
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
inline void setUp(TestCasePtr test, LoggerPtr logger)
{
    test->setUp_(test->self_, logger);
}

inline void testBody(TestCasePtr test, LoggerPtr logger)
{
    test->testBody_(test->self_, logger);
}

inline void tearDown(TestCasePtr test, LoggerPtr logger)
{
    test->tearDown_(test->self_, logger);
}

inline int ignored(const TestCasePtr test)
{
    return test->ignored_(test->self_);
}

inline const char* name(const TestCasePtr test)
{
    return test->name_(test->self_);
}

inline const char* source(const TestCasePtr test)
{
    return test->source_(test->self_);
}

inline int line(const TestCasePtr test)
{
    return test->line_(test->self_);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
inline void startWorkWithTestEngine(LoggerPtr logger, const char *path)
{
    (*logger->startWorkWithTestEngine_)(logger->self_, path);
}

inline void startLoadTe(LoggerPtr logger)
{
    (*logger->startLoadTe_)(logger->self_);
}

inline void startGetExt(LoggerPtr logger)
{
    (*logger->startGetExt_)(logger->self_);
}

inline void startUnloadTe(LoggerPtr logger)
{
    (*logger->startUnloadTe_)(logger->self_);
}

inline void startWorkWithTestContainer(LoggerPtr logger, const char *path)
{
    (*logger->startWorkWithTestContainer_)(logger->self_, path);
}

inline void startLoadTc(LoggerPtr logger)
{
    (*logger->startLoadTc_)(logger->self_);
}

inline void startUnloadTc(LoggerPtr logger)
{
    (*logger->startUnloadTc_)(logger->self_);
}

inline void startWorkWithTest(LoggerPtr logger, TestCasePtr test)
{
    (*logger->startWorkWithTest_)(logger->self_, test);
}

inline void startSetUp(LoggerPtr logger)
{
    (*logger->startSetUp_)(logger->self_);
}

inline void startTest(LoggerPtr logger)
{
    (*logger->startTest_)(logger->self_);
}

inline void startTearDown(LoggerPtr logger)
{
    (*logger->startTearDown_)(logger->self_);
}

inline void success(LoggerPtr logger)
{
    (*logger->success_)(logger->self_);
}

inline void failure(LoggerPtr logger, const char *message)
{
    (*logger->failure_)(logger->self_, message);
}

inline void error(LoggerPtr logger, const char *message)
{
    (*logger->error_)(logger->self_, message);
}

inline void destroy(LoggerPtr logger)
{
    (*logger->destroy_)(logger->self_);
}

#ifdef __cplusplus
} // extern "C"
#endif

#endif // _TEST_ENGINE_INTERFACE_HEADER_
