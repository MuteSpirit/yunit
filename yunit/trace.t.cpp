//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// trace.t.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "cppunit.h"
#include "trace.h"
#include <cstring>

using namespace YUNIT_NS;


test(parse_error_message_with_windows_full_path)
{
    const char toLuaErrorHandlerMessage[] = "e:\\path\\to\\source.lua:13: expected table, but was nil";
    enum {messageLength = (sizeof(toLuaErrorHandlerMessage) - sizeof('\0')) / sizeof(char)};
    const char* toLuaErrorHandlerMessageEnd = toLuaErrorHandlerMessage + messageLength;
    
    const char* colonAfterDiskLetter = ::strchr(toLuaErrorHandlerMessage, ':');
    const char* colonBeforeLine = ::strchr(colonAfterDiskLetter + 1, ':');
    const char* colonAfterLine = ::strchr(colonBeforeLine + 1, ':');
    isTrue(colonAfterDiskLetter < colonBeforeLine && colonBeforeLine < colonAfterLine);

    LuaErrorMessage::ParseResult res = LuaErrorMessage::parse(toLuaErrorHandlerMessage);
    
    areEq(toLuaErrorHandlerMessage, res.sourceBegin_);
    areEq(colonBeforeLine, res.sourceEnd_);

    areEq(colonBeforeLine + 1, res.lineBegin_);
    areEq(colonAfterLine, res.lineEnd_);
    
    areEq(colonAfterLine + 1 + sizeof(' '), res.messageBegin_);
    areEq(toLuaErrorHandlerMessageEnd, res.messageEnd_);
}

