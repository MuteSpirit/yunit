//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// aux.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define YUNIT_DLL_EXPORTS
#include "aux.h"
#include "lua_wrapper.h"

#ifdef _WIN32
#  include <windows.h>
#  include <tlhelp32.h>
#else
#  include <unistd.h>
#  include <dirent.h>
#  include <cctype>
#  include <sys/stat.h>
#  include <string.h>
#endif

namespace YUNIT_NS {

struct Aux {};

extern "C"
int YUNIT_API luaopen_yunit_aux(lua_State* L)
{
    Lua::State lua(L);
    luaWrapper<Aux>().regLib(lua, "yunit.aux");
    return 1;
}


#if defined(_WIN32)
LUA_META_METHOD(Aux, allProccesses)
{
    Lua::State lua(L);

    const DWORD currentProcessFlag = 0;
    HANDLE procSnapshot = ::CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, currentProcessFlag);
    if (INVALID_HANDLE_VALUE == procSnapshot)
        return lua.error("undefined WinAPI behaviour: CreateToolhelp32Snapshot return INVALID_HANDLE_VALUE");

    PROCESSENTRY32 procInfo;
    procInfo.dwSize = sizeof(procInfo);
    
    if (FALSE == ::Process32First(procSnapshot, &procInfo))
    {
        ::CloseHandle(procSnapshot);
        return lua.error("undefined WinAPI behaviour: Process32First return FALSE");;
    }

    lua.push(Lua::Table());
    const int procsTableIdx = lua.top();
    int procInfoIdx;
    do
    {
        lua.push(Lua::Table());     /* stack: procInfo */
        procInfoIdx = lua.top();

        lua.push(procInfo.th32ParentProcessID);
        lua.setfield(procInfoIdx, "ppid");

        lua.push(procInfo.szExeFile);
        lua.setfield(procInfoIdx, "exe");

        lua.push(procInfo.th32ProcessID);   /* stack: procInfo, pid */
        lua.push(Lua::Value(procInfoIdx));  /* stack: procInfo, pid, procInfo */
        lua.settable(procsTableIdx);        /* stack: procInfo */

        lua.pop(1);                         /* stack: */
    }
    while(::Process32Next(procSnapshot, &procInfo));

    ::CloseHandle(procSnapshot);
    return 1;
}

#else // defined(_WIN32)

LUA_META_METHOD(Aux, pid)
{
    Lua::State lua(L);
#if defined(_WIN32)
    lua.push(::GetCurrentProcessId());
#else
    lua.push(getpid());
#endif
    return 1;
}

LUA_META_METHOD(Aux, exePath)
{
    Lua::State lua(L);
    
    enum Args {pidIdx = 1};

#define MAXLINE 8192 // got from pstree.p
    enum {pathSize = MAXLINE};
    char path[pathSize];

    int cChars = snprintf(path, pathSize - 1, "/proc/%d/exe", lua_tointeger(L, pidIdx));
    path[cChars] = '\0';

    errno = 0;
    ssize_t cBytes = readlink(path, path, pathSize - 1);
    if (-1 == cBytes)
    {
        return lua.error("readlink('%s') failed, errno = %d, EACCES = %d\n", path, errno, EACCES);
    }
    else
    {
        lua.push(path, cBytes);
        return 1;
    }
}

LUA_META_METHOD(Aux, ppid)
{
    Lua::State lua(L);
    
    enum Args {pidIdx = 1};

#define MAXLINE 8192 // got from pstree.p
    enum {pathSize = MAXLINE};
    char path[pathSize];

    int cChars = snprintf(path, pathSize - 1, "/proc/%d/status", lua_tointeger(L, pidIdx));
    path[cChars] = '\0';

    FILE* f = fopen(path, "r");
    if (NULL == f)
        return lua.error("Cannot open '%s' to detect parent proccess pid", path);

    const char* ppidPrefix = "PPid:";
    enum {ppidPrefixSize = sizeof("PPid:") - sizeof(char)};

    while (fgets(path, pathSize, f) != NULL) /* until reach EOF */
    {
        const char* p = path;
        for (; *p && !isalpha(*p); ++p)
            ;
                
        if (0 == strncmp(ppidPrefix, p, ppidPrefixSize))
        {
            unsigned long ppid = 0;
            
            for (p += ppidPrefixSize; *p && !isdigit(*p); ++p)
                ;
            
            for (; *p && isdigit(*p); ++p)
            {
                ppid *= 10;
                ppid += *p - '0';
            }

            lua.push(ppid);
            fclose(f);
            return 1;
        }
    }

    fclose(f);
    return 0;
}

#endif // defined(_WIN32)

} // namespace YUNIT_NS
