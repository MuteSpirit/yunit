//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// c_string_gen.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#include <string.h>
#include <limits.h>
#include <stdlib.h>
#include <errno.h>



#include "c_string_gen.h"
//#include "type_int.h"
#include "c_string_exception.h"

namespace afl {

enum EndAddr { offsEndAddr = 1 };	//if (pe == последний адрес) { = 1 } else (pe == последний адрес + 1) { = 0 }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// class CStrGen

CStrGen::CStrGen(wchar_t* pb, wchar_t* pe)
: pb_(pb), pe_(pe), pc_(pb), pcRecovery_(pe), strc_(pb)
{
	if (pe_ < pb_)		//offs
		throw ExceptionCStrGen(ExceptionCStrGen::exceptMemoryIncorrect);
}

CStrGen& CStrGen::operator<<(const wchar_t* pb)
{
	while (*pb != 0)
	{
		if (pc_ >= pe_)
			throw ExceptionCStrGen(ExceptionCStrGen::exceptMemoryNotEnough);
		
		*pc_++ = *pb++;
	}
	
	return *this;
}

//CStrGen& CStrGen::operator<<(CChain& cchain)
//{
//	const wchar_t* p = cchain.begin();
//	
//	while (!cchain.endOfChain(p))
//	{
//		if (pc_ >= pe_)
//			throw ExceptionCStrGen(ExceptionCStrGen::exceptMemoryNotEnough);
//		
//		*pc_++ = cchain.charOfChain(p++);
//	}
//		
//	return *this;
//}

CStrGen& CStrGen::operator<<(const CChain& cchain)
{
	const wchar_t* p = cchain.begin();
	
	while (!cchain.endOfChain(p))
	{
		if (pc_ >= pe_)
			throw ExceptionCStrGen(ExceptionCStrGen::exceptMemoryNotEnough);
		
		*pc_++ = cchain.charOfChain(p++);
	}
	
	return *this;
}

//void CStrGen::addChain(const wchar_t* pb, const wchar_t* pe)
//{
//	while (pb <= pe)
//	{
//		if (pc_ >= pe_)
//			throw ExceptionCStrGen(ExceptionCStrGen::exceptMemoryNotEnough);
//		
//		*pc_++ = *pb++;
//	}
//}

wchar_t* CStrGen::c_str()
{
	if (pc_ >= pe_)
		throw ExceptionCStrGen(ExceptionCStrGen::exceptMemoryNotEnough);
	
	*pc_++ = L'\0';
	
	wchar_t* strc = strc_;
	strc_ = pc_;
	return strc;
}

size_t CStrGen::capacity()
{
	return pe_ - pc_ + 1;	//offs
}

wchar_t* CStrGen::currentPosition() const
{
	return pc_;
}

void CStrGen::post(size_t cnt)
{
	pc_ += cnt;
}

void CStrGen::saveRecovery()
{
	pcRecovery_ = pc_;
}

void CStrGen::doRecovery()
{
	pc_ = pcRecovery_;
	strc_ = pcRecovery_;
}


	
} //namespace afl

