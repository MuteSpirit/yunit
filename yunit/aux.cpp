//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// aux.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define YUNIT_DLL_EXPORTS
#include "aux.h"
#include "lua_wrapper.h"

#ifdef _WIN32
#else
#  include <unistd.h>
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

LUA_META_METHOD(Aux, parentProcPath)
{
    Lua::State lua(L);

// get from pstree.c
#define MAXLINE 8192
    enum {pathSize = MAXLINE};
    char path[pathSize];

    pid_t ppid = getppid();
    pid_t sessionLeaderPid = getsid(ppid);
    int cChars = snprintf(path, pathSize - 1, "/proc/%d/exe", sessionLeaderPid);
    path[cChars] = '\0';

    ssize_t cBytes = readlink(path, path, pathSize - 1);
    if (-1 == cBytes)
        return lua.error("Cannot define parent process exe path: readlink returned %d, errno = %d", cBytes, errno);
   
    lua.push(path, cBytes);
    return 1;
}

} // namespace YUNIT_NS
