#include "tests.h"
#include "asserts.h"
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
                TestRegistry::FailCtx *failCtx = static_cast<TestRegistry::FailCtx*>(data);
                printf("%s\n", failCtx->errmsg_);
                delete [] failCtx->errmsg_;
                delete failCtx;
            }
        }

        unsigned int ignoredTestCounter_;
        unsigned int successTestCounter_;
        unsigned int failTestCounter_;
    }
    testCtx;

    testRegistry->executeAllTests(TestResultHandler::onTestEvent, &testCtx); 

    printf("ignored - %u" "\n"
           "success - %u" "\n"
           "fail    - %u" "\n",
           testCtx.ignoredTestCounter_,
           testCtx.successTestCounter_,
           testCtx.failTestCounter_);

    return 0;
}

TEST(smokeTest)
{}

TEST(failedTest)
{
    isTrue(false);
}

_TEST(ignoredTest)
{
    isTrue(false);
}

struct SampleFixture
{
    unsigned int value_;

    SampleFixture()  // a'la setUp
    : value_(0)
    {
    }

    ~SampleFixture() // a'la tearDown
    {
    }
};

TEST1(successTestWithFixture, SampleFixture)
{
    isNull(value_);
}

TEST1(failTestWithFixture, SampleFixture)
{
    areEq(1, value_);
}
