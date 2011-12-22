//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// yunit.h
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifdef _MSC_VER
#  pragma once
#endif

#ifndef _YUNIT_TEST_HEADER_
#define _YUNIT_TEST_HEADER_

#define YUNIT_NS yUnit

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef YUNIT_API
#   if defined _WIN32 || defined __CYGWIN__
#       define YUNIT_HELPER_DLL_IMPORT __declspec(dllimport)
#       define YUNIT_HELPER_DLL_EXPORT __declspec(dllexport)
#       define YUNIT_HELPER_DLL_LOCAL
#   else
#       if __GNUC__ >= 4
#           define YUNIT_HELPER_DLL_IMPORT __attribute__ ((visibility ("default")))
#           define YUNIT_HELPER_DLL_EXPORT __attribute__ ((visibility ("default")))
#           define YUNIT_HELPER_DLL_LOCAL  __attribute__ ((visibility ("hidden")))
#       else
#           define YUNIT_HELPER_DLL_IMPORT
#           define YUNIT_HELPER_DLL_EXPORT
#           define YUNIT_HELPER_DLL_LOCAL
#       endif
#   endif

#   ifdef YUNIT_DLL_EXPORTS // defined if we are building the YUNIT DLL (instead of using it)
#       define YUNIT_API YUNIT_HELPER_DLL_EXPORT
#   else
#       define YUNIT_API YUNIT_HELPER_DLL_IMPORT
#   endif
#   define YUNIT_LOCAL YUNIT_HELPER_DLL_LOCAL
#endif

#ifndef TS_T
#	if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#		define TS_SNPRINTF	_snprintf
#	else
#		define TS_SNPRINTF	snprintf
#	endif
#endif

#endif // _YUNIT_TEST_HEADER_
