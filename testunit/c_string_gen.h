//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// c_string_gen.h
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef _C_STRING_GEN_HEADER_
#define _C_STRING_GEN_HEADER_

#include "type_int.h"
#include "c_string_chain.h"

namespace afl {

//typedef uint32_t size_t

class CChain;
class CStrColl;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// class CStrGen

class CStrGen
{
public:
	CStrGen(wchar_t* pb, wchar_t* pe);
	
	CStrGen& operator<<(const wchar_t* pb);
	
	//CStrGen& operator<<(CChain& cchain);
	CStrGen& operator<<(const CChain& cchain);
	
	wchar_t* c_str();
	
	size_t capacity();
	
protected:
	friend class CStrColl;
	
	wchar_t* currentPosition() const;
	
	void post(size_t cnt);
	
	void saveRecovery();
	void doRecovery();
	
private:
	wchar_t* pb_;
	wchar_t* pe_;
	wchar_t* pc_;			//Текущая позиция
	wchar_t* pcRecovery_;	//Восстановление текущей позиции
	wchar_t* strc_;			//Текущая формируемая строка C
	
};

} //namespace afl

#endif	//_C_STRING_GEN_HEADER_
