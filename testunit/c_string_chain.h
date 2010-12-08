//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// c_string_chain.h
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef _C_STRING_CHAIN_HEADER_
#define _C_STRING_CHAIN_HEADER_

//#include "type_int.h"

namespace afl {


enum CaseChar { enCaseNative, enCaseUpper, enCaseLower };

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// class CChain

class CChain
{
public:
	CChain(const wchar_t* pb, CaseChar caseChar = enCaseNative);
	CChain(const wchar_t* pb, size_t offs, CaseChar caseChar = enCaseNative);
	CChain(const wchar_t* pb, size_t offs, size_t cnt, CaseChar caseChar = enCaseNative);
	CChain(const wchar_t* pb, const wchar_t* pe, CaseChar caseChar = enCaseNative);

protected:
	friend class CStrGen;
	friend class CStrColl;

	const wchar_t* begin() const;
	
	bool endOfChain(const wchar_t* pc) const;
	wchar_t charOfChain(const wchar_t* pc) const;
	
	//CChain* operator()();

private:
	const wchar_t* pb_;
	const wchar_t* pe_;
	
	bool (*endOf_)(const wchar_t* pc, const wchar_t* pe);
	wchar_t (*charOf_)(const wchar_t* pc);
};


} //namespace afl

#endif	//_C_STRING_CHAIN_HEADER_
