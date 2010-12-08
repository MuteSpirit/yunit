//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// c_string_exception.h
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef _C_STRING_EXCEPTION_HEADER_
#define _C_STRING_EXCEPTION_HEADER_

//#include "type_int.h"

namespace afl {

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// class ExceptionCStrGen

class ExceptionCStrGen
{
public:
	enum ExceptionCStrGenType { exceptMemoryIncorrect,				//Неверно задана память для размещения
								exceptMemoryNotEnough,				//Недостаточно паямяти
								exceptDataMissing,					//Отсутствуют данные (конструктор без параметра 1, collate с параметром 2)
								exceptInputCharacterIncorrect,		//Неверный символ во входной строке
								exceptRunTimeError					//Ошибка определенная на уровне Run-Time Library
							};
	
	ExceptionCStrGen(const ExceptionCStrGenType errType);

	ExceptionCStrGenType getErrType() const;

protected:
	ExceptionCStrGenType errType_;
};


} //namespace afl

#endif	//_C_STRING_EXCEPTION_HEADER_
