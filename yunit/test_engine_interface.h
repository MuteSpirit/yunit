/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// @file test_engine_interface.h
/// @brief Declare test unit engine library interface functions
///
/// When you create test unit engine library, you have to:
/// 1) include current file
/// 2) define macro TUE_LIB
/// 3) define all functions from current file, marked with attribute TUE_API (they will be exported, 
/// 4) build library as DLL
/// 
/// @todo Think about strategy of TestCase, TestError creation and destroing
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef _TEST_ENGINE_INTERFACE_HEADER_
#define _TEST_ENGINE_INTERFACE_HEADER_

#ifdef __cplusplus
extern "C" {
#endif

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
#endif // ifndef TUE_API

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// API functions:
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct _TestContainer;
typedef struct _TestContainer TestContainer, *TestContainerPtr;

/// @brief Create new TestContainer object
/// @param[in] path Path to test container file (usually, but really it maybe path to some other resource)
TUE_API TestContainerPtr newTestContainer(const char *path);

/// @brief Delete TestContainer object
TUE_API void closeTestContainer(TestContainerPtr tcPtr);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct _TestCase;
typedef struct _TestCase TestCase, *TestCasePtr;

struct _TestContainer
{
    void *self_;

    /// @brief load test container file and tests from it
    /// @return list of TestCase objects or NULL in case of tests abscent
    TestCasePtr (*load_)(void *self); 

    /// unload test container file. You must not use got TestCase objects after this method call
    /// @param[in] self "this" pointer
    /// @param[in] testList list of tests, returned from load_ call
    bool (*unload_)(void *self, TestCasePtr testList); 

    /// @return Last occured error's message. String must be copied by client code before usage.
    const char* (*errMsg_)(void *self); 
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct _TestError;
typedef struct _TestError TestError;

/// @brief Test Case object
/// @details You should return test, even it must be ignored, because information hiding is wrong strategy
struct _TestCase
{
    /// real obect "this" pointer
    void *self_;
    
    /// will be called before 'testBody'
    /// @return true in case of succes and false otherwise
    bool (*setUp_)(void *self);

    /// test's 'main' function, will be called if 'setUp' has been success
    /// @return true in case of succes and false otherwise
    bool (*testBody_)(void *self);               

    /// will be called, if 'setUp' has been success
    /// @return true in case of succes and false otherwise
    bool (*tearDown_)(void *self);           

    /// will be called if any of 'setUp', 'testBody' or 'tearDown' functions return false to get 
    /// @param[out] errorInfo it will be fiiled with information about last error
    void (*error_)(void *self, TestError *errorInfo); 

    /// @return 1 if test must be ignored and not executed and 0 otherwise
    int (*ignored_)(const void *self);

    const char* (*name_)(const void *self);  ///< @return test name
    const char* (*source_)(const void *self);///< @return full path of file, containing test source
    int (*line_)(const void *self);          ///< @return number of 1st line of test definition
    
    struct _TestCase* next_;                    ///< pointer to next Test in list
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// inline funcions definition
//
// This functions is like class methods, they only call functions-members of structs.
// They are defined here, because it is not reasonable to force test unit engine authors to define them 
// themselves.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
inline const char* testContainerErrMsg(TestContainerPtr tc)
{
    return tc->errMsg_(tc->self_);
}

inline TestCasePtr testContainerLoad(TestContainerPtr tc)
{
    return tc->load_(tc->self_);
}

inline bool testContainerUnload(TestContainerPtr tc, TestCasePtr testList)
{
    return tc->unload_(tc->self_, testList);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
inline bool setUp(TestCasePtr test)
{
    test->setUp_(test->self_);
}

inline bool testBody(TestCasePtr test)
{
    test->testBody_(test->self_);
}

inline bool tearDown(TestCasePtr test)
{
    test->tearDown_(test->self_);
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

#ifdef __cplusplus
} // extern "C"
#endif

#endif // _TEST_ENGINE_INTERFACE_HEADER_
