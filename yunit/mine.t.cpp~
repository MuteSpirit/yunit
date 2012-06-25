//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// mine.t.cpp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "cppunit.h"

using namespace YUNIT_NS;

test(mine_usecase)
{
    struct MockTerminator : public Terminator
    {
        void boom()
        {
            occured_ = true;
        }
        bool occured_;
    }
    terminator;
    
    terminator.occured_ = false;
    
    Mine mine(&terminator);
    mine.boomAfterSuchSeconds(0);

    isTrue(terminator.occured_);
}
