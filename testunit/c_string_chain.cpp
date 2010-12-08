//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// c_string_chain.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//#include <string.h>
#include <wchar.h>
//#include <limits.h>
//#include <stdlib.h>
//#include <errno.h>



#include "c_string_chain.h"


namespace afl {

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// functions

bool endByNull(const wchar_t* pc, const wchar_t*)
{
	return *pc == L'\0';
}

bool endByAddr(const wchar_t* pc, const wchar_t* pe)
{
	return pc > pe;
}

wchar_t charNative(const wchar_t* pc)
{
	return *pc;
}

wchar_t charUpper(const wchar_t* pc)
{
	return ::towupper(*pc);
}

wchar_t charLower(const wchar_t* pc)
{
	return ::towlower(*pc);
}


typedef wchar_t (*TypeFunctionPtr)(const wchar_t*);

TypeFunctionPtr charOf(CaseChar caseChar)
{
	switch (caseChar)
	{
		case enCaseUpper:	return &charUpper;
		case enCaseLower:	return &charLower; 
		default:			return &charNative;
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// class CChain

//: pb_(pb), pe_(0), endOf_(&afl::CChain::endByNull), charOf_(&CChain::charNative)//(charOf(caseChar))

CChain::CChain(const wchar_t* pb, CaseChar caseChar)
: pb_(pb), pe_(0), endOf_(&endByNull), charOf_(charOf(caseChar))
{
	//endOf_ = &endByNull;
}

CChain::CChain(const wchar_t* pb, size_t offs, CaseChar caseChar)
: pb_(pb + offs), pe_(0), endOf_(&endByNull), charOf_(charOf(caseChar))
{}

CChain::CChain(const wchar_t* pb, size_t offs, size_t cnt, CaseChar caseChar)
: pb_(pb + offs), pe_(pb + offs + cnt - 1), endOf_(&endByAddr), charOf_(charOf(caseChar))
{}

CChain::CChain(const wchar_t* pb, const wchar_t* pe, CaseChar caseChar)
: pb_(pb), pe_(pe), endOf_(&endByAddr), charOf_(charOf(caseChar))
{}

//CChain* CChain::operator()()
//{
//	return this;
//}

const wchar_t* CChain::begin() const
{
	return pb_;
}

bool CChain::endOfChain(const wchar_t* pc) const
{
	return (*endOf_)(pc, pe_);
}

wchar_t CChain::charOfChain(const wchar_t* pc) const
{
	return (*charOf_)(pc);
}

} //namespace afl

