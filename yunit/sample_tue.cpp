#include "sample_tue.h"

#ifndef _WIN32
#  include <dlfcn.h>
#endif

static Test *aloneTest = NULL;

void registerTest(TestPtr test)
{
    aloneTest = test;
}

Test* loadTestContainer(const char *path)
{
    dlopen(path, RTLD_NOW | RTLD_GLOBAL);

    return aloneTest;
}

