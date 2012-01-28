//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// mine.h
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
#if _MSC_VER > 1000
#  pragma once
#endif

#ifndef _YUNIT_MINE_HEADER_
#define _YUNIT_MINE_HEADER_

#include "yunit.h"

namespace YUNIT_NS {

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
struct YUNIT_API Seconds
{
    Seconds(unsigned long num);
    unsigned long num_;
};

void YUNIT_API sleep(Seconds seconds);

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
class DamageAgent
{
public:
    virtual void boom() = 0;
};


class MineImpl;

class YUNIT_API Mine
{
public:
    Mine(DamageAgent* damageAgent);
    ~Mine();

    void setTimer(Seconds seconds);
    void turnoff();

private:
    MineImpl* impl_;
};

} // namespace YUNIT_NS

#endif // _YUNIT_MINE_HEADER_