#include "sample_tue.h"

static Test *aloneTest;

void registerTest(TestPtr test)
{
    aloneTest = test;
}

const char** testContainerExtensions()
{
    static const char* supportedExts[] = {"t.so", NULL};
    return supportedExts;
}

Test* loadTestContainer(const char *path)
{
    return aloneTest;
}

