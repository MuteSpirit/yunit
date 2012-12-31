//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// @file asserts.hpp
//
// Contain assert functions for usage inside unit tests.
// Their implementation is depend on C++ exceptions, so use it inside C++ project only.
//
// You have to include asserts.cpp and asserts.hpp files into you project, because they are deployed only as
// source code.
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

// use "guard defines" instead of #pragma once, because it's more 
#ifndef _ASSERTS_YUNIT_HEADER_
#define _ASSERTS_YUNIT_HEADER_

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

#include <string> // for STL strings comparison macro

YUNIT_NS_BEGIN

#define isNull(actual)\
{\
    if(!YUNIT_NS_PREF(cppunitAssert)(NULL == (actual)))\
        YUNIT_NS_PREF(throwException)(YUNIT_SOURCELINE(), #actual " is not NULL", false);\
}

#define isNotNull(actual)\
{\
    if(!YUNIT_NS_PREF(cppunitAssert)((actual) != NULL))\
        YUNIT_NS_PREF(throwException)(YUNIT_SOURCELINE(), #actual " is NULL", false);\
}

#define isTrue(condition)\
{\
    if(!YUNIT_NS_PREF(cppunitAssert)(condition))\
        YUNIT_NS_PREF(throwException)(YUNIT_SOURCELINE(), #condition);\
}

#define isFalse(condition)\
{\
    if(YUNIT_NS_PREF(cppunitAssert)(condition))\
        YUNIT_NS_PREF(throwException)(YUNIT_SOURCELINE(), #condition " != false", false);\
}

#define areEq(expected, actual)\
{\
    if(!YUNIT_NS_PREF(cppunitAssert)((expected), (actual)))\
        YUNIT_NS_PREF(throwException)(YUNIT_SOURCELINE(), (expected), (actual), true);\
}

#define areNotEq(expected, actual)\
{\
    if(YUNIT_NS_PREF(cppunitAssert)((expected), (actual)))\
        YUNIT_NS_PREF(throwException)(YUNIT_SOURCELINE(), (expected), (actual), false);\
}

#define areDoubleEq(expected, actual, delta)\
{\
    if(!YUNIT_NS_PREF(cppunitAssert)((expected), (actual), (delta)))\
        YUNIT_NS_PREF(throwException)(YUNIT_SOURCELINE(), (expected), (actual), (delta), true);\
}

#define areDoubleNotEq(expected, actual, delta)\
{\
    if(YUNIT_NS_PREF(cppunitAssert)((expected), (actual), (delta)))\
        YUNIT_NS_PREF(throwException)(YUNIT_SOURCELINE(), (expected), (actual), (delta), false);\
}

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
            YUNIT_NS_PREF(throwException)(YUNIT_SOURCELINE(),												\
            "Expected exception \"" #exceptionType "\" has not been thrown", true);						    \
        }                                                                                                   \
    }

#define noSpecificThrow(expression, exceptionType)														\
{\
    try																									\
    {																									\
        expression;																						\
    }																									\
    catch(const exceptionType&)																			\
    {																									\
        YUNIT_NS_PREF(throwException)(YUNIT_SOURCELINE                                              	\
            "Not expected exception \"" #exceptionType "\" has been thrown", true);			            \
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
        YUNIT_NS_PREF(throwException)(YUNIT_SOURCELINE(),											    \
            "Unwanted C++ exception has been thrown", true);			                                \
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
class TestException : public std::exception
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
bool cppunitAssert(const bool condition);

bool cppunitAssert(const long long int expected, const long long int actual);


/// \param[in] delta must be at [0.000000000000001, +INFINITE) for long double comparison
bool cppunitAssert(const long double expected, const long double actual, const long double delta);

/// \param[in] delta must be at [0.000000000000001, +INFINITE) for double comparison
bool cppunitAssert(const double expected, const double actual, const long double delta);

/// \param[in] delta must be at [0.00000001f, +INFINITE) for float comparison
bool cppunitAssert(const float expected, const float actual, const long double delta);

bool cppunitAssert(const void *expected, const void *actual);

bool cppunitAssert(const char *expected, const char *actual);
bool cppunitAssert(const wchar_t *expected, const wchar_t *actual);

inline bool cppunitAssert(const std::wstring& expected, const std::wstring& actual) {
    return cppunitAssert(expected.c_str(), actual.c_str());
}

inline bool cppunitAssert(const std::string& expected, const std::string& actual) {
    return cppunitAssert(expected.c_str(), actual.c_str());
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void throwException(const SourceLine& sourceLine, const char* condition);
void throwException(const SourceLine& sourceLine, const char* message, bool);

void throwException(const SourceLine& sourceLine, const void* expected, const void* actual,
        bool mustBeEqual);

void throwException(const SourceLine& sourceLine, const long long expected, const long long actual,
        bool mustBeEqual);
void throwException(const SourceLine& sourceLine, const char* expected, const char* actual,
        bool mustBeEqual);

inline void throwException(const SourceLine& sourceLine,
        const std::string& expected,
        const std::string& actual,
        bool mustBeEqual) {
    throwException(sourceLine, expected.c_str(), actual.c_str(), mustBeEqual);
}

void throwException(const SourceLine& sourceLine, const wchar_t* expected, const wchar_t* actual,
        bool mustBeEqual);

// This function is inline historically. Firstly it was a part of yUnit API, built as Dinamic Link Library.
// There is a problem to pass STL strings inside DLL functions, because they are different for Debug and
// Release configurations, but yUnit library was always compiled as Release and has a problem with accepting
// debug STL strings objects.
inline void throwException(const SourceLine& sourceLine,
        const std::wstring& expected,
        const std::wstring& actual,
        bool mustBeEqual) {
    throwException(sourceLine, expected.c_str(), actual.c_str(), mustBeEqual);
}

void throwException(const SourceLine& sourceLine, const double expected, const double actual,
        const double delta, bool mustBeEqual);

YUNIT_NS_END

#endif // _ASSERTS_YUNIT_HEADER_
