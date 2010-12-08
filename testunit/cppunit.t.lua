--------------------------------------------------------------------------------------------------------------
module("CppUnitTest", lunit.testcase, package.seeall)
--------------------------------------------------------------------------------------------------------------

function cppunitTest()
    -- load cppunit.dll
    package.cpath = "../_bin/?.dll;"..package.cpath;
    local cppUnit = require("cppunit");
    assert_not_nil(cppUnit);
    assert_not_nil(cppunit);
    assert_equal("table", type(package.loaded["cppunit"]));
    assert_not_nil(cppunit.getTestList);
    assert_equal("function", type(cppunit.getTestList));
    
    local testList, testCase;
    
    testList = cppUnit.getTestList();
    assert_equal(0, #testList);
    
    local testRunner = require("test_runner");
    testRunner.loadCppDriver("../_bin/cppunit_test_driver.t.dll");

    testList = cppUnit.getTestList();
    assert_equal(1, #testList);
    
    -- check validation of C++ TestCase interface
    testCase = testList[1];

    assert_not_nil(testCase.name_);
    assert_equal("string", type(testCase.name_));
    assert_not_nil(testCase.setUp);
    assert_equal("function", type(testCase.setUp));
    assert_not_nil(testCase.test);
    assert_equal("function", type(testCase.test));
    assert_not_nil(testCase.tearDown);
    assert_equal("function", type(testCase.tearDown));

    local testObserver = testRunner.TestObserver:new();
    local mockTestListener = testRunner.TestListener:new();
    mockTestListener.error_ = false;
    function mockTestListener:addError()
        mockTestListener.error_ = true;
    end
    function mockTestListener:addFailure()
        mockTestListener.error_ = true;
    end
    testObserver:addTestListener(mockTestListener);
    
    testRunner.runTestCase(testCase.name_, testCase, testObserver);
    assert_false(mockTestListener.error_);
end
