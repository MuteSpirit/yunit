//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// asserts.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "asserts.h"
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <cmath>

#if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#	define SNPRINTF	_snprintf
#else
#	define SNPRINTF	snprintf
#endif

YUNIT_NS_BEGIN

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool areEqValues(const long long int expected, const long long int actual)
{
    return expected == actual;
}

/// \brief All float point types have imprecission, so we must know precission of type for normal check
/// \param[in] delta must be positive
static bool areEqValues(const long double expected, const long double actual, const long double  delta, const long double typePrecission = 0)
{
    return (fabs(expected - actual) - fabs(delta)) <= typePrecission;
}

bool areEqValues(const float expected, const float actual, const long double delta)
{
    return areEqValues(expected, actual, delta, 0.0000001f);
}

bool areEqValues(const double expected, const double actual, const long double delta)
{
    return areEqValues(expected, actual, delta, 0.000000000000001);
}

bool areEqValues(const long double expected, const long double actual, const long double delta)
{
    return areEqValues(expected, actual, delta, 0.000000000000001);
}

bool areEqValues(const void *expected, const void *actual)
{
	return expected == actual;
}

bool areEqValues(const char *expected, const char *actual)
{
	return expected == actual || (NULL != expected && NULL != actual && 0 == ::strcmp(expected, actual));
}

bool areEqValues(const wchar_t *expected, const wchar_t *actual)
{
	return expected == actual || (NULL != expected && NULL != actual && 0 == ::wcscmp(expected, actual));
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct TestException : std::exception
{
    enum {msgSize = 16 * 1024};
    char msg_[msgSize];

    virtual const char* what() const throw()
    {
        return msg_;
    }
};

void throwException(const char *prefix, const long long expected, const long long actual, bool mustBeEqual)
{
    TestException e;
    
	int writtenBytes = SNPRINTF(e.msg_, e.msgSize - 1, mustBeEqual ? "%s" "%lld != %lld" : "%s" "%lld == %lld", prefix, expected, actual);
    e.msg_[writtenBytes] = '\0';

    throw e;
}

void throwException(const char *prefix, const void* expected, const void* actual, bool mustBeEqual)
{
    TestException e;
    
	int writtenBytes = SNPRINTF(e.msg_, e.msgSize - 1, mustBeEqual ? "%s" "\"0x%X\" != \"0x%X\"" : "%s" "\"0x%X\" == \"0x%X\"",
        prefix, reinterpret_cast<unsigned int>(expected), reinterpret_cast<unsigned int>(actual));
    e.msg_[writtenBytes] = '\0';

    throw e;
}

static void makeEqualMessage(char* dst, const unsigned int dstSize, const bool mustBeEqual, const wchar_t* expected, const wchar_t* actual);

void throwException(const char *prefix, const wchar_t* expected, const wchar_t* actual, bool mustBeEqual)
{
    TestException e;
    
	int offset = SNPRINTF(e.msg_, e.msgSize - 1, "%s", prefix);
    makeEqualMessage(e.msg_ + offset, e.msgSize - offset, mustBeEqual, expected ? expected : L"NULL", actual ? actual : L"NULL");

    throw e;
}

static void makeEqualMessage(char* dst, const unsigned int dstSize, const bool mustBeEqual, const wchar_t* expected, const wchar_t* actual)
{
    size_t writtenBytes = ::wcstombs(dst, expected, dstSize);
    size_t offset = writtenBytes;

    if (offset >= dstSize)
        return;

    const char* equalSign = mustBeEqual ? " != " : " == ";
    const size_t equalSignLen = ::strlen(equalSign);
    ::strncpy(dst + offset, equalSign, equalSignLen);
    offset += equalSignLen;

    if (offset >= dstSize)
        return;

    writtenBytes = ::wcstombs(dst + offset, actual, dstSize - offset);
}

void throwException(const char *prefix, const char* expected, const char* actual, bool mustBeEqual)
{
    TestException e;
    
	int writtenBytes = SNPRINTF(e.msg_, e.msgSize - 1, mustBeEqual ? "%s" "\"%s\" != \"%s\"" : "%s" "\"%s\" == \"%s\"", 
	                                                   prefix,
	                                                   expected ? expected : "NULL",
	                                                   actual ? actual : "NULL");
    e.msg_[writtenBytes] = '\0';

    throw e;
}

void throwException(const char *prefix,
                    const double expected, const double actual, const double delta,
					bool mustBeEqual)
{
    TestException e;
    
	int writtenBytes = SNPRINTF(e.msg_, e.msgSize - 1, mustBeEqual ? "%s" "%f != %f +- %f" : "%s" "%f == %f +- %f", prefix, expected, actual, delta);
    e.msg_[writtenBytes] = '\0';

    throw e;
}

YUNIT_NS_END
