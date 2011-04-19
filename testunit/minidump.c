//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// minidump.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifdef __cplusplus
extern "C" {
#endif
#include <lua/lua.h>
#include <lua/lauxlib.h>
#include <lua/lualib.h>
#ifdef __cplusplus
}
#endif

#include <windows.h>
#include <dbghelp.h>

#ifndef MINIDUMP_API
#	if defined(_WIN32) || defined(__WIN32__) || defined(__CYGWIN__)
#		define MINIDUMP_API __declspec(dllexport)
#	elif defined(__GNUC__) && defined(GCC_HASCLASSVISIBILITY)
#		define MINIDUMP_API __attribute__ ((visibility("default")))
#	else
#		define MINIDUMP_API
#	endif
#endif

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct CrashContext
{
    DWORD threadId_;            //!< id of thread, which has raised exception
    EXCEPTION_POINTERS* ep_;    //!< pointer for exception information structure
};

enum {cmdLineSize = 2 * MAX_PATH};
static wchar_t cmdLine[cmdLineSize] = {0};

static void runCoroner(EXCEPTION_POINTERS* ep)
{
    const wchar_t* coronerCmdLineFmtStr = L"lua5.1.exe -l minidump -e \"minidump.dumpProcess(%u, %u)\"";

    static struct CrashContext crashContext = {0};
    STARTUPINFOW si;
    PROCESS_INFORMATION pi;

    crashContext.ep_ = ep;
    crashContext.threadId_ = GetCurrentThreadId();

    swprintf(cmdLine, cmdLineSize, coronerCmdLineFmtStr, GetCurrentProcessId(), &crashContext);

    memset(&si, 0, sizeof(si));
    si.cb = sizeof(si);

    if (CreateProcessW(0, cmdLine, 0, 0, FALSE, 0, 0, 0, &si, &pi) != 0)
    {
        // Wait for our killer work finish.
        // We not use Sleep, because external process may do nothing with us (not kill) and current
        // process will be in infinite deadlock
        WaitForSingleObject(pi.hProcess, INFINITE);
    }

    // Finish failing process
    ExitProcess(1);
}

static LONG __stdcall unhandledExceptionFilter(EXCEPTION_POINTERS* ep)
{
    // Serialization enter into handler
    static __declspec(align(32)) LONG entryCount = 0;

    if (InterlockedExchange(&entryCount, 1) == 1)
        Sleep(INFINITE);

    runCoroner(ep);
}

static int setUnhandleExceptionHandler(lua_State* L)
{
    // Function no raise errors
    SetUnhandledExceptionFilter(unhandledExceptionFilter);
    (void)L;
    return 0;
}

static int dumpProcess(lua_State* L)
{
    int argInd = 0, pid = 0, excContextAdr = 0;
    
    argInd = 1;
    if (lua_isnumber(L, argInd))
    {
        lua_pushboolean(L, 0);
        lua_pushfstring(L, "invalide 1st argument (integer expected, got %s)", lua_typename(L, lua_type(L, argInd)));
        return 2;
    }
    pid = lua_tointeger(L, 1);

    if (lua_isnumber(L, argInd))
    {
        lua_pushboolean(L, 0);
        lua_pushfstring(L, "invalide 1st argument (integer expected, got %s)", lua_typename(L, lua_type(L, argInd)));
        return 2;
    }
    excContextAdr = lua_tointeger(L, 1);

    return 1;
}

static const luaL_Reg minidumpLib[] = 
{
    {"setCrashHandler", setUnhandleExceptionHandler},
    {"dumpProcess", dumpProcess},
    {NULL, NULL}
};

#ifdef __cplusplus
extern "C"
#endif
int MINIDUMP_API luaopen_minidump(lua_State *L)
{
    luaL_register(L, "minidump", minidumpLib);
	return 0;
}
