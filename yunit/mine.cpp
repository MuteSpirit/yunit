//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// mine.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
    We use "wide" variant (with suffix W in name, i.e. CreateEventW) of WinAPI functions instead of 
    "ansi" variants, i.e. CreateEventA, because "ansi" variants are only wrapper over "wide" variants
*/

#define YUNIT_DLL_EXPORTS
#include "yunit.h"
#include "mine.h"
#include "lua_wrapper.h"


#ifdef _WIN32

#define UNICODE
#include <windows.h>

#ifndef _WINBASE_
#include <specstrings.h>
#define DECLSPEC_IMPORT __declspec(dllimport)
#define WINBASEAPI extern "C" DECLSPEC_IMPORT
#define VOID void
#define WINAPI __stdcall
 
typedef unsigned long DWORD, *PDWORD, *LPDWORD;

#define INFINITE            0xFFFFFFFF  // Infinite timeout

typedef void *PVOID;
typedef void *LPVOID;
typedef PVOID HANDLE;
typedef int BOOL;

#define INVALID_HANDLE_VALUE ((HANDLE)(LONG_PTR)-1)

typedef struct _SECURITY_ATTRIBUTES {
    DWORD nLength;
    LPVOID lpSecurityDescriptor;
    BOOL bInheritHandle;
} SECURITY_ATTRIBUTES, *PSECURITY_ATTRIBUTES, *LPSECURITY_ATTRIBUTES;

#define CONST const
typedef wchar_t WCHAR;
typedef __nullterminated CONST WCHAR *LPCWSTR, *PCWSTR;

#ifndef NULL
#ifdef __cplusplus
#define NULL    0
#else
#define NULL    ((void *)0)
#endif
#endif

#ifndef FALSE
#define FALSE               0
#endif

#ifndef TRUE
#define TRUE                1
#endif


WINBASEAPI
VOID
WINAPI
Sleep(
    __in DWORD dwMilliseconds
    );

WINBASEAPI
BOOL
WINAPI
CloseHandle(
    __in HANDLE hObject
    );

WINBASEAPI
__out_opt
HANDLE
WINAPI
CreateEventW(
    __in_opt LPSECURITY_ATTRIBUTES lpEventAttributes,
    __in     BOOL bManualReset,
    __in     BOOL bInitialState,
    __in_opt LPCWSTR lpName
    );
#define CreateEvent  CreateEventW

WINBASEAPI
DWORD
WINAPI
WaitForSingleObject(
    __in HANDLE hHandle,
    __in DWORD dwMilliseconds
    );

WINBASEAPI
BOOL
WINAPI
SetEvent(
    __in HANDLE hEvent
    );

#endif  //  _WINBASE_

#include <process.h>

#else
#include <unistd.h>
#endif

namespace YUNIT_NS {

#ifdef _WIN32
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define MineImplWin32 MineImpl

class MineImplWin32
{
public:
    MineImplWin32(DamageAgent* damageAgent);
    ~MineImplWin32();

    void setTimer(Seconds seconds);
    void neutralize();

    static void mineThread(void* param);

private:
    DamageAgent* damageAgent_;
    HANDLE thread_;
    unsigned long timeToBoom_;
    HANDLE orderReceivedEvent_;
};

class UndefinedWinApiBehaviour 
{
};
#else 

#define MineImplStub MineImpl

class MineImplStub
{
    MineImplStub(DamageAgent*) {}

    void setTimer(Seconds) {}
    void neutralize() {}
};

#endif // #ifdef _WIN32

class ProcessKiller : public DamageAgent
{
public:
    void boom() { abort(); }
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
Seconds::Seconds(unsigned long num)
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

#ifdef _WIN32
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void MineImplWin32::mineThread(void* param)
{
    MineImplWin32* mineImpl = reinterpret_cast<MineImplWin32*>(param);

    for (;;) // don't use while(1) to avoid compiler warning "expression is constant"
    {
        int waitRes = ::WaitForSingleObject(mineImpl->orderReceivedEvent_, mineImpl->timeToBoom_);

        if (WAIT_TIMEOUT == waitRes)
            break;
        else if (WAIT_FAILED == waitRes || WAIT_ABANDONED == waitRes)
            throw UndefinedWinApiBehaviour();
    }

    mineImpl->damageAgent_->boom();
}

MineImplWin32::MineImplWin32(DamageAgent* damageAgent)
: damageAgent_(damageAgent)
, thread_(INVALID_HANDLE_VALUE)
, orderReceivedEvent_(::CreateEvent(0, FALSE, FALSE, 0))
, timeToBoom_(INFINITE)
{
    thread_ = reinterpret_cast<HANDLE>(_beginthread(mineThread, 0, this));
    if (0 == thread_)
        throw UndefinedWinApiBehaviour();
}

MineImplWin32::~MineImplWin32()
{
    timeToBoom_ = 0;
    ::SetEvent(orderReceivedEvent_);
    ::CloseHandle(thread_);
}

void MineImplWin32::setTimer(Seconds seconds)
{
    if (INFINITE == timeToBoom_)
    {
        timeToBoom_ = seconds.num_;
        ::SetEvent(orderReceivedEvent_);
    }
}

void MineImplWin32::neutralize()
{
    if (INFINITE != timeToBoom_)
    {
        timeToBoom_ = INFINITE;
        ::SetEvent(orderReceivedEvent_);
    }
}

#endif // #ifdef _WIN32

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
Mine::Mine(DamageAgent* damageAgent)
: impl_(new MineImpl(damageAgent))
{
}

Mine::~Mine()
{
    delete impl_;
}

void Mine::setTimer(Seconds seconds)
{
    impl_->setTimer(seconds);
}

void Mine::neutralize()
{
    impl_->neutralize();
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
static ProcessKiller processKiller;
static Mine mine(&processKiller);

extern "C"
int YUNIT_API luaopen_yunit_mine(lua_State* L)
{
    Lua::State lua(L);
    luaWrapper<Mine>().regLib(lua, "yunit.mine");
    return 1;
}

LUA_META_METHOD(Mine, sleep)
{
    Lua::State lua(L);

    enum Args {timeoutInSecIdx = 1};

    if (!lua.isinteger(timeoutInSecIdx))
        lua.error("integer expected as argument, but was %s", lua.typeName(timeoutInSecIdx));

    sleep(Seconds(lua_tounsigned(lua, timeoutInSecIdx)));
    return 0;
}

LUA_META_METHOD(Mine, setTimer)
{
    Lua::State lua(L);

    enum Args {timeoutInSecIdx = 1};

    if (!lua.isinteger(timeoutInSecIdx))
        lua.error("integer expected as argument, but was %s", lua.typeName(timeoutInSecIdx));

    mine.setTimer(Seconds(lua_tounsigned(lua, timeoutInSecIdx)));
    return 0;
}

LUA_META_METHOD(Mine, turnoff)
{
    mine.neutralize();
    return 0;
}

} // namespace YUNIT_NS
