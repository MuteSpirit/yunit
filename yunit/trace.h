//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// trace.h
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#ifndef _YUNIT_TRACE_HEADER_
#define _YUNIT_TRACE_HEADER_

#include "yunit.h"

namespace YUNIT_NS {

struct YUNIT_API LuaErrorMessage
{
    struct ParseResult
    {
        const char* sourceBegin_;
        const char* sourceEnd_;

        const char* lineBegin_;
        const char* lineEnd_;

        const char* messageBegin_;
        const char* messageEnd_;
    };

    static ParseResult parse(const char * const s);
};


} // namespace YUNIT_NS

#endif // _YUNIT_TRACE_HEADER_
