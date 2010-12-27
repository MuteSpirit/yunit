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

--- \fn loadLuaContainer(filePath)
--- \brief Load tests from Lua file
--- \param[in] filePath Path to the file, whitch name correspond to wildcard "*.t.lua"
--- \return None

--- \fn loadCppContainer(filePath)
--- \brief Load C++ test driver (in view of DLL) to the current process
--- \param[in] filePath Path to the file, whitch name correspond to wildcard "*.t.dll"
--- \return None

--- \fn isLuaTestContainer(filePath)
--- \brief Check if 'filePath' is correspond to wildcard "*.t.lua"
--- \return true or false

--- \fn isCppTestContainer(filePath)
--- \brief Check if 'filePath' is correspond to wildcard "*.t.dll"
--- \return true or false

--- \fn initializeTestUnits()
--- \brief Load modules, whitch allow to work with Lua and C++ tests
--- \return None

--- \fn loadTestContainers(filePathList)
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

local luaUnit = require("testunit.luaunit");

module('test_runner.t', luaUnit.testmodule, package.seeall);

local testListeners = require("testunit.test_listeners");
local testRunner = require("testunit.test_runner");

-- This fixture save (at setUp) and restore (at tearDown) currentSuite variable at luaunit module for possibility TEST_* macro testing
TEST_FIXTURE("LuaUnitSelfTestFixture")
{
    setUp = function(self)
        self.testRegistry = luaUnit.TestRegistry:new();
        self.currentTestRegistry = luaUnit.currentTestRegistry();
        luaUnit.currentTestRegistry(self.testRegistry);
        
        self.currentSuite = luaUnit.currentSuite();
    end
    ;
    tearDown = function(self)
        luaUnit.currentSuite(self.currentSuite);
        luaUnit.currentTestRegistry(self.currentTestRegistry);
        self.currentSuite = nil;
        self.testRegistry = nil;
    end
    ;
};

TEST_FIXTURE("GlobalTestCaseListFixture")
{
    setUp = function(self)
        self.testRegistry = luaUnit.TestRegistry:new();
        self.currentTestRegistry = luaUnit.currentTestRegistry();
        luaUnit.currentTestRegistry(self.testRegistry);
        
        self.currentSuite = luaUnit.currentSuite();

        self.globalTestCaseList = luaUnit.copyTable(testRunner.GlobalTestCaseList);
        testRunner.GlobalTestCaseList = {};
    end
    ;
    tearDown = function(self)
        luaUnit.currentSuite(self.currentSuite);
        luaUnit.currentTestRegistry(self.currentTestRegistry);
        self.currentSuite = nil;
        self.testRegistry = nil;

        testRunner.GlobalTestCaseList = luaUnit.copyTable(self.globalTestCaseList);
    end
    ;
};

TEST_SUITE("testModuleName")
{
    TEST_CASE{"testTestListenerCreation", function(self)
        ASSERT_IS_NOT_NIL(testRunner.TestListener:new());
    end
    };


    TEST_CASE{"testObserverCreationTest", function(self)
        ASSERT_IS_NOT_NIL(testRunner.TestObserver:new());
    end
    };


    TEST_CASE{"testObserverTestAddFailureFunctionTest", function(self)
        local ttpl1 = testListeners.TextTestProgressListener:new();
        local ttpl2 = testListeners.TextTestProgressListener:new();
        local tr = testRunner.TestObserver:new();
        local fakeTestCaseName = _M._NAME;
        local fakeTestName = "testTestObserver";
        local fakeFailureMessage = "This is test message. It hasn't usefull information";
        
        ASSERT_IS_NOT_NIL(fakeTestCaseName)
        
        function ttpl1:addFailure(testCaseName, failureMessage)
            ASSERT_EQUAL(fakeTestCaseName, testCaseName);
            ASSERT_EQUAL(fakeFailureMessage, failureMessage);
        end
        
        function ttpl2:addFailure(testCaseName, failureMessage)
            ASSERT_EQUAL(fakeTestCaseName, testCaseName);
            ASSERT_EQUAL(fakeFailureMessage, failureMessage);
        end
        
        tr:addTestListener(ttpl1);
        tr:addTestListener(ttpl2);
        ASSERT_EQUAL(2, #tr.testListeners);
        
        tr:addFailure(fakeTestCaseName, fakeFailureMessage);
    end
    };


    TEST_CASE{"testObserverStartTestsFunctionTest", function(self)
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
         
        ASSERT_TRUE(ttpl1.startTestsCall);
        ASSERT_TRUE(ttpl2.startTestsCall);
    end
    };

    TEST_CASE_EX{"runTestCaseTest", "GlobalTestCaseListFixture", function(self)

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

        ASSERT_IS_NOT_NIL(_G["CallSetUpAndTearDownTestFixture"]);
        
        TEST_SUITE("CallSetUpAndTearDownTestSuite")
        {
            TEST_CASE_EX{"CallSetUpAndTearDownTestCase", "CallSetUpAndTearDownTestFixture", function(self)
                
            end
            };
        };
        
        ASSERT_EQUAL(2, #self.testRegistry.testsuites);
        ASSERT_EQUAL(1, #self.testRegistry.testsuites[2].testcases);
        ASSERT_EQUAL("CallSetUpAndTearDownTestCase", self.testRegistry.testsuites[2].testcases[1].name_);
        
        testRunner.copyAllLuaTestCasesToGlobalTestList();
        ASSERT_EQUAL(1, #testRunner.GlobalTestCaseList);
        ASSERT_EQUAL("CallSetUpAndTearDownTestSuite::CallSetUpAndTearDownTestCase", testRunner.GlobalTestCaseList[1].name_);
        
        testRunner.runAllTestCases();
        
        ASSERT_TRUE(setUpCalled_);
        ASSERT_TRUE(tearDownCalled_);
    end
    };

    TEST_CASE_EX{"runAllTestCasesTest", "GlobalTestCaseListFixture", function(self)
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
        
        ASSERT_TRUE(ttpl1.startTestsCall);
        ASSERT_TRUE(ttpl1.endTestsCall);
        
        ASSERT_TRUE(ttpl2.startTestsCall);
        ASSERT_TRUE(ttpl2.endTestsCall);
    end
    };


    TEST_CASE{"isTestFunctionTest", function(self)
        local isTestFunction = testRunner.isTestFunction;
        ASSERT_TRUE(isTestFunction("test"));
        ASSERT_TRUE(isTestFunction("Test"));
        ASSERT_TRUE(isTestFunction("test1"));
        ASSERT_TRUE(isTestFunction("Test1"));
        ASSERT_TRUE(isTestFunction("sometest"));
        ASSERT_TRUE(isTestFunction("SomeTest"));

        ASSERT_FALSE(isTestFunction("TEST_FIXTURE"));
        ASSERT_FALSE(isTestFunction("TEST_SUITE"));
        ASSERT_FALSE(isTestFunction("TEST_CASE"));
        ASSERT_FALSE(isTestFunction("TEST_CASE_EX"));

        ASSERT_TRUE(isTestFunction("test_fixture"));
        ASSERT_TRUE(isTestFunction("test_suite"));
        ASSERT_TRUE(isTestFunction("test_case"));
        ASSERT_TRUE(isTestFunction("test_case_ex"));
    end
    };

    TEST_CASE{"isLuaTestContainerTest", function(self)
        ASSERT_TRUE(testRunner.isLuaTestContainer("unit.t.lua"));
        ASSERT_TRUE(testRunner.isLuaTestContainer(" .t.lua"));
        ASSERT_FALSE(testRunner.isLuaTestContainer("unit_t.lua"));
        ASSERT_FALSE(testRunner.isLuaTestContainer("unit.test.lua"));
        ASSERT_FALSE(testRunner.isLuaTestContainer("unit.lua.t"));
    end
    };

    TEST_CASE{"isCppTestContainerTest", function(self)
        ASSERT_TRUE(testRunner.isCppTestContainer("unit.t.dll"));
        ASSERT_TRUE(testRunner.isCppTestContainer(" .t.dll"));
        ASSERT_FALSE(testRunner.isCppTestContainer("unit_t.dll"));
        ASSERT_FALSE(testRunner.isCppTestContainer("unit.test.dll"));
        ASSERT_FALSE(testRunner.isCppTestContainer("unit.dll.t"));
        ASSERT_FALSE(testRunner.isCppTestContainer("unit.t.cpp"));
    end
    };
};

