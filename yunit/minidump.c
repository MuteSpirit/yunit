//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// minidump.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifdef __cplusplus
extern "C" {
#endif
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
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
typedef struct _CrashContext
{
    DWORD threadId_;            //!< id of thread, which has raised exception
    EXCEPTION_POINTERS* ep_;    //!< pointer for exception information structure
} CrashContext;

static const wchar_t* coronerCmdLineFmtStr = L"lua5.1.exe -l minidump -e \"minidump.dumpProcess(%u, %u)\"";

static void runCoroner(EXCEPTION_POINTERS* ep)
{
    enum {cmdLineSize = 2 * MAX_PATH};
    static wchar_t cmdLine[cmdLineSize] = {0};

    static CrashContext crashContext = {0};
    static STARTUPINFOW si;
    static PROCESS_INFORMATION pi;

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
    return 0;
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
    int pid = 0;
    const void* excContextAdr = 0;
    int argInd = 0;

    unsigned long bytesRead = 0;

    int useCrashContext = 0;

    HANDLE hCrashProc = INVALID_HANDLE_VALUE;
    HANDLE hDumpFile = INVALID_HANDLE_VALUE;
    CrashContext crashContext = {0};
    wchar_t tempPath[MAX_PATH + 1];
    wchar_t tempFileName[MAX_PATH + 1];
    MINIDUMP_EXCEPTION_INFORMATION mei;
    int minidumpType = MiniDumpWithDataSegs | 
                       MiniDumpWithHandleData |
                       MiniDumpWithUnloadedModules |
                       MiniDumpWithProcessThreadData;
    int rc = 0;

    argInd = 1;
    if (0 == lua_isnumber(L, argInd))
    {
        lua_pushboolean(L, 0);
        lua_pushfstring(L, "invalide 1st argument (integer expected, got %s)", lua_typename(L, lua_type(L, argInd)));
        return 2;
    }
    pid = lua_tointeger(L, 1);

    if (0 == lua_isnumber(L, argInd))
    {
        lua_pushboolean(L, 0);
        lua_pushfstring(L, "invalide 2nd argument (integer expected, got %s)", lua_typename(L, lua_type(L, argInd)));
        return 2;
    }
    excContextAdr = lua_topointer(L, 1);

    hCrashProc = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_TERMINATE | PROCESS_VM_READ, FALSE, pid);
    if (INVALID_HANDLE_VALUE == hCrashProc)
    {
        lua_pushboolean(L, 0);
        lua_pushfstring(L, "error opening process (pid = %u): %u\n", pid, GetLastError());
		return 2;
    }

    if (0 == DebugActiveProcess(pid))
    {
        CloseHandle(hCrashProc);

        lua_pushboolean(L, 0);
        lua_pushfstring(L, "can't attach to process (pid = %u): %u\n", pid, GetLastError());
		return 2;
    }
    //
    // Read CrashContext from crashing process memory 
    if (excContextAdr && 0 != ReadProcessMemory(hCrashProc, excContextAdr, &crashContext, sizeof(CrashContext), &bytesRead))
        useCrashContext = 1;
    //
    // Create temporary file for dump writing
    rc = GetTempPathW(MAX_PATH, tempPath);
    if (0 == rc || rc > MAX_PATH)
    {
        CloseHandle(hCrashProc);

        lua_pushboolean(L, 0);
        lua_pushfstring(L, "GetTempPath failed: %u\n", GetLastError());
		return 2;
    }

    if (0 == GetTempFileNameW(tempPath, L"_yu", 0 /*create unique name*/, tempFileName))
    {
        CloseHandle(hCrashProc);

        lua_pushboolean(L, 0);
        lua_pushfstring(L, "GetTempFileNameW failed: %u\n", GetLastError());
		return 2;
    }

    hDumpFile = CreateFileW(tempFileName, GENERIC_WRITE, 0, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
    if (INVALID_HANDLE_VALUE == hDumpFile)
    {
        CloseHandle(hCrashProc);

        lua_pushboolean(L, 0);
        lua_pushfstring(L, "can't create file for dump failed: %u\n", GetLastError());
		return 2;
    }

    if (useCrashContext)
    {
        mei.ThreadId          = crashContext.threadId_;
        mei.ExceptionPointers = crashContext.ep_;
	    mei.ClientPointers    = TRUE;
    }

    rc = MiniDumpWriteDump(hCrashProc, pid, hDumpFile, 
        (MINIDUMP_TYPE)minidumpType, (useCrashContext) ? &mei : NULL, NULL, 0);

    CloseHandle(hDumpFile);
    CloseHandle(hCrashProc);

    if (FALSE == rc)
    {
        lua_pushboolean(L, 0);
        lua_pushfstring(L, "MiniDumpWriteDump failed: %u\n", GetLastError());
		return 2;
    }

    lua_pushboolean(L, 1);
    return 1;
}

static int raiseException(lua_State* L)
{
    return (int)L / (int)NULL;
}

static const luaL_Reg minidumpLib[] = 
{
    {"setCrashHandler", setUnhandleExceptionHandler},
    {"dumpProcess", dumpProcess},
    {"raiseException", raiseException},
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
