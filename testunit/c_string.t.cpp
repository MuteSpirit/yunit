//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// c_string.test.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if defined(TS_TEST)


#include <wchar.h>
#include "test.h"

//// add
#include <locale.h>

#include "type_int.h"
#include "c_string_gen.h"
#include "c_string_coll.h"
#include "c_string_function.h"

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class CStrTestSuite :  public CPPUNIT_NS::TestSuite
{
public:
	CStrTestSuite();

protected:
	void setUp();
	void createTestCases();
	void tearDown();

public:
	bool setUpCall_;

private:
	void testGen();
	void testColl();
};

CPPUNIT_TEST_MAP_BEGIN(CStrTestSuite)
CPPUNIT_TEST(testGen)
CPPUNIT_TEST(testColl)
CPPUNIT_TEST_MAP_END()

//////////////////////////////////////////////////////////////////////////////////////////////////////////////

void CStrTestSuite::setUp()
{
	wchar_t* locale = 0;
	locale = _wsetlocale(LC_ALL, L"Russian");	//TS_TRACE(L"locale = _wsetlocale(LC_ALL, L\"Russian\");\n");
	//locale = _wsetlocale(LC_ALL, L"Belarusian");	//TS_TRACE(L"locale = _wsetlocale(LC_ALL, L\"Belarusian\");\n");
	//locale = _wsetlocale(LC_ALL, L"Ukrainian");	//TS_TRACE(L"locale = _wsetlocale(LC_ALL, L\"Ukrainian\");\n");
	//locale = _wsetlocale(LC_ALL, L"Polish");	//TS_TRACE(L"locale = _wsetlocale(LC_ALL, L\"Polish\");\n");
	
	//locale = _wsetlocale(LC_ALL, L"English");	//TS_TRACE(L"locale = _wsetlocale(LC_ALL, L\"English\");\n");
	//locale = _wsetlocale(LC_ALL, L"French");	//TS_TRACE(L"locale = _wsetlocale(LC_ALL, L\"French\");\n");
	
	//if (locale != 0)	{	TS_TRACE(L"\tЛокализация: %ws\n\n", locale); }		//Возвращает:	Локализация: Russian_Russia.1251
	//else				{	TS_TRACE(L"\tЛокализация: нет\n\n"); }
	
	//CPPUNIT_ASSERT(locale == 0);
	
	if (locale != 0)
		setUpCall_ = true;
}

void CStrTestSuite::tearDown()
{
	//wchar_t* locale = 0;
	//locale = _wsetlocale(LC_ALL, L"");
	
	setUpCall_ = false;
}

void CStrTestSuite::testGen()
{
	using namespace afl;
	
	const size_t cBuf = 1024 * 10;
	wchar_t buf[cBuf];
	
	wchar_t* pb = buf;
	wchar_t* pe = buf + cBuf -1;
	
	afl::CStrGen csg(pb, pe);
	
	csg << L"abcdefg " << L"абвгдеё ";
	
	wchar_t* seqDigit = L" 12345678";
	//afl::CChain cch(seqDigit + 1, 4);
	
	csg << substring(seqDigit, 1, 4) << substring(seqDigit, 5);
	
	wchar_t* res1 = csg.c_str();
	int_t cmp1 = wcscmp(res1, L"abcdefg абвгдеё 12345678");			CPPUNIT_ASSERT(cmp1 == 0);
	
	csg << L"HELLO, " << L"WORLD!";
	wchar_t* res2 = csg.c_str();
	int_t cmp2 = wcscmp(res2, L"HELLO, WORLD!");					CPPUNIT_ASSERT(cmp2 == 0);
	
	int_t cmp3 = _wcsicmp(res2, L"hello, world!");					CPPUNIT_ASSERT(cmp3 == 0);
}

void CStrTestSuite::testColl()
{
	using namespace afl;

	const size_t cBuf = 1024 * 10;
	wchar_t buf[cBuf];
	
	wchar_t* pb = buf;
	wchar_t* pe = buf + cBuf -1;
	
	afl::CStrColl csc(pb, pe, L"аеёио");
	int_t res = 0;
	
	res = csc.collate(L"аее\x0308ио");			CPPUNIT_ASSERT(res == 0);
	res = csc.collate(L"аеёио");				CPPUNIT_ASSERT(res == 0);
	res = csc.collate(L"аеаио");				CPPUNIT_ASSERT(res > 0);
	res = csc.collate(L"аеоио");				CPPUNIT_ASSERT(res < 0);
}

#endif // defined(TS_TEST)
