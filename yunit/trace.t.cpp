//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// trace.t.cpp
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "cppunit.h"
#include <cstring>

test(parse_error_message_with_windows_full_path)
{
    const char toLuaErrorHandlerMessage[] = "e:\\path\\to\\source.lua:13: expected table, but was nil";
    const char* colonAfterDiskLetter = ::strchr(toLuaErrorHandlerMessage, ':');
    const char* colonBeforeLine = ::strchr(colonAfterDiskLetter + 1, ':');
    const char* colonAfterLine = ::strchr(colonBeforeLine + 1, ':');
    isTrue(colonAfterDiskLetter < colonBeforeLine && colonBeforeLine < colonAfterLine);

    //areEq("e:\\path\\to\\source.lua", errSource);
    //areEq(13, errLine);
    //areEq("expected table, but was nil", errMessage);
}