--- \class TestResultHandler
--- \brief Base class for all Test Listeners classes. Contain interface functions and their empty definitions

--- \class TestResultHandlerList
--- \brief Variation of pattern observer for events during test execution process. Contain several 
--- TestListeners and inform then about test events

--- \fn TestResultHandlerList:callHandlersMethod(functionName, ...)
--- \brief Function call function with name 'functionName' of each TestResultHandler, whitch contained at list 'listeners'
--- \param[in] functionName Each TestResultHandler must have function with such name.
--- \param[in] ... Arguments, whith will be sended to the function 
--- \return None

--- \fn isTestFunction(functionName)
--- \brief Function is consided as test function if it contain word 'test' at the begining or
--- at the end of it's name
--- \param[in] functionName Name of function for check
--- \return boolean

--- \fn runTestCase(testcase, testResultHandler)
--- \brief This is "Frame of Test". Run setUp(), test() and tearDown() function of testcase (if thay are present, i.e. it may not use fixture).
--- \param[in] testcase TestCase for run
--- \param[in] testResultHandler TesObserver for log events
--- \return None

--- \var GlobalTestCaseList
--- \brief Global list of TestCases

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




local luaUnit = require("yunit.luaunit")
local testResultHandlers = require("yunit.test_result_handlers");
local testRunner = require("yunit.test_runner");
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

        self.curDir = lfs.currentdir();
        tmpDir = fs.tmpDirName();
        lfs.mkdir(tmpDir);
    end
    ;
    tearDown = function(self)
        luaUnit.currentSuite(currentSuite);
        luaUnit.currentTestRegistry(currentTestRegistry);
        currentSuite = nil;
        testRegistry = nil;
        
        -- delete tmpDir recursively
        isNotNil(tmpDir);
        isTrue(lfs.chdir(self.curDir))
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

globalTestCaseListFixturePlusUseTmpDir =
{
    setUp = function(self)
        self.testRegistry = luaUnit.TestRegistry:new();
        self.currentTestRegistry = luaUnit.currentTestRegistry();
        luaUnit.currentTestRegistry(self.testRegistry);
        
        self.currentSuite = luaUnit.currentSuite();
        luaUnit.currentSuite(self.testRegistry.testsuites[1]);

        self.globalTestCaseList = luaUnit.copyTable(testRunner.GlobalTestCaseList);
        testRunner.GlobalTestCaseList = {};

        self.curDir = lfs.currentdir();
        self.tmpDir = fs.tmpDirName();
        lfs.mkdir(self.tmpDir);
    end
    ;
    tearDown = function(self)
        luaUnit.currentSuite(self.currentSuite);
        luaUnit.currentTestRegistry(self.currentTestRegistry);
        self.currentSuite = nil;
        self.testRegistry = nil;

        testRunner.GlobalTestCaseList = luaUnit.copyTable(self.globalTestCaseList);

        -- delete tmpDir recursively
        isNotNil(self.tmpDir);
        isTrue(lfs.chdir(self.curDir))
        local status, msg = fs.rmdir(self.tmpDir)
        areEq(nil, msg)
        isTrue(status)
    end
    ;
};

    function testTestListenerCreation()
        isNotNil(testRunner.TestResultHandler:new());
    end


    function testObserverCreationTest()
        isNotNil(testRunner.TestResultHandlerList:new());
    end


    function testObserverTestAddFailureFunctionTest()
        local ttpl1 = testResultHandlers.TextTestProgressHandler:new();
        local ttpl2 = testResultHandlers.TextTestProgressHandler:new();
        local tr = testRunner.TestResultHandlerList:new();
        local fakeTestCaseName = _M._NAME;
        local fakeTestName = "testTestListenerList";
        local fakeFailureMessage = "This is test message. It hasn't usefull information";
        
        isNotNil(fakeTestCaseName)
        
        function ttpl1:onTestFailure(testCaseName, failureMessage)
            areEq(fakeTestCaseName, testCaseName);
            areEq(fakeFailureMessage, failureMessage);
        end
        
        function ttpl2:onTestFailure(testCaseName, failureMessage)
            areEq(fakeTestCaseName, testCaseName);
            areEq(fakeFailureMessage, failureMessage);
        end
        
        tr:addHandler(ttpl1);
        tr:addHandler(ttpl2);
        areEq(2, #tr.testResultHandlers);
        
        tr:onTestFailure(fakeTestCaseName, fakeFailureMessage);
    end


    function testObserverStartTestsFunctionTest()
        local ttpl1 = testResultHandlers.TextTestProgressHandler:new();
        local ttpl2 = testResultHandlers.SciteTextTestProgressHandler:new();
        local tr = testRunner.TestResultHandlerList:new();
        
        function ttpl1:onTestsBegin()
            self.onTestsBeginCall = true;
        end
        
        function ttpl2:onTestsBegin()
            self.onTestsBeginCall = true;
        end
        
        tr:addHandler(ttpl1);
        tr:addHandler(ttpl2);
        
        tr:onTestsBegin();
         
        isTrue(ttpl1.onTestsBeginCall);
        isTrue(ttpl2.onTestsBeginCall);
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
        
        areEq(0, #testRegistry.testsuites)
        
        local status, msg = luaUnit.loadTestContainer(luaTestContainerFilename)
        areEq(nil, msg)
        isTrue(status)
        
        areEq(1, #testRegistry.testsuites)
        areEq(3, #testRegistry.testsuites[1].testcases)

        areEq(luaTestContainerFilename, testRegistry.testsuites[1].name_)
    end

function globalTestCaseListFixturePlusUseTmpDir.runSomeTestContainer(self)
    local testContainerPath = self.tmpDir .. fs.osSlash() .. 'lua_test_container.t.lua'
    local testContainerText = [[function someTestCase() end]]
    isTrue(aux.createTextFileWithContent(testContainerPath, testContainerText))
   
    areEq(0, #self.testRegistry.testsuites)

    require('default_test_run')
    run(testContainerPath)
    
    areEq(1, #self.testRegistry.testsuites)
    areEq(1, #self.testRegistry.testsuites[1].testcases)
    areEq("someTestCase", self.testRegistry.testsuites[1].testcases[1].name_)
end

function testSetGoodWorkingDir()
    isTrue(fs.isExist('test_runner.t.lua'));
end

function loadTestUnitEnginesTest()
    testRunner.loadTestUnitEngines{'cppunit'};
    isTable(testRunner.GlobalTestUnitEngineList['.t.dll']);
    
    testRunner.loadTestUnitEngines{'yunit.luaunit'};
    isTable(testRunner.GlobalTestUnitEngineList['.t.lua']);
end

function sortTestCasesAccordingFileAndLine()
	local tests = 
	{
		{
			['fileName_'] = 'test_b.t.lua',
			['lineNumber_'] = 9,
		},
		{
			['fileName_'] = 'test_a.t.lua',
			['lineNumber_'] = 11,
		},
		{
			['fileName_'] = 'test_a.t.lua',
			['lineNumber_'] = 10,
		},
	}
	
	table.sort(tests, testRunner.operatorLess)
	
	areEq('test_a.t.lua', tests[1].fileName_)
	areEq(10, tests[1].lineNumber_)

	areEq('test_a.t.lua', tests[2].fileName_)
	areEq(11, tests[2].lineNumber_)

	areEq('test_b.t.lua', tests[3].fileName_)
	areEq(9, tests[3].lineNumber_)
end
