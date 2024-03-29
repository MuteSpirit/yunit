//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// mine.t.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "cppunit.h"
#include "mine.h"

namespace YUNIT_NS {

struct MockDamageAgent : public DamageAgent
{
    void boom()
    {
        occured_ = true;
    }

    MockDamageAgent()
    : occured_(false)
    {}

    bool occured_;
};

test(mine_usecase)
{
    MockDamageAgent terminator;
    Mine mine(&terminator);

    mine.setTimer(Seconds(0));
    sleep(Seconds(1));

    isTrue(terminator.occured_);
    mine.turnoff();
}

test(mine_neutralize)
{
    MockDamageAgent terminator;
    Mine mine(&terminator);

    mine.setTimer(Seconds(1));
    mine.turnoff();
    sleep(Seconds(1));

    isFalse(terminator.occured_);
}


} // namespace YUNIT_NS