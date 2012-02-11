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

LUA_META_METHOD(Aux, allProccesses)
{
    Lua::State lua(L);

#if defined(_WIN32)
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
#else

#define MAXLINE 8192 // got from pstree.p
    enum {pathSize = MAXLINE};
    char path[pathSize];

    DIR *procDir;
    struct dirent *dirEnt;
    const char* procPath = "/proc/";

    procDir = opendir(procPath);
    if (NULL == procDir)
        return lua.error("cannot open '%s' directory", procPath);

    struct stat dirStat;
    lua.push(Lua::Table());
    const int procsTableIdx = lua.top();
    int dirEntIdx;
    
    while (dirEnt = readdir(procDir))
    {
        lstat(dirEnt->d_name, &dirStat);
        if (!S_ISDIR(dirStat.st_mode))
            continue;
        
        if (strcmp(".", dirEnt->d_name) == 0 || strcmp("..", dirEnt->d_name) == 0)
            continue;
        
        // detect that dirname is pid number
        bool isNotPid = false;
        for (const char* p = dirEnt->d_name; p && *p; ++p)
        {
            if (!isdigit(*p))
            {
                isNotPid = true;
                break;
            }
        }
        
        if (isNotPid)
            continue;
        
        lua.push(Lua::Table());     /* stack: procInfo */
        dirEntIdx = lua.top();

        int cChars = snprintf(path, pathSize - 1, "/proc/%s/exe", dirEnt->d_name);
        path[cChars] = '\0';
        
//        errno = 0;
//        ssize_t cBytes = readlink(path, path, pathSize - 1);
//        if (-1 == cBytes)
//        {
//            printf("readlink('%s') failed, errno = %d, EACCES = %d\n", path, errno, EACCES);
//            lua.remove(dirEntIdx);
//            continue;
//        }
//        else
//        {
//            lua.push(path, cBytes);
//            lua.setfield(dirEntIdx, "exe");
//        }
//
        cChars = snprintf(path, pathSize - 1, "/proc/%s/status", dirEnt->d_name);
        path[cChars] = '\0';
        
        FILE* f = fopen(path, "r");
        if (NULL == f)
        {
            closedir(procDir);
            return lua.error("Cannot open '%s' to detect parent proccess pid", path);
        }
        
        const char* ppidPrefix = "Ppid:";
        enum {ppidPrefixSize = sizeof("Ppid:") - sizeof(char)};
        
        while (fgets(path, pathSize, f) != NULL) /* until reach EOF? */
        {
            if (0 == strncmp(ppidPrefix, path, ppidPrefixSize))
            {
                unsigned long ppid = 0;
                char c;
                for (const char* p = path + ppidPrefixSize; p && *p; ++p)
                {
                    c = *p;
                    if (' ' == c)
                        continue;
                    else if (!isdigit(c))
                        break;
                    else
                    {
                        ppid *= 10;
                        ppid += c - '0';
                    }
                }
                
                lua.push(ppid);
                lua.setfield(dirEntIdx, "ppid");
                break;
            }
        }
                
        fclose(f);
        
        lua.push(atoi(dirEnt->d_name));
        lua.push(Lua::Value(dirEntIdx));
        lua.settable(procsTableIdx);
        
        lua.remove(dirEntIdx);
    }

    closedir(procDir);
            

#endif // defined(_WIN32)
    return 1;
}

} // namespace YUNIT_NS
