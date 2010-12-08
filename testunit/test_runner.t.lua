--- \fn fakeFunction()
--- \brief Do nothing. Apply it for disable work some function.

--- \class TestListener
--- \brief Base class for all Test Listeners classes. Contain interface functions and their empty definitions

--- \class TestObserver
--- \brief Variation of pattern observer for events during test execution process. Contain several 
--- TestListeners and inform then about test events

--- \fn TestObserver:callListenersFunction(functionName, ...)
--- \brief Function call function with name 'functionName' of each TestListener, whitch contained at list 'listeners'
--- \param[in] functionName Each TestListener must have function with such name.
--- \param[in] ... Arguments, whith will be sended to the function 
--- \return None

--- \fn isTestFunction(functionName)
--- \brief Function is consided as test function if it contain word 'test' at the begining or
--- at the end of it's name
--- \param[in] functionName Name of function for check
--- \return boolean

--- \fn runTestCase(testcase, testResult)
--- \brief This is "Frame of Test". Run setUp(), test() and tearDown() function of testcase.
--- \param[in] testcase TestCase for run
--- \param[in] testResult TesObserver for log events
--- \return None

--- \var GlobalTestCaseList
--- \brief Global list of TestCaseRecord

--- \class TestCaseRecord
--- \brief Class, containing link to TestCase object and some additional info for active test list management

--- \fn loadLuaDriver(filePath)
--- \brief Load tests from Lua file
--- \param[in] filePath Path to the file, whitch name correspond to wildcard "*.t.lua"
--- \return None

--- \fn loadCppDriver(filePath)
--- \brief Load C++ test driver (in view of DLL) to the current process
--- \param[in] filePath Path to the file, whitch name correspond to wildcard "*.t.dll"
--- \return None

--- \fn isLuaTestDriver(filePath)
--- \brief Check if 'filePath' is correspond to wildcard "*.t.lua"
--- \return true or false

--- \fn isCppTestDriver(filePath)
--- \brief Check if 'filePath' is correspond to wildcard "*.t.dll"
--- \return true or false

--- \fn initializeTestUnits()
--- \brief Load modules, whitch allow to work with Lua and C++ tests
--- \return None

--- \fn loadTestDrivers(filePathList)
--- \brief Make first initialization, then load tests from files of 'filePathList',
--- then copy ALL Lua and C++ test to thr global test list. Call this function only one time at script
--- \param[in] filePathList Table with list of test (even Lua and C++ simultaneously) file paths. 
--- \return None

--- \fn copyAllLuaTestCasesToGlobalTestList()
--- \brief Get list of tests from Lua part of unit test engine and push them into global test list
--- of TestRunner
--- \todo internal and external names of test cases are not equal, external contains additional test suite name
--- \return None

--- \fn copyAllCppTestCasesToGlobalTestList()
--- \brief Get list of tests from C++ part of unit test engine and push them into global test list
--- of TestRunner
--- \todo internal and external names of test cases are not equal, external contains additional test suite name
--- \return None

--- \fn runAllTestCases(testObserver)
--- \brief Run all TestCases from global test list
--- \param[in] testObserver Object, whitch wlii be received messages from and about tests
--- \return None

local require, print = require, print;

local testListeners = require("afl.test_listeners");
local testRunner = require("afl.test_runner");
local luaUnit = require("afl.lua_unit");

local _G = _G;

local testModuleName = "TestRunnerTest";
--------------------------------------------------------------------------------------------------------------
module(testModuleName, lunit.testcase)
--------------------------------------------------------------------------------------------------------------

------------------------------------------------------
function testTestListenerCreation()
    assert_not_nil(testRunner.TestListener:new());
end

------------------------------------------------------
function testObserverCreationTest()
    assert_not_nil(testRunner.TestObserver:new());
end

------------------------------------------------------
function testObserverTestAddFailureFunctionTest()
    local ttpl1 = testListeners.TextTestProgressListener:new();
    local ttpl2 = testListeners.TextTestProgressListener:new();
    local tr = testRunner.TestObserver:new();
    local fakeTestCaseName = testModuleName;
    local fakeTestName = "testTestObserver";
    local fakeFailureMessage = "This is test message. It hasn't usefull information";
    
    function ttpl1:addFailure(testCaseName, failureMessage)
        assert_equal(fakeTestCaseName, testCaseName);
        assert_equal(fakeFailureMessage, failureMessage);
    end
    
    function ttpl2:addFailure(testCaseName, failureMessage)
        assert_equal(fakeTestCaseName, testCaseName);
        assert_equal(fakeFailureMessage, failureMessage);
    end
    
    tr:addTestListener(ttpl1);
    tr:addTestListener(ttpl2);
    assert_equal(2, #tr.testListeners);
    
    tr:addFailure(fakeTestCaseName, fakeFailureMessage);
end

------------------------------------------------------
function testObserverStartTestsFunctionTest()
    local ttpl1 = testListeners.TextTestProgressListener:new();
    local ttpl2 = testListeners.SciteTextTestProgressListener:new();
    local tr = testRunner.TestObserver:new();
    
    function ttpl1:startTests()
        self.startTestsCall = true;
    end
    
    function ttpl2:startTests()
        self.startTestsCall = true;
    end
    
    tr:addTestListener(ttpl1);
    tr:addTestListener(ttpl2);
    
    tr:startTests();
     
    assert_true(ttpl1.startTestsCall);
    assert_true(ttpl2.startTestsCall);
end

function runTestCaseTest()
    -- clear lists of tests
    luaUnit.TestRegistry:reset();
    testRunner.GlobalTestCaseList = {};

    local TEST_FIXTURE = luaUnit.TEST_FIXTURE;
    local TEST_SUITE = luaUnit.TEST_SUITE;
    local TEST_CASE_EX = luaUnit.TEST_CASE_EX;

    setUpCalled_ = false;
    tearDownCalled_ = false;
    
    TEST_FIXTURE('CallSetUpAndTearDownTestFixture')
    {
        setUp = function(self)
            setUpCalled_ = true;
        end;
        tearDown = function(self)
            tearDownCalled_ = true;
        end;
    };

    assert_not_nil(_G["CallSetUpAndTearDownTestFixture"]);
    
    TEST_SUITE("CallSetUpAndTearDownTestSuite")
    {
        TEST_CASE_EX{"CallSetUpAndTearDownTestCase", "CallSetUpAndTearDownTestFixture", function(self)
            
        end
        };
    };
    
    assert_equal(2, #luaUnit.TestRegistry.testsuites);
    assert_equal(1, #luaUnit.TestRegistry.testsuites[2].testcases);
    
    testRunner.copyAllLuaTestCasesToGlobalTestList();
    assert_equal(1, #testRunner.GlobalTestCaseList);
    
    testRunner.runAllTestCases();
    
    assert_true(setUpCalled_);
    assert_true(tearDownCalled_);
    
    -- clear lists of tests
    luaUnit.TestRegistry:reset();
    testRunner.GlobalTestCaseList = {};
end

function runAllTestCasesTest()
    local TEST_SUITE = luaUnit.TEST_SUITE;
    local TEST_CASE = luaUnit.TEST_CASE;
    local ASSERT_TRUE = luaUnit.ASSERT_TRUE;
    
    TEST_SUITE("RunTestCaseTestSuite")
    {
        TEST_CASE{"successfullTest", function()
            ASSERT_TRUE(true);
        end
        };
        
        TEST_CASE{"failureTest", function()
            ASSERT_TRUE(false);
        end;
        };
    };
    
    local ttpl1 = testListeners.TextTestProgressListener:new();
    local ttpl2 = testListeners.SciteTextTestProgressListener:new();
    local tr = testRunner.TestObserver:new();
    
    function ttpl1:startTests()
        self.startTestsCall = true;
    end
    function ttpl1:endTests()
        self.endTestsCall = true;
    end
    function ttpl1:outputMessage(message)
    end
    
    function ttpl2:startTests()
        self.startTestsCall = true;
    end
    function ttpl2:endTests()
        self.endTestsCall = true;
    end
    function ttpl2:outputMessage(message)
    end
    
    tr:addTestListener(ttpl1);
    tr:addTestListener(ttpl2);

    testRunner.copyAllLuaTestCasesToGlobalTestList();
    testRunner.runAllTestCases(tr);
    
    assert_true(ttpl1.startTestsCall);
    assert_true(ttpl1.endTestsCall);
    
    assert_true(ttpl2.startTestsCall);
    assert_true(ttpl2.endTestsCall);
end

------------------------------------------------------
function isTestFunctionTest()
    local isTestFunction = testRunner.isTestFunction;
    assert_true(isTestFunction("test"));
    assert_true(isTestFunction("Test"));
    assert_true(isTestFunction("test1"));
    assert_true(isTestFunction("Test1"));
    assert_true(isTestFunction("sometest"));
    assert_true(isTestFunction("SomeTest"));

    assert_false(isTestFunction("TEST_FIXTURE"));
    assert_false(isTestFunction("TEST_SUITE"));
    assert_false(isTestFunction("TEST_CASE"));
    assert_false(isTestFunction("TEST_CASE_EX"));

    assert_true(isTestFunction("test_fixture"));
    assert_true(isTestFunction("test_suite"));
    assert_true(isTestFunction("test_case"));
    assert_true(isTestFunction("test_case_ex"));
end

function isLuaTestDriverTest()
    assert_true(testRunner.isLuaTestDriver("unit.t.lua"));
    assert_true(testRunner.isLuaTestDriver(" .t.lua"));
    assert_false(testRunner.isLuaTestDriver("unit_t.lua"));
    assert_false(testRunner.isLuaTestDriver("unit.test.lua"));
    assert_false(testRunner.isLuaTestDriver("unit.lua.t"));
end

function isCppTestDriverTest()
    assert_true(testRunner.isCppTestDriver("unit.t.dll"));
    assert_true(testRunner.isCppTestDriver(" .t.dll"));
    assert_false(testRunner.isCppTestDriver("unit_t.dll"));
    assert_false(testRunner.isCppTestDriver("unit.test.dll"));
    assert_false(testRunner.isCppTestDriver("unit.dll.t"));
    assert_false(testRunner.isCppTestDriver("unit.t.cpp"));
end
