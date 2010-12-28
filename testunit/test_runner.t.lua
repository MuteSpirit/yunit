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




local luaUnit = require("testunit.luaunit")
local testListeners = require("testunit.test_listeners");
local testRunner = require("testunit.test_runner");
local fs = require("filesystem");
local aux = require("aux_test_func");

-- This fixture save (at setUp) and restore (at tearDown) currentSuite variable at luaunit module for possibility TEST_* macro testing
substitutionCurrentTestRegistryAndTestSuitePlusUseTmpDir = 
{
    setUp = function(self)
        testRegistry = luaUnit.TestRegistry:new();
        currentTestRegistry = luaUnit.currentTestRegistry();
        luaUnit.currentTestRegistry(testRegistry);
        
        currentSuite = luaUnit.currentSuite();

        tmpDir = fs.tmpDirName();
        lfs.mkdir(tmpDir);
    end
    ;
    tearDown = function(self)
        luaUnit.currentSuite(currentSuite);
        luaUnit.currentTestRegistry(currentTestRegistry);
        currentSuite = nil;
        testRegistry = nil;
        
        isNotNil(tmpDir);
        isTrue(lfs.chdir(tmpDir .. fs.osSlash() .. '..'))
        local status, msg = fs.rmdir(tmpDir)
        areEq(nil, msg)
        isTrue(status)
    end
    ;
};

globalTestCaseListFixture = 
{
    setUp = function(self)
        testRegistry = luaUnit.TestRegistry:new();
        currentTestRegistry = luaUnit.currentTestRegistry();
        luaUnit.currentTestRegistry(testRegistry);
        
        currentSuite = luaUnit.currentSuite();

        globalTestCaseList = luaUnit.copyTable(testRunner.GlobalTestCaseList);
        testRunner.GlobalTestCaseList = {};
    end
    ;
    tearDown = function(self)
        luaUnit.currentSuite(currentSuite);
        luaUnit.currentTestRegistry(currentTestRegistry);
        currentSuite = nil;
        testRegistry = nil;

        testRunner.GlobalTestCaseList = luaUnit.copyTable(globalTestCaseList);
    end
    ;
};
    function testTestListenerCreation()
        isNotNil(testRunner.TestListener:new());
    end


    function testObserverCreationTest()
        isNotNil(testRunner.TestObserver:new());
    end


    function testObserverTestAddFailureFunctionTest()
        local ttpl1 = testListeners.TextTestProgressListener:new();
        local ttpl2 = testListeners.TextTestProgressListener:new();
        local tr = testRunner.TestObserver:new();
        local fakeTestCaseName = _M._NAME;
        local fakeTestName = "testTestObserver";
        local fakeFailureMessage = "This is test message. It hasn't usefull information";
        
        isNotNil(fakeTestCaseName)
        
        function ttpl1:addFailure(testCaseName, failureMessage)
            areEq(fakeTestCaseName, testCaseName);
            areEq(fakeFailureMessage, failureMessage);
        end
        
        function ttpl2:addFailure(testCaseName, failureMessage)
            areEq(fakeTestCaseName, testCaseName);
            areEq(fakeFailureMessage, failureMessage);
        end
        
        tr:addTestListener(ttpl1);
        tr:addTestListener(ttpl2);
        areEq(2, #tr.testListeners);
        
        tr:addFailure(fakeTestCaseName, fakeFailureMessage);
    end


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
         
        isTrue(ttpl1.startTestsCall);
        isTrue(ttpl2.startTestsCall);
    end

    function globalTestCaseListFixture.runTestCaseTest()

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

        isNotNil(_G["CallSetUpAndTearDownTestFixture"]);
        
        TEST_SUITE("CallSetUpAndTearDownTestSuite")
        {
            TEST_CASE_EX{"CallSetUpAndTearDownTestCase",  'CallSetUpAndTearDownTestFixture', function(self)
                
            end
            };
        }
        
        areEq(2, #testRegistry.testsuites);
        areEq(1, #testRegistry.testsuites[2].testcases);
        areEq("CallSetUpAndTearDownTestCase", testRegistry.testsuites[2].testcases[1].name_);
        
        testRunner.copyAllLuaTestCasesToGlobalTestList();
        areEq(1, #testRunner.GlobalTestCaseList);
        areEq("CallSetUpAndTearDownTestSuite::CallSetUpAndTearDownTestCase", testRunner.GlobalTestCaseList[1].name_);
        
        testRunner.runAllTestCases();
        
        isTrue(setUpCalled_);
        isTrue(tearDownCalled_);
    end

    function globalTestCaseListFixture.runAllTestCasesTest()
        local TEST_SUITE = luaUnit.TEST_SUITE;
        local TEST_CASE = luaUnit.TEST_CASE;
        local ASSERT_TRUE = luaUnit.ASSERT_TRUE;
        
        TEST_SUITE("RunTestCaseTestSuite")
        {
            TEST_CASE{"successfullTest", function()
                isTrue(true);
            end
            };
            
            TEST_CASE{"failureTest", function()
                isTrue(false);
            end
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
        
        isTrue(ttpl1.startTestsCall);
        isTrue(ttpl1.endTestsCall);
        
        isTrue(ttpl2.startTestsCall);
        isTrue(ttpl2.endTestsCall);
    end


    function isTestFunctionTest()
        local isTestFunction = testRunner.isTestFunction;
        isTrue(isTestFunction("test"));
        isTrue(isTestFunction("Test"));
        isTrue(isTestFunction("test1"));
        isTrue(isTestFunction("Test1"));
        isTrue(isTestFunction("sometest"));
        isTrue(isTestFunction("SomeTest"));

        isFalse(isTestFunction("TEST_FIXTURE"));
        isFalse(isTestFunction("TEST_SUITE"));
        isFalse(isTestFunction("TEST_CASE"));
        isFalse(isTestFunction("TEST_CASE_EX"));

        isTrue(isTestFunction("test_fixture"));
        isTrue(isTestFunction("test_suite"));
        isTrue(isTestFunction("test_case"));
        isTrue(isTestFunction("test_case_ex"));
    end

    function isLuaTestContainerTest()
        isTrue(testRunner.isLuaTestContainer("unit.t.lua"));
        isTrue(testRunner.isLuaTestContainer(" .t.lua"));
        isFalse(testRunner.isLuaTestContainer("unit_t.lua"));
        isFalse(testRunner.isLuaTestContainer("unit.test.lua"));
        isFalse(testRunner.isLuaTestContainer("unit.lua.t"));
    end

    function isCppTestContainerTest()
        isTrue(testRunner.isCppTestContainer("unit.t.dll"));
        isTrue(testRunner.isCppTestContainer(" .t.dll"));
        isFalse(testRunner.isCppTestContainer("unit_t.dll"));
        isFalse(testRunner.isCppTestContainer("unit.test.dll"));
        isFalse(testRunner.isCppTestContainer("unit.dll.t"));
        isFalse(testRunner.isCppTestContainer("unit.t.cpp"));
    end
    
    function substitutionCurrentTestRegistryAndTestSuitePlusUseTmpDir.loadLuaContainerTest()
        local luaTestContainerText = 
            [[fixture =
                {
                    setUp = function()
                    end,

                    tearDown = function()
                    end
                }
                function testCase() end 
                function fixture.fixtureTestCase() end 
                local function notTestCase() end
                function _ignoredTest() end
                ]]
        local luaTestContainerFilename = tmpDir .. fs.osSlash() .. 'load_lua_container.t.lua'
        isTrue(aux.createTextFileWithContent(luaTestContainerFilename, luaTestContainerText))
        
        areEq(1, #testRegistry.testsuites)
        areEq(0, #testRegistry.testsuites[1].testcases)
        
        local status, msg = testRunner.loadLuaContainer(luaTestContainerFilename)
        areEq(nil, msg)
        isTrue(status)
        
        areEq(2, #testRegistry.testsuites)
        areEq(0, #testRegistry.testsuites[1].testcases)
        areEq(3, #testRegistry.testsuites[2].testcases)

        areEq(luaTestContainerFilename, testRegistry.testsuites[2].name_)
    end

