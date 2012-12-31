#include "asserts.h"

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


    return 0;
}
