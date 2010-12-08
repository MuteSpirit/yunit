//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// c_string_coll.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#include <string.h>
#include <limits.h>
//#include <stdlib.h>
#include <errno.h>



#include "c_string_coll.h"
#include "c_string_exception.h"

namespace afl {

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// class CStrColl	

CStrColl::CStrColl(wchar_t* pb, wchar_t* pe)
: cstrGen_(pb, pe), key1_(0)
{}

CStrColl::CStrColl(wchar_t* pb, wchar_t* pe, const wchar_t* ps1)
: cstrGen_(pb, pe), key1_(0)
{
	key1_ = keyGenerate(ps1);
	
	cstrGen_.saveRecovery();
}

CStrColl::CStrColl(wchar_t* pb, wchar_t* pe, CChain& cchain1)
: cstrGen_(pb, pe), key1_(0)
{}

CStrColl::CStrColl(wchar_t* pb, wchar_t* pe, const CChain& cchain1)
: cstrGen_(pb, pe), key1_(0)
{}

wchar_t* CStrColl::keyGenerate(const wchar_t* ps)
{
	size_t cntCapacity = cstrGen_.capacity();
	size_t cntKey = wcsxfrm(cstrGen_.currentPosition(), ps, cntCapacity);			//Возвращает без терминирующего нуля; 
	
	if (cntKey >= cntCapacity)
	{
		if (cntKey == INT_MAX)
		{
			int_t errNo;
			_get_errno(&errNo);
			
			if (errNo == EILSEQ)
				throw ExceptionCStrGen(ExceptionCStrGen::exceptInputCharacterIncorrect);
			else
				throw ExceptionCStrGen(ExceptionCStrGen::exceptRunTimeError);
		}	
	
		throw ExceptionCStrGen(ExceptionCStrGen::exceptMemoryNotEnough);
	}
	
	cstrGen_.post(cntKey);
	
	return cstrGen_.c_str();
}

int_t CStrColl::collate(const wchar_t* ps2)
{
	if (key1_ == 0)
		throw ExceptionCStrGen(ExceptionCStrGen::exceptDataMissing);
	
	cstrGen_.doRecovery();
	
	wchar_t* key2 = keyGenerate(ps2);
	
	return wcscmp(key1_, key2);
}

int_t CStrColl::collate(CChain& cchain2)
{
	return 0;
}

int_t collate(const CChain& cchain2)
{
	return 0;
}

} //namespace afl

