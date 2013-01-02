//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// yunit.h
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef _YUNIT_YUNIT_HEADER_
#define _YUNIT_YUNIT_HEADER_

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
/// You may define your own ASSERT_MESSAGE_PREFIX macro for your specific IDE
#ifndef ASSERT_MESSAGE_PREFIX
#  ifdef _MSC_VER
// implementation for MS Visual Studio error message format
#    define ASSERT_MESSAGE_PREFIX(file, line) file "(" TOSTR(line) ") : "
#  else
#    define ASSERT_MESSAGE_PREFIX(file, line) file ":" TOSTR(line) ":0: error: "
#  endif
#endif


#ifndef TS_T
#	if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#		define TS_SNPRINTF	_snprintf
#	else
#		define TS_SNPRINTF	snprintf
#	endif
#endif

#endif // _YUNIT_YUNI_HEADER_
