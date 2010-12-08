//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// c_string_function.h
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef _C_STRING_FUNCTION_HEADER_
#define _C_STRING_FUNCTION_HEADER_

#include "c_string_chain.h"

namespace afl {

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// functions

CChain substring(const wchar_t* pb, size_t offs, size_t cnt);
CChain substring(const wchar_t* pb, size_t offs = 0);
CChain substring(const wchar_t* pb, const wchar_t* pe);

CChain upper(const wchar_t* pb, size_t offs, size_t cnt);
CChain upper(const wchar_t* pb, size_t offs = 0);
CChain upper(const wchar_t* pb, const wchar_t* pe);

CChain lower(const wchar_t* pb, size_t offs, size_t cnt);
CChain lower(const wchar_t* pb, size_t offs = 0);
CChain lower(const wchar_t* pb, const wchar_t* pe);

//int compare(...);
//
//size_type find(...);
//                
//size_type find_first_of(...);
//size_type find_first_not_of(...);
//                            
//size_type find_last_of(...);
//size_type find_last_not_of(...);


} //namespace afl

#endif	//_C_STRING_FUNCTION_HEADER_
