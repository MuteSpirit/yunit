#include "tests.h"
#include <cstdio>

using namespace YUNIT_NS;

int main(int /*argc*/, char ** /*argv*/)
{
    struct TestResultHandler
    {
        typedef TestResultHandler Self;

        TestResultHandler()
        : ignoredTestCounter_(0) 
        , successTestCounter_(0)
        , failTestCounter_(0)
        {}

        static void onTestEvent(void *ctx, void *arg, void *data)
        {
            Self *self = static_cast<Self*>(ctx);

            if (TestRegistry::ignored == arg)
                ++(self->ignoredTestCounter_);
            else if (TestRegistry::success == arg)
                ++(self->successTestCounter_);
            else if (TestRegistry::fail == arg)
            {
                ++(self->failTestCounter_);
                char *errmsg = static_cast<char*>(data);
                printf("%s\n", errmsg);
                delete [] errmsg;
            }

        }

        unsigned int ignoredTestCounter_;
        unsigned int successTestCounter_;
        unsigned int failTestCounter_;
    }
    testCtx;

    testRegistry->executeAllTests(TestResultHandler::onTestEvent, &testCtx); 

    printf("success - %u" "\n"
           "fail    - %u" "\n", testCtx.successTestCounter_, testCtx.failTestCounter_);

    return 0;
}

TEST(smokeTest)
{}
