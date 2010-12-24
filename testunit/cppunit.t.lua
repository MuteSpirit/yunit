local luaUnit = require('testunit.luaunit');
module('cppunit.t', luaUnit.testmodule, package.seeall);


TEST_SUITE("CppUnitTest")
{
    TEST_CASE{"cppunitTest", function(self)
        -- load cppunit.dll
        package.cpath = "../_bin/?.dll;"..package.cpath;
        local cppUnit = require("cppunit");
        ASSERT_IS_NOT_NIL(cppUnit);
        ASSERT_IS_NOT_NIL(cppunit);
        ASSERT_EQUAL("table", type(package.loaded["cppunit"]));
        ASSERT_IS_NOT_NIL(cppunit.getTestList);
        ASSERT_EQUAL("function", type(cppunit.getTestList));
        
        package.loadlib("../_bin/cppunit.t.dll", "");
        
        local testList, testCase;
        
        testList = cppUnit.getTestList();
        ASSERT_NOT_EQUAL(0, #testList);
        
        -- check validation of C++ TestCase interface
        testCase = testList[1];

        ASSERT_IS_NOT_NIL(testCase.name_);
        ASSERT_EQUAL("string", type(testCase.name_));
        ASSERT_IS_NOT_NIL(testCase.isIgnored_);
        ASSERT_EQUAL("boolean", type(testCase.isIgnored_));
        ASSERT_IS_NOT_NIL(testCase.setUp);
        ASSERT_EQUAL("function", type(testCase.setUp));
        ASSERT_IS_NOT_NIL(testCase.test);
        ASSERT_EQUAL("function", type(testCase.test));
        ASSERT_IS_NOT_NIL(testCase.tearDown);
        ASSERT_EQUAL("function", type(testCase.tearDown));
    end
    };
};