#include "test_unit_engine.h"
#include <stdio.h>
#include <string.h>

template<typename T, void (T::*method)(LoggerPtr)>
void callAdapter(void *t, LoggerPtr logger)
{
    (static_cast<T*>(t)->*method)(logger);
}

struct StubTest : public Test
{
    typedef StubTest Self;
    StubTest()
    {
        self_ = this;
        setUp_ = &callAdapter<Self, &Self::setUp>;
        test_ = &callAdapter<Self, &Self::test>;
        tearDown_ = &callAdapter<Self, &Self::tearDown>;
        name_ = &Self::name;
    }
    
    void setUp(LoggerPtr logger)
    {
        logger->success_(logger->self_);
    };
    
    void test(LoggerPtr logger)
    {
        logger->success_(logger->self_);
    };
    
    void tearDown(LoggerPtr logger)
    {
        logger->success_(logger->self_);
    };
    
    const char* name() const
    {
        return "StubTest";
    }

    static const char* name(const void *self)
    {
        return ((const StubTest*)self)->name();
    }
};

Test** loadTestContainer(const char *path)
{
    static StubTest test;
    static Test* tests[] = {&test, NULL};

    return tests;
}

const char** testContainerExtensions()
{
    static const char* supportedExts[] = {"t.so", NULL};
    return supportedExts;
}
