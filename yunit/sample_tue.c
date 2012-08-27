#include "test_unit_engine.h"
#include <stdio.h>

Test* loadTestContainer(const char *path)
{
    return 0;
}

static const char* supportedExts[] = {"t.so", NULL};

const char** testContainerExtensions()
{
    return supportedExts;
}
