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

local luaUnit = require "yunit.luaunit"
local testResultHandlers = require "yunit.test_result_handlers"
local testRunner = require "yunit.test_runner"
local fs = require "yunit.filesystem"
local aux = require "yunit.aux_test_func"

--[[ Test Fixtures ]]


useTmpDir = 
{
    setUp = function(self)
        self.currentDir_ = lfs.currentdir()
        self.tmpDir_ = fs.tmpDirName()
        isTrue(lfs.mkdir(self.tmpDir_))
    end
    ;
    tearDown = function(self)
        isTrue(lfs.chdir(self.currentDir_))
        local status, msg = fs.rmdir(self.tmpDir_)
        areEq(nil, msg)
        isTrue(status)
    end
    ;
}

--[[ Tests ]]

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
    local fakeTestCaseName = _NAME;
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

function testSetGoodWorkingDir()
    isTrue(fs.isExist('test_runner.t.lua'))
end

function sortTestCasesAccordingFileAndLine()
	local tests = 
	{
		{
			fileName = function() return 'test_b.t.lua' end,
			lineNumber = function() return 9 end,
		},
		{
			fileName = function() return 'test_a.t.lua' end,
			lineNumber = function() return 11 end,
		},
		{
			fileName = function() return 'test_a.t.lua' end,
			lineNumber = function() return 10 end,
		},
	}
	
	table.sort(tests, testRunner.operatorLess)
	
	areEq('test_a.t.lua', tests[1]:fileName())
	areEq(10, tests[1]:lineNumber())

	areEq('test_a.t.lua', tests[2]:fileName())
	areEq(11, tests[2]:lineNumber())

	areEq('test_b.t.lua', tests[3]:fileName())
	areEq(9, tests[3]:lineNumber())
end

function useTmpDir:find_all_test_containers_from_current_folder()
    local testContainer1path = self.tmpDir_ .. fs.osSlash() .. 'test_container.t.lua'
    local testContainer1content = 
[[function test1()
    isTrue(true)
end]]
    aux.createTextFileWithContent(testContainer1path, testContainer1content)

    local runner = testRunner.TestRunner:new()
    local fixFailed = testResultHandlers.FixFailed:new()
    runner:addResultHandler(fixFailed)
    runner:loadLtue('yunit.luaunit')
    isNotNil(next(runner.ltues_))
    isNotNil(next(runner.fileExts_))
    runner:runTestContainersFromDir(self.tmpDir_)
    isTrue(fixFailed:passed())
end

function test_frame()
    ---------------------------------------------------
    -- initialize message system
    local testObserver = testRunner.TestResultHandlerList:new()
    local mockTestListener = testRunner.TestResultHandler:new()
    mockTestListener.error_ = false
    function mockTestListener:onTestError(name, errObj)
        mockTestListener.error_ = true
        print(name)
        print(errObj.func)
    end
    function mockTestListener:onTestFailure(name, errObj)
        mockTestListener.error_ = true
    end
    testObserver:addHandler(mockTestListener)

    -- Make TestCase manually, then run it 

    local testcase = luaUnit.TestCase:new("testFrameTestCase")
    testcase.test = function()
        return true, {}
    end
    testcase.setUp = testcase.test
    testcase.tearDown = testcase.test
    
    testRunner.runTestCase(testcase, testObserver)
    isFalse(mockTestListener.error_)
end

