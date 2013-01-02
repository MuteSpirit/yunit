#include "asserts.h"
#include <cstdio>

int main(int /*argc*/, char ** /*argv*/)
{
    isTrue(true);
    isFalse(false);
    isNull(NULL);
    isNotNull(1);

    areEq(1, 1);
    areEq(-1, -1);
    areEq(1., 1.);
    areEq("", "");
    areEq(L"", L"");
    areEq("a", "a");
    areEq(L"a", L"a");

    areNotEq(1, 2);
    areNotEq(1., 2.);
    areNotEq(-1, -2);
    areNotEq(-1., -2.);
    areNotEq("", "foo");
    areNotEq(L"", L"foo");

    areEq((void*)main, (void*)main);

    struct ___
    {
        static void foo() {}
    };
    areNotEq((void*)main, (void*)___::foo);

    willThrow(std::exception mustBeCatched; throw mustBeCatched;, std::exception);

    try
    {
        isTrue(false);
    }
    catch (std::exception &e)
    {
        printf("%s\n", e.what());
    }

    try
    {
        areEq(1, 0);
    }
    catch (std::exception &e)
    {
        printf("%s\n", e.what());
    }

    try
    {
        areEq("string", "строка");
    }
    catch (std::exception &e)
    {
        printf("%s\n", e.what());
    }

    try
    {
        areDoubleEq(1.0, 5.99, 0.00001);
    }
    catch (std::exception &e)
    {
        printf("%s\n", e.what());
    }

    return 0;
}
