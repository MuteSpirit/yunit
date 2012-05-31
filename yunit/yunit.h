//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// yunit.h
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if _MSC_VER > 1000
#  pragma once
#endif

/// @todo Replace all starage guards with #pragma once, because it avoid thinking about it names
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

#define TOSTR_(name) #name 
#define TOSTR(name) TOSTR_(name)

#define TOWSTR_(name) L ## #name
#define TOWSTR(name) TOWSTR_(name)


#ifdef CONFIG_HEADER
#  include TOSTR(CONFIG_HEADER)
#endif

#ifndef TS_T
#	if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#		define TS_SNPRINTF	_snprintf
#	else
#		define TS_SNPRINTF	snprintf
#	endif
#endif

#endif // _YUNIT_TEST_HEADER_
