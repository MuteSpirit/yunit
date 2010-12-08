//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// c_string_function.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//#include <string.h>
//#include <limits.h>
//#include <stdlib.h>
//#include <errno.h>

#include "c_string_function.h"


namespace afl {

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// substring

CChain substring(const wchar_t* pb, size_t offs, size_t cnt)
{
	return CChain(pb, offs, cnt);
}

CChain substring(const wchar_t* pb, size_t offs)
{
	return CChain(pb + offs);
}

CChain substring(const wchar_t* pb, const wchar_t* pe)
{
	return CChain(pb, pe);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// upper

CChain upper(const wchar_t* pb, size_t offs, size_t cnt)
{
	return CChain(pb, offs, cnt, enCaseUpper);
}

CChain upper(const wchar_t* pb, size_t offs)
{
	return CChain(pb + offs, enCaseUpper);
}

CChain upper(const wchar_t* pb, const wchar_t* pe)
{
	return CChain(pb, pe, enCaseUpper);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// lower

CChain lower(const wchar_t* pb, size_t offs, size_t cnt)
{
	return CChain(pb, offs, cnt, enCaseLower);
}

CChain lower(const wchar_t* pb, size_t offs)
{
	return CChain(pb + offs, enCaseLower);
}

CChain lower(const wchar_t* pb, const wchar_t* pe)
{
	return CChain(pb, pe, enCaseLower);
}

} //namespace afl

