//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// c_string_coll.h
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef _C_STRING_COLL_HEADER_
#define _C_STRING_COLL_HEADER_

#include "type_int.h"
#include "c_string_gen.h"

namespace afl {

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// class CStrColl

class CStrColl
{
public:
	CStrColl(wchar_t* pb, wchar_t* pe);
	CStrColl(wchar_t* pb, wchar_t* pe, const wchar_t* ps1);
	CStrColl(wchar_t* pb, wchar_t* pe, CChain& cchain1);
	CStrColl(wchar_t* pb, wchar_t* pe, const CChain& cchain1);	
	
	int_t collate(const wchar_t* ps2);
	int_t collate(CChain& cchain2);
	int_t collate(const CChain& cchain2);
	
	int_t collate(const wchar_t* ps2, const wchar_t* ps3);
	int_t collate(const wchar_t* ps2, CChain& cchain3);
	int_t collate(const wchar_t* ps2, const CChain& cchain3);
	
	int_t collate(CChain& cchain2, const wchar_t* ps3);
	int_t collate(CChain& cchain2, CChain& cchain3);
	int_t collate(CChain& cchain2, const CChain& cchain3);
	
	int_t collate(const CChain& cchain2, const wchar_t* ps3);
	int_t collate(const CChain& cchain2, CChain& cchain3);
	int_t collate(const CChain& cchain2, const CChain& cchain3);
	
private:
	wchar_t* keyGenerate(const wchar_t* ps);
	
private:
	CStrGen cstrGen_;
	
	wchar_t* key1_;
	//wchar_t* key2_;
	//wchar_t* key3_;
};


} //namespace afl

#endif	//_C_STRING_COLL_HEADER_
