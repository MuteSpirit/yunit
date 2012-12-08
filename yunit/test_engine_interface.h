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
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// @todo Think about how TestCase::test* methods say about asserts passes, pass messages
/// @todo Try to pass TestError objects into setUp, testBody, tearDown
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// @todo @done Think about strategy of TestCase, TestError creation and destroing
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
// Test Engine API functions
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct _TestContainer;
typedef struct _TestContainer TestContainer, *TestContainerPtr;

/// @brief Fill TestContainer object
/// @param[in] path Path to test container file (usually, but really it maybe path to some other resource)
/// So test engine library must not create struct TestContainer object, but only create it's TestContainer 
/// implementation object.
TUE_API void loadTestContainer(TestContainerPtr tcPtr, const char *path);

/// @brief Clear TestContainer object and say library that it may destroy it's object of TestContainer
/// implementation.
TUE_API void unloadTestContainer(TestContainerPtr tcPtr);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct _TestCase;
typedef struct _TestCase TestCase, *TestCasePtr;

struct _TestContainer
{
    /// @brief Pointer to real object, created inside test engine
    void *self_;

    /// @param[in] self Pass 'self_'
    /// @return Number of tests, contained at test container
    ///
    /// It allow create required number of TestCase objects to execute 'load_' method
    unsigned int (*numberOfTests_)(void *self);

    /// @brief load test container file and tests from it
    /// @param[in] self Pass 'self_'
    /// @param[in, out] testList Client code must create list with such many TestCase objects, as 'numberOfTests_'
    ///                          method sad
    void (*load_)(void *self, TestCasePtr testList); 

    /// @brief unload test container file. Free TestCase's members, besides of 'next_'
    /// @param[in] self Pass 'self_'
    /// @param[in] testList list of tests, returned from load_ call
    bool (*unload_)(void *self, TestCasePtr testList); 

    /// @param[in] self Pass 'self_'
    /// @return Last occured error's message. Client code must use only copy of this string.
    ///         Test engine library may delete it in any next call.
    const char* (*errMsg_)(void *self); 
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct _TestError;
typedef struct _TestError TestError;

/// @brief Test Case object
/// @details You should return test, even it must be ignored, because information hiding is wrong strategy
struct _TestCase
{
    /// @brief Pointer to real object, created inside test engine
    void *self_;
    
    /// @param[in] self Pass 'self_'
    /// will be called before 'testBody'
    /// @return true in case of succes and false otherwise
    bool (*setUp_)(void *self);

    /// @param[in] self Pass 'self_'
    /// test's 'main' function, will be called if 'setUp' has been success
    /// @return true in case of succes and false otherwise
    bool (*testBody_)(void *self);               

    /// @param[in] self Pass 'self_'
    /// will be called, if 'setUp' has been success
    /// @return true in case of succes and false otherwise
    bool (*tearDown_)(void *self); 

    /// @param[in] self Pass 'self_'
    /// will be called if any of 'setUp', 'testBody' or 'tearDown' functions return false to get 
    /// @param[out] errorInfo it will be fiiled with information about last error
    void (*error_)(void *self, TestError *errorInfo); 

    /// @param[in] self Pass 'self_'
    /// @return 1 if test must be ignored and not executed and 0 otherwise
    int (*ignored_)(const void *self);

    /// @param[in] self Pass 'self_'
    /// @return test name
    const char* (*name_)(const void *self);

    /// @param[in] self Pass 'self_'
    /// @return full path of file, containing test source
    const char* (*source_)(const void *self);

    /// @param[in] self Pass 'self_'
    /// @return number of 1st line of test definition
    int (*line_)(const void *self);

    /// pointer to next list element
    struct _TestCase* next_;
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// inline funcions definition
//
// This functions is like class methods, they only call functions-members of structs.
// They are defined here, because it is not reasonable to force test unit engine authors to define them 
// themselves.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TestContainer
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
inline unsigned int testContainerNumberOfTests(TestContainerPtr tc)
{
    return tc->numberOfTests_(tc->self_);
}

inline void testContainerLoad(TestContainerPtr tc, TestCasePtr testList) 
{
    return tc->load_(tc->self_);
}

inline bool testContainerUnload(TestContainerPtr tc, TestCasePtr testList) 
{
    return tc->unload_(tc->self_);
}

inline const char* testContainerErrMsg(TestContainerPtr tc) 
{
    return tc->errMsg_(tc->self_);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// TestCase
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
