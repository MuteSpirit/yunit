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
	enum ExceptionCStrGenType { exceptMemoryIncorrect,				//������� ������ ������ ��� ����������
								exceptMemoryNotEnough,				//������������ �������
								exceptDataMissing,					//����������� ������ (����������� ��� ��������� 1, collate � ���������� 2)
								exceptInputCharacterIncorrect,		//�������� ������ �� ������� ������
								exceptRunTimeError					//������ ������������ �� ������ Run-Time Library
							};
	
	ExceptionCStrGen(const ExceptionCStrGenType errType);

	ExceptionCStrGenType getErrType() const;

protected:
	ExceptionCStrGenType errType_;
};


} //namespace afl

#endif	//_C_STRING_EXCEPTION_HEADER_
