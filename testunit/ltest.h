//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// test.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifdef __cplusplus
extern "C" {
#endif

#include "lua/lauxlib.h"
#include "lua/lualib.h"

#ifdef __cplusplus
}
#endif

#ifndef _CPPUNIT_PORTABILITY_HEADER_
#include "test.h"
#endif

CPPUNIT_NS_BEGIN

int luaTestCaseSetUp(lua_State *L);
int luaTestCaseTest(lua_State *L);
int luaTestCaseTearDown(lua_State *L);
int getTestList(lua_State *L);

CPPUNIT_NS_END

extern "C"
int AFL_API luaopen_cppunit(lua_State *L);
