//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// mine.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define YUNIT_DLL_EXPORTS
#include "yunit.h"
#include "mine.h"

#if defined(_WIN32)
#   ifndef _WINBASE_
#       include <specstrings.h>
#       define DECLSPEC_IMPORT __declspec(dllimport)
#       define WINBASEAPI extern "C" DECLSPEC_IMPORT
#       define VOID void
#       define WINAPI __stdcall
        typedef unsigned long DWORD, *PDWORD, *LPDWORD;

        WINBASEAPI
        VOID
        WINAPI
        Sleep(
            __in DWORD dwMilliseconds
            );
#   endif  //  _WINBASE_

#else
#   include <unistd.h>
#endif

namespace YUNIT_NS {

Seconds::Seconds(unsigned int num)
: num_(num)
{
}

void sleep(Seconds seconds)
{
#if defined(_WIN32)
    ::Sleep(1000 * seconds.num_);
#else
    sleep(seconds.num_);
#endif
}

Mine::Mine(DamageAgent* damageAgent)
: damageAgent_(damageAgent)
{
}

void Mine::setTimer(Seconds /*seconds*/)
{
}

void Mine::neutralize()
{
}

//extern "C"
//int YUNIT_API luaopen_yunit_mine(lua_State* L)
//{
//    using namespace YUNIT_NS;
//    LuaState lua(L);
//
//    luaWrapper<Mine>().regLib(lua, "yunit.mine");
//    return 1;
//}

//static unsigned int mineTimeout = 0;

//LUA_META_METHOD(Mine, start)
//{
//    enum Args {timeoutInSecIdx = 1};
//    
//}

} // namespace YUNIT_NS
