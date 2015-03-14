# C++ Unit Test Syntax #

```
////////////////////////////////////////////////////////////
// component.t.cpp
//
////////////////////////////////////////////////////////////

#include <yunit/test.h>     // for yUnit >= 0.3.9
#include <yunit/cppunit.h>  // for yUnit >= 0.3.16

test(testA)
{
    isTrue(true);
    isFalse(false);
}

fixture(fixtureA)
{
    // will be executed BEFORE every test, used this fixture
    setUp()         
    {
        a_ = 10;
    }
    // will be executed AFTER every test, used this fixture
    tearDown()
    {
        a_ = 0;
    }
 
    // fixture members:
    // they are used by tests. Every test use it's own copy of them
    int a_;         
};

// fixtureA::setUp() will be called before testB and fixtureA::tearDown() - after.
test1(testB, fixtureA)
{
    areEq(10, a_); 
}

fixture(fixtureB)
{
    setUp()
    {
        b_ = 11;
    }

    tearDown()
    {
        b_ = 0;
    }

    int b_;
};


// fixtureA::setUp() and fixtureB::setUp() will be executed before testC
// fixtureB::tearDown() and fixtureA::tearDown() will be executed after testC
test2(testC, fixtureA, fixtureB)
{
    areEq(10, a_); 
    areEq(11, b_); 
}

// ignored test case (may have uncompiled code in body)
_test(testD)
{
    int uncompiledCode[0] = {1};
}

// ignored test case (may have uncompiled code in body)
_test1(testE, fixtureA)
{
    int uncompiledCode[0] = {1};
}

// ignored test case (may have uncompiled code in body)
_test2(testF, fixtureA, fixtureB)
{
    int uncompiledCode[0] = {1};
}
```

## Assert Functions ##

  1. Check logical expression with:
    * isTrue(actual)
    * isFalse(actual)
  1. Check for (non)equation integer values:
    * isNull(actual)
    * isNotNull(actual)
    * areEq(expected, actual)
    * areNotEq(expected, actual)
  1. Check for (non)equation float values:
    * areDoubleEq(expected, actual, delta)
    * areDoubleNotEq(expected, actual, delta)
  1. Check for raising exceptions:
    * willThrow(expression, exceptionType)
    * noSpecificThrow(expression, exceptionType)
    * noAnyCppThrow(expression)
    * noSehThrow(expression)