#include "test_unit_engine.h"
#include <stdio.h>
#include <string.h>

struct StubTest
{
    void setUp(LoggerPtr logger)
    {
        printf("StubTest::setUp\n");
    };
    
    void test(LoggerPtr logger)
    {
        printf("StubTest::test\n");
        logger->success_(logger->self_, NULL);
    };
    
    void tearDown(LoggerPtr logger)
    {
        printf("StubTest::tearDown\n");
    };
};

void setUpStubTest(void *self, LoggerPtr logger)
{
    ((StubTest*)self)->setUp(logger);
}

void testStubTest(void *self, LoggerPtr logger)
{
    ((StubTest*)self)->test(logger);
}

Test** loadTestContainer(const char *path)
{
    static StubTest stubTest;
    static Test test;
    static Test* tests[] = {&test, NULL};

    memset(&test, 0, sizeof(test));
    test.self_ = &stubTest;
    test.setUp_ = &setUpStubTest;
    test.test_ = &testStubTest;
    
    return tests;
}

static const char* supportedExts[] = {"t.so", NULL};

const char** testContainerExtensions()
{
    return supportedExts;
}
