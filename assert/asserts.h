//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// @file asserts.hpp
//
// Contain assert functions for usage inside unit tests.
// Their implementation is depend on C++ exceptions, so use it inside C++ project only.
//
// You have to include asserts.cpp and asserts.hpp files into you project, because they are deployed only as
// source code.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

// use "guard defines" instead of #pragma once, because it's more supported
#ifndef _ASSERTS_YUNIT_HEADER_
#define _ASSERTS_YUNIT_HEADER_

#include <string> // for STL strings comparison macro
#include <stdexcept>

// yUnit functions 
#ifndef WITHOUT_YUNIT_NS
#  define YUNIT_NS yUnit
#  define YUNIT_NS_PREF(var) yUnit::var
#  define YUNIT_NS_BEGIN namespace YUNIT_NS {
#  define YUNIT_NS_END   }
#else
#  define YUNIT_NS_BEGIN
#  define YUNIT_NS_END
#  define YUNIT_NS_PREF(var) var
#endif

/// @define ASSERT_MESSAGE_PREFIX(file, line)
/// @param file literal string
/// @param line integer value. number of line
#ifdef _MSC_VER
#  define ASSERT_MESSAGE_PREFIX(file, line) file "(" TOSTR(line) ") : "
#else
#  define ASSERT_MESSAGE_PREFIX(file, line) file ":" TOSTR(line) ":0: error: "
#endif

#define TOSTR_(expression) #expression 
#define TOSTR(expression) TOSTR_(expression)

YUNIT_NS_BEGIN

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define isNull(actual) \
{ \
    if (0 != (actual)) \
        throw std::logic_error(ASSERT_MESSAGE_PREFIX(__FILE__, __LINE__) TOSTR(actual) " is not NULL"); \
}

#define isNotNull(actual) \
{ \
    if (0 == (actual)) \
        throw std::logic_error(ASSERT_MESSAGE_PREFIX(__FILE__, __LINE__) TOSTR(actual) " is NULL"); \
}

#define isTrue(condition) \
{ \
    if (!(condition)) \
        throw std::logic_error(ASSERT_MESSAGE_PREFIX(__FILE__, __LINE__) #condition " != true"); \
}

#define isFalse(condition) \
{ \
    if (condition) \
        throw std::logic_error(ASSERT_MESSAGE_PREFIX(__FILE__, __LINE__) #condition " != false"); \
}

#define areEq(expected, actual)\
{\
    if (!YUNIT_NS_PREF(areEqValues)((expected), (actual)))\
        YUNIT_NS_PREF(throwException)(ASSERT_MESSAGE_PREFIX(__FILE__, __LINE__), (expected), (actual), true);\
}

#define areNotEq(expected, actual)\
{\
    if (YUNIT_NS_PREF(areEqValues)((expected), (actual)))\
        YUNIT_NS_PREF(throwException)(ASSERT_MESSAGE_PREFIX(__FILE__, __LINE__), (expected), (actual), false);\
}

#define areDoubleEq(expected, actual, delta)\
{\
    if (!YUNIT_NS_PREF(areEqValues)((expected), (actual), (delta)))\
        YUNIT_NS_PREF(throwException)(ASSERT_MESSAGE_PREFIX(__FILE__, __LINE__), (expected), (actual), (delta), true);\
}

#define areDoubleNotEq(expected, actual, delta)\
{\
    if (YUNIT_NS_PREF(areEqValues)((expected), (actual), (delta)))\
        YUNIT_NS_PREF(throwException)(ASSERT_MESSAGE_PREFIX(__FILE__, __LINE__), (expected), (actual), (delta), false);\
}

#define willThrow(expression, exceptionType)																\
    for (;;) \
    {                                                                                                       \
        try																									\
        {																									\
            expression;																			            \
        }																									\
        catch(const exceptionType&)																			\
        {																									\
            break;                                                                                          \
        }																									\
                                                                                                            \
        throw std::logic_error(ASSERT_MESSAGE_PREFIX(__FILE__, __LINE__)                                    \
                               "Expected exception \"" #exceptionType "\" has not been thrown");		    \
    }

#define noSpecificThrow(expression, exceptionType)														\
{                                                                                                       \
    try																									\
    {																									\
        expression;																						\
    }																									\
    catch(const exceptionType&)																			\
    {																									\
        throw std::logic_error(ASSERT_MESSAGE_PREFIX(__FILE__, __LINE__)                                \
            "Not expected exception \"" #exceptionType "\" has been thrown");			                \
    }\
}

#define noAnyCppThrow(expression)														                \
{\
    try																									\
    {																									\
        expression;																						\
    }																									\
    catch(...)																			                \
    {																									\
        throw std::logic_error(ASSERT_MESSAGE_PREFIX(__FILE__, __LINE__) "Unwanted C++ exception has been thrown");\
    }\
}


#ifdef _WIN32 // use _WIN32 instead of WIN32, because _WIN32 is automatically defined by the visual C/C++ compiler

#define EXCEPTION_EXECUTE_HANDLER 1

#define noSehThrow(expression)																	            \
{\
    __try																									\
    {																										\
        expression;																							\
    }																										\
    __except(EXCEPTION_EXECUTE_HANDLER)																		\
    {																										\
        YUNIT_NS_PREF(throwException)(YUNIT_SOURCELINE(), "Unwanted SEH exception has been thrown", true);  \
    }\
}

#endif // _WIN32

#define YUNIT_SOURCELINE()   YUNIT_NS::SourceLine(__FILE__, __LINE__)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool areEqValues(const long long int expected, const long long int actual);

/// \param[in] delta must be at [0.000000000000001, +INFINITE) for long double comparison
bool areEqValues(const long double expected, const long double actual, const long double delta);

/// \param[in] delta must be at [0.000000000000001, +INFINITE) for double comparison
bool areEqValues(const double expected, const double actual, const long double delta);

/// \param[in] delta must be at [0.00000001f, +INFINITE) for float comparison
bool areEqValues(const float expected, const float actual, const long double delta);

bool areEqValues(const void *expected, const void *actual);

bool areEqValues(const char *expected, const char *actual);
bool areEqValues(const wchar_t *expected, const wchar_t *actual);

inline bool areEqValues(const std::wstring& expected, const std::wstring& actual) {
    return areEqValues(expected.c_str(), actual.c_str());
}

inline bool areEqValues(const std::string& expected, const std::string& actual) {
    return areEqValues(expected.c_str(), actual.c_str());
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Any "throwException" function will throw exception of class, derived from std::exception
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void throwException(const char *prefix, const void* expected, const void* actual, bool mustBeEqual);
void throwException(const char *prefix, const long long expected, const long long actual, bool mustBeEqual);
void throwException(const char *prefix, const char* expected, const char* actual, bool mustBeEqual);
void throwException(const char *prefix, const wchar_t* expected, const wchar_t* actual, bool mustBeEqual);
void throwException(const char *prefix, const double expected, const double actual, const double delta, bool mustBeEqual);

// This function is inline historically. Firstly it was a part of yUnit API, built as Dinamic Link Library.
// There is a problem to pass STL strings inside DLL functions, because they are different for Debug and
// Release configurations, but yUnit library was always compiled as Release and has a problem with accepting
// debug STL strings objects.
inline void throwException(const char *prefix, const std::string& expected, const std::string& actual, bool mustBeEqual)
{
    throwException(prefix, expected.c_str(), actual.c_str(), mustBeEqual);
}

// This function is inline historically. Firstly it was a part of yUnit API, built as Dinamic Link Library.
// There is a problem to pass STL strings inside DLL functions, because they are different for Debug and
// Release configurations, but yUnit library was always compiled as Release and has a problem with accepting
// debug STL strings objects.
inline void throwException(const char *prefix, const std::wstring& expected, const std::wstring& actual, bool mustBeEqual)
{
    throwException(prefix, expected.c_str(), actual.c_str(), mustBeEqual);
}


YUNIT_NS_END

#endif // _ASSERTS_YUNIT_HEADER_
