//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// @file test_engine_interface.h
/// @brief Declare test unit engine library interface functions
///
/// @todo Rename methods isIgnored -> ignored
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


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// @brief Must be implemented (and exported) by test engine shared library
/// @return test container file extensions, supported by this test unit engine library.
/// @details Last pointer must be NULL.
/// For example, you may return address of variable, defined like
/// static const char* ext[] = {"t.cpp", NULL};
/// Test runner use it to filter test container files among all files
TUE_API const char** testContainerExtensions();

struct _Test;
typedef struct _Test Test, *TestPtr;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// @brief load one test container
/// @brief Must be implemented (and exported) by test engine shared library
/// @return list with unit test objects
/// @param[in] path Full path to test container file
/// @details test runner will not delete returned Test objects, it will use it only
TUE_API TestPtr loadTestContainer(const char *path);


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// @brief Accept execution result
/// @details Example of method call:
/// @code{.cpp}
/// void testExecute(void *self, LoggerPtr logger)
/// {
///     TestPtr test = (TestPtr)self;
///     if (test->execute())
///         (*logger->success_)(logger, test);
///     else
///         (*logger->fail_)(logger, test, "Oops! :-(")
/// }
/// @endcode
struct _Logger
{
    void *self_;

    /// Using this method allow TestRunner to estimate elapsed time for test execution
    void (*startTest_)(void *self);
    
    // Any next method call means, that test execution has been finished
    void (*success_)(void *self);
    void (*failure_)(void *self, const char *message);
    void (*error_)(void *self, const char *message);

};
typedef struct _Logger Logger, *LoggerPtr;

inline void startTest(LoggerPtr logger)
{
    (*logger->startTest_)(logger->self_);
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// @brief Test case object
/// @details You should return test, even it must be ignored, because information hiding is wrong strategy
struct _Test
{
    ///< @brief test object 'this' pointer
    void *self_;
    
    ///< will be called before 'test'
	void (*setUp_)(void *self, LoggerPtr logger);
	void (*test_)(void *self, LoggerPtr logger);               ///< test's 'main' function, will be called if 'setUp' has been success
	void (*tearDown_)(void *self, LoggerPtr logger);           ///< will be called, if 'setUp' has been success


    /// @return 1 if test must be ignored and not executed and 0 otherwise
	int (*isIgnored_)(const void *self);

	const char* (*name_)(const void *self);  ///< @return test name
	const char* (*source_)(const void *self);///< @return full path of file, containing test source
    int (*line_)(const void *self);          ///< @return number of 1st line of test definition
	
	struct _Test* next_;                    ///< pointer to next Test in list
};

inline void setUp(TestPtr test, LoggerPtr logger)
{
    test->setUp_(test->self_, logger);
}

inline void test(TestPtr test, LoggerPtr logger)
{
    test->test_(test->self_, logger);
}

inline void tearDown(TestPtr test, LoggerPtr logger)
{
    test->tearDown_(test->self_, logger);
}

inline int isIgnored(const TestPtr test)
{
    return test->isIgnored_(test->self_);
}

inline const char* name(const TestPtr test)
{
    return test->name_(test->self_);
}

inline const char* source(const TestPtr test)
{
    return test->source_(test->self_);
}

inline int line(const TestPtr test)
{
    return test->line_(test->self_);
}

#ifdef __cplusplus
} // extern "C"
#endif

#endif // _TEST_ENGINE_INTERFACE_HEADER_
